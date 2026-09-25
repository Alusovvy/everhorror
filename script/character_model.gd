extends Node3D
class_name CharacterModel

## Builds a character from Quaternius parts that share one skeleton and plays retargeted
## animations from the Universal Animation Library.
## The bare base body is replaced by a head-only mesh (see tools/generators/build_character_head.gd),
## so clothing parts go on top without clipping.

const BASE_SCENE := preload("res://assets/characters/quaternius/base/Superhero_Male_FullBody.gltf")
const HEAD_MESH := preload("res://assets/characters/quaternius/base/head_male.res")
const ANIMATION_SOURCE := preload("res://assets/characters/quaternius/animations/AnimationLibrary_Godot_Standard.glb")

## Outfit, hair, beard… Each is a glTF rigged to the same skeleton.
@export var parts: Array[PackedScene] = []
## Replaces the outfit's base colour texture (e.g. T_Peasant_2_BaseColor for a variant).
@export var outfit_texture: Texture2D
## Multiplies the outfit colour (dirt, soot).
@export var outfit_tint: Color = Color.WHITE
## Multiplies the hair colour (grey for older characters).
@export var hair_tint: Color = Color.WHITE
## Animation played on start: Idle, Idle_Talking, Sitting_Idle, Sitting_Talking, Idle_Torch, …
@export var animation: StringName = &"Idle"

static var _library: AnimationLibrary

var skeleton: Skeleton3D
var anim_player: AnimationPlayer

func _ready() -> void:
	var body := BASE_SCENE.instantiate()
	body.name = "Body"
	add_child(body)
	skeleton = body.find_child("GeneralSkeleton", true, false) as Skeleton3D
	(skeleton.get_node("SuperHero_Male") as MeshInstance3D).mesh = HEAD_MESH
	_customise_meshes(body)
	for scene in parts:
		var part := scene.instantiate()
		add_child(part)
		for mesh in part.find_children("*", "MeshInstance3D", true, false):
			(mesh as MeshInstance3D).skeleton = mesh.get_path_to(skeleton)
		_customise_meshes(part)
	anim_player = AnimationPlayer.new()
	anim_player.name = "AnimationPlayer"
	body.add_child(anim_player)
	anim_player.add_animation_library(&"", _get_library())
	play(animation)

## Plays an animation by name (blended over 0.3 s).
func play(anim_name: StringName) -> void:
	animation = anim_name
	if anim_player and anim_player.has_animation(anim_name):
		anim_player.play(anim_name, 0.3)

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
	if "hair" in material_name and hair_tint != Color.WHITE:
		var hair := material.duplicate() as StandardMaterial3D
		hair.albedo_color = hair.albedo_color * hair_tint
		return hair
	if "peasant" in material_name and (outfit_texture or outfit_tint != Color.WHITE):
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
		source.free()
	return _library
