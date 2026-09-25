extends SceneTree
## Usage: godot --headless --path . --script res://tools/generators/build_character_head.gd
## Cuts the head (and neck) out of the Quaternius base body so clothing can go on top without
## the bare body clipping through. Keeps triangles whose vertices are mostly driven by the
## Head/Neck bones. Writes res://assets/characters/quaternius/base/head_male.res.

const BASE := "res://assets/characters/quaternius/base/Superhero_Male_FullBody.gltf"
const OUT := "res://assets/characters/quaternius/base/head_male.res"
const KEEP_BONES := ["Head", "Neck"]

func _initialize() -> void:
	var scene: Node = load(BASE).instantiate()
	var body := scene.find_child("SuperHero_Male", true, false) as MeshInstance3D
	var skeleton := scene.find_child("GeneralSkeleton", true, false) as Skeleton3D
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

	var head := ArrayMesh.new()
	var flags := Mesh.ARRAY_FLAG_USE_8_BONE_WEIGHTS if per_vertex == 8 else 0
	head.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays, [], {}, flags)
	var material := body.get_active_material(0)
	head.surface_set_material(0, material)
	head.resource_name = "HeadMale"
	var err := ResourceSaver.save(head, OUT)
	print("head mesh: kept %d of %d triangles, bones/vertex=%d, saved err=%d" % [kept.size() / 3, indices.size() / 3, per_vertex, err])
	scene.free()
	quit()
