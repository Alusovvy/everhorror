extends Node3D
class_name CharacterModel

## Builds a character from Quaternius parts that share one skeleton and plays retargeted
## animations from the Universal Animation Library.
## The bare base body is replaced by a head-only mesh (see tools/generators/build_character_head.gd),
## so clothing parts go on top without clipping.

const MALE_BASE := preload("res://assets/characters/quaternius/base/Superhero_Male_FullBody.gltf")
const MALE_HEAD := preload("res://assets/characters/quaternius/base/head_male.res")
const ANIMATION_SOURCE := preload("res://assets/characters/quaternius/animations/AnimationLibrary_Godot_Standard.glb")
## One-shot animations in the library that NPCs hold as looping work poses.
const LOOPED_WORK_ANIMATIONS: Array[StringName] = [&"Fixing_Kneeling", &"Interact", &"PickUp_Table", &"Push"]

## Base body (male if empty). Its skin mesh is swapped for `head_mesh`.
@export var base_scene: PackedScene
## Head-only mesh cut from the base body (male head if empty).
@export var head_mesh: Mesh
## Outfit, hair, beard… Each is a glTF rigged to the same skeleton.
@export var parts: Array[PackedScene] = []
## Node names of part meshes to hide, e.g. the hood that comes with the ranger outfit.
@export var hidden_meshes: PackedStringArray = []
## Scenes attached to the head bone (e.g. the iron mask), placed in the bone's space.
@export var head_attachments: Array[PackedScene] = []
## Scenes held in a hand (a mage's staff, a guard's sword), in the hand bone's space.
@export var hand_attachments: Array[PackedScene] = []
## The hand that holds them. Idle_Torch raises the left fist (a staff held upright).
@export_enum("RightHand", "LeftHand") var hand_bone: String = "RightHand"
## Replaces the outfit's base colour texture (e.g. T_Peasant_2_BaseColor for a variant).
@export var outfit_texture: Texture2D
## Multiplies the outfit colour (dirt, soot).
@export var outfit_tint: Color = Color.WHITE
## Multiplies the hair colour (grey for older characters).
@export var hair_tint: Color = Color.WHITE
## Multiplies the skin colour (people from the desert, a sun-starved scribe).
@export var skin_tint: Color = Color.WHITE
## Animation played on start: Idle, Idle_Talking, Sitting_Idle, Sitting_Talking, Idle_Torch, …
@export var animation: StringName = &"Idle"

static var _library: AnimationLibrary

var skeleton: Skeleton3D
var anim_player: AnimationPlayer

func _ready() -> void:
	var body := (base_scene if base_scene else MALE_BASE).instantiate()
	body.name = "Body"
	add_child(body)
	skeleton = body.find_child("GeneralSkeleton", true, false) as Skeleton3D
	_find_skin_mesh(body).mesh = head_mesh if head_mesh else MALE_HEAD
	_customise_meshes(body)
	for scene in parts:
		var part := scene.instantiate()
		add_child(part)
		for mesh in part.find_children("*", "MeshInstance3D", true, false):
			(mesh as MeshInstance3D).skeleton = mesh.get_path_to(skeleton)
		_customise_meshes(part)
	for mesh_name in hidden_meshes:
		var hidden := find_child(mesh_name, true, false) as Node3D
		if hidden:
			hidden.visible = false
	for scene in head_attachments:
		_attach(scene, "Head")
	for scene in hand_attachments:
		_attach(scene, hand_bone)
	anim_player = AnimationPlayer.new()
	anim_player.name = "AnimationPlayer"
	body.add_child(anim_player)
	anim_player.add_animation_library(&"", _get_library())
	play(animation)

func _attach(scene: PackedScene, bone: String) -> void:
	var attachment := BoneAttachment3D.new()
	attachment.bone_name = bone
	skeleton.add_child(attachment)
	attachment.add_child(scene.instantiate())

## Plays an animation by name (blended over 0.3 s).
func play(anim_name: StringName) -> void:
	animation = anim_name
	if anim_player and anim_player.has_animation(anim_name):
		anim_player.play(anim_name, 0.3)

## The base body's skin mesh (material MI_Superhero_*), not its eyes or eyebrows.
func _find_skin_mesh(body: Node) -> MeshInstance3D:
	for node in body.find_children("*", "MeshInstance3D", true, false):
		var material := (node as MeshInstance3D).get_active_material(0)
		if material and material.resource_name.to_lower().contains("superhero"):
			return node
	return null

func _customise_meshes(root: Node) -> void:
	for mesh in root.find_children("*", "MeshInstance3D", true, false):
		var mi := mesh as MeshInstance3D
		for surface in mi.mesh.get_surface_count():
			var material := mi.get_active_material(surface) as StandardMaterial3D
			if material == null:
				continue
			var tinted := _customise(material)
			if tinted:
				mi.set_surface_override_material(surface, tinted)

## Returns a recoloured copy of the part's material, or null to keep the original.
func _customise(material: StandardMaterial3D) -> StandardMaterial3D:
	var material_name := material.resource_name.to_lower()
	if "superhero" in material_name and skin_tint != Color.WHITE:
		var skin := material.duplicate() as StandardMaterial3D
		skin.albedo_color = skin.albedo_color * skin_tint
		return skin
	if "hair" in material_name and hair_tint != Color.WHITE:
		var hair := material.duplicate() as StandardMaterial3D
		hair.albedo_color = hair.albedo_color * hair_tint
		return hair
	var is_outfit := "peasant" in material_name or "ranger" in material_name
	if is_outfit and (outfit_texture or outfit_tint != Color.WHITE):
		var cloth := material.duplicate() as StandardMaterial3D
		if outfit_texture:
			cloth.albedo_texture = outfit_texture
		cloth.albedo_color = cloth.albedo_color * outfit_tint
		return cloth
	return null

static func _get_library() -> AnimationLibrary:
	if _library == null:
		var source := ANIMATION_SOURCE.instantiate()
		var player := source.find_child("AnimationPlayer", true, false) as AnimationPlayer
		_library = player.get_animation_library(&"")
		for anim_name in LOOPED_WORK_ANIMATIONS:
			if _library.has_animation(anim_name):
				_library.get_animation(anim_name).loop_mode = Animation.LOOP_LINEAR
		source.free()
	return _library
