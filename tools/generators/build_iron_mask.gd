extends SceneTree
## Usage: godot --headless --path . --script res://tools/generators/build_iron_mask.gd
## Builds the iron face mask worn by the Drudzy (LoreDoc: "na twarzach noszą żelazne maski"):
## a curved plate over the front of the head with two eye slits and a ridge down the middle.
## Writes res://assets/characters/iron_mask.res (mesh with its material).

const OUT := "res://assets/characters/iron_mask.res"
## Ellipsoid the plate follows (metres), centred on the face.
const RADII := Vector3(0.086, 0.115, 0.105)
const THETA := Vector2(-78.0, 78.0)   # horizontal extent, degrees (0 = straight ahead)
const PHI := Vector2(-58.0, 52.0)     # vertical extent, degrees (0 = eye level)
const STEPS := Vector2i(40, 30)
## Eye slits: centre (theta, phi) and half-size in degrees.
const EYES := [Vector4(-24.0, 7.0, 12.0, 3.6), Vector4(24.0, 7.0, 12.0, 3.6)]

func _initialize() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in STEPS.x:
		for j in STEPS.y:
			var t0 := lerpf(THETA.x, THETA.y, float(i) / STEPS.x)
			var t1 := lerpf(THETA.x, THETA.y, float(i + 1) / STEPS.x)
			var p0 := lerpf(PHI.x, PHI.y, float(j) / STEPS.y)
			var p1 := lerpf(PHI.x, PHI.y, float(j + 1) / STEPS.y)
			if _in_eye((t0 + t1) * 0.5, (p0 + p1) * 0.5):
				continue
			var a := _point(t0, p0)
			var b := _point(t1, p0)
			var c := _point(t1, p1)
			var d := _point(t0, p1)
			for v in [a, c, b, a, d, c]:   # front faces wind clockwise in Godot
				st.set_normal(_normal(v))
				st.set_uv(Vector2(v.x / RADII.x * 0.5 + 0.5, 0.5 - v.y / RADII.y * 0.5))
				st.add_vertex(v)
	st.generate_tangents()
	var mesh := st.commit()
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.34, 0.33, 0.32)
	material.metallic = 0.45
	material.roughness = 0.5
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.surface_set_material(0, material)
	mesh.resource_name = "IronMask"
	print("iron mask saved err=", ResourceSaver.save(mesh, OUT))
	quit()

func _in_eye(theta: float, phi: float) -> bool:
	for eye in EYES:
		if absf(theta - eye.x) < eye.z and absf(phi - eye.y) < eye.w:
			return true
	return false

## Point on the ellipsoid; +Z is forward (the face), a slight ridge along theta = 0.
func _point(theta_deg: float, phi_deg: float) -> Vector3:
	var t := deg_to_rad(theta_deg)
	var p := deg_to_rad(phi_deg)
	var ridge := 1.0 + 0.06 * exp(-pow(theta_deg / 7.0, 2.0)) * (1.0 if phi_deg < 20.0 else 0.4)
	return Vector3(sin(t) * cos(p) * RADII.x, sin(p) * RADII.y, cos(t) * cos(p) * RADII.z * ridge)

func _normal(v: Vector3) -> Vector3:
	return Vector3(v.x / (RADII.x * RADII.x), v.y / (RADII.y * RADII.y), v.z / (RADII.z * RADII.z)).normalized()
