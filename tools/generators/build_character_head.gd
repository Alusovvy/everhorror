extends SceneTree
## Usage: godot --headless --path . --script res://tools/generators/build_character_head.gd
## Cuts the head (and neck) out of the Quaternius base bodies so clothing can go on top without
## the bare body clipping through. Keeps triangles whose vertices are mostly driven by the
## Head/Neck bones. Writes head_male.res and head_female.res next to the base bodies, and prints
## the eye height of each body (for NpcData.portrait_eye_height).

const DIR := "res://assets/characters/quaternius/base/"
const BASES := {
	"Superhero_Male_FullBody.gltf": "head_male.res",
	"Superhero_Female_FullBody.gltf": "head_female.res",
}
const KEEP_BONES := ["Head", "Neck"]

func _initialize() -> void:
	for source_file in BASES:
		_build(DIR + source_file, DIR + BASES[source_file])
	quit()

func _build(source_path: String, out_path: String) -> void:
	var scene: Node = load(source_path).instantiate()
	var skeleton := scene.find_child("GeneralSkeleton", true, false) as Skeleton3D
	var body := _find_body(scene)
	var skin := body.skin
	var source := body.mesh as ArrayMesh
	var arrays := source.surface_get_arrays(0)
	var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	var bones: PackedInt32Array = arrays[Mesh.ARRAY_BONES]
	var weights: PackedFloat32Array = arrays[Mesh.ARRAY_WEIGHTS]
	var per_vertex := bones.size() / verts.size()

	var keep_vertex := PackedByteArray()
	keep_vertex.resize(verts.size())
	for v in verts.size():
		var best := 0
		for k in per_vertex:
			if weights[v * per_vertex + k] > weights[v * per_vertex + best]:
				best = k
		var bind := bones[v * per_vertex + best]
		var bone_name := String(skin.get_bind_name(bind)) if skin else ""
		if bone_name == "" and skin:
			bone_name = skeleton.get_bone_name(skin.get_bind_bone(bind))
		keep_vertex[v] = 1 if bone_name in KEEP_BONES else 0

	var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
	var kept := PackedInt32Array()
	for t in range(0, indices.size(), 3):
		var count := keep_vertex[indices[t]] + keep_vertex[indices[t + 1]] + keep_vertex[indices[t + 2]]
		if count >= 1:
			kept.append_array([indices[t], indices[t + 1], indices[t + 2]])
	arrays[Mesh.ARRAY_INDEX] = kept
	# Custom channels (the female body has one) would need their format flags; the head doesn't use them.
	for channel in [Mesh.ARRAY_CUSTOM0, Mesh.ARRAY_CUSTOM1, Mesh.ARRAY_CUSTOM2, Mesh.ARRAY_CUSTOM3]:
		arrays[channel] = null

	var head := ArrayMesh.new()
	var flags := Mesh.ARRAY_FLAG_USE_8_BONE_WEIGHTS if per_vertex == 8 else 0
	head.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, [], {}, flags)
	head.surface_set_material(0, body.get_active_material(0))
	head.resource_name = out_path.get_file().get_basename().to_pascal_case()
	var err := ResourceSaver.save(head, out_path)
	var head_bone := skeleton.find_bone("Head")
	var head_y := skeleton.get_bone_global_rest(head_bone).origin.y
	print("%s: body node '%s', kept %d of %d triangles, bones/vertex=%d, head bone y=%.3f, saved err=%d" % [
		out_path.get_file(), body.name, kept.size() / 3, indices.size() / 3, per_vertex, head_y, err])
	scene.free()

## The skin mesh of the base body (its material is MI_Superhero_*), not the eyes or eyebrows.
static func _find_body(scene: Node) -> MeshInstance3D:
	for node in scene.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		var material := mesh.get_active_material(0)
		if material and material.resource_name.to_lower().contains("superhero"):
			return mesh
	return null
