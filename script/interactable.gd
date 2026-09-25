extends Area3D
class_name Interactable

## Something the player can aim at and use with the interact key.
## Add it as a child of a prop. If it has no CollisionShape3D child, a box
## fitted to the target's meshes is generated at runtime.
##
## Actions:
## - DESCRIBE: the HUD shows `description` (optionally with effects, e.g. a found note).
## - DIALOGUE: opens the VN screen with `dialogue` / `dialogue_cue`.
## - USE: emits `used`; the scene decides what happens (map table, bed, exits…).
## Effects (flag, note, item, quest entry) are applied every time it is used; they are
## idempotent except for items, so item pickups should use `remove_after_use`.

signal used(interactable: Interactable)

enum Action { DESCRIBE, DIALOGUE, USE }

const INTERACTABLE_LAYER := 2
const HIGHLIGHT_SHADER := preload("res://shader/interact_highlight.gdshader")

static var _highlight_material: ShaderMaterial

## Name shown in the prompt and as the description title, e.g. "Beczka".
@export var display_name: String = ""
## Text shown after pressing the interact key (DESCRIBE).
@export_multiline var description: String = ""
@export var action: Action = Action.DESCRIBE
## Prompt after "[E]". Empty = display_name.
@export var prompt_text: String = ""
## Hours this action costs (0 = free). Shown in the prompt.
@export var time_cost_hours: float = 0.0
## Shown in the "time passed" message, e.g. "Rozmowa z Mirosławem".
@export var time_reason: String = ""

@export_group("Dialogue")
@export var dialogue: DialogueResource
@export var dialogue_cue: String = "start"
## NPC that plays its talking animation during the dialogue.
@export var speaker_npc: StringName = &""

@export_group("Effects")
@export var on_use_flag: String = ""
@export var on_use_note: StringName = &""
@export var on_use_item: String = ""
@export var on_use_quest: StringName = &""
@export var on_use_quest_entry: String = ""
## Log the quest entry only if the quest was already started.
@export var quest_only_if_active: bool = false
## The parent object disappears after use (a pickup). Remembered via `on_use_flag`.
@export var remove_after_use: bool = false

@export_group("Availability")
## Only usable (and visible) when this flag is set.
@export var required_flag: String = ""
## Hidden, together with its parent, when this flag is set.
@export var hidden_by_flag: String = ""

@export_group("Shape")
## Node whose meshes glow when aimed at. Defaults to the parent.
@export var highlight_target: Node3D
## Also block the player with a solid box of the same size (props from packs have no collision).
@export var solid: bool = true
## Extra margin around the generated box so the ray hits this area before the prop's own body.
@export var padding: float = 0.05

var _meshes: Array[MeshInstance3D] = []
var _previous_overlays: Dictionary = {}
var _solid_body: StaticBody3D
var _active := true
## Switched off by code (e.g. an NPC who is away), on top of the flag conditions.
var _enabled := true

func _ready() -> void:
	collision_layer = 1 << (INTERACTABLE_LAYER - 1)
	collision_mask = 0
	monitoring = false
	if highlight_target == null:
		highlight_target = get_parent() as Node3D
	_collect_meshes(highlight_target)
	if not _has_shape():
		_build_shapes()
	GameState.state_replaced.connect(refresh_from_state)
	GameState.flags_changed.connect(refresh_from_state)
	refresh_from_state()

## Prompt shown by the HUD, e.g. "Porozmawiaj z Mirosławem · 1 h".
func get_prompt() -> String:
	var text := prompt_text if prompt_text != "" else display_name
	if time_cost_hours > 0.0:
		text += " · %s h" % _format_hours(time_cost_hours)
		if not GameState.can_afford(time_cost_hours):
			text += "  (za późno)"
	return text

## Called by the player when the interact key is pressed on this object.
func interact() -> void:
	if not _active:
		return
	if time_cost_hours > 0.0 and not GameState.can_afford(time_cost_hours):
		GameState.message.emit("Już za późno. Pora odpocząć.")
		return
	GameState.advance_time(time_cost_hours, time_reason if time_reason != "" else display_name)
	_apply_effects()
	match action:
		Action.DIALOGUE:
			VN.start(dialogue, dialogue_cue, speaker_npc)
		Action.USE:
			used.emit(self)
	if remove_after_use:
		_set_active(false)

func is_active() -> bool:
	return _active

func set_enabled(on: bool) -> void:
	_enabled = on
	refresh_from_state()

func refresh_from_state() -> void:
	var active := _enabled
	if required_flag != "" and not GameState.has_flag(required_flag):
		active = false
	if hidden_by_flag != "" and GameState.has_flag(hidden_by_flag):
		active = false
	if remove_after_use and on_use_flag != "" and GameState.has_flag(on_use_flag):
		active = false
	_set_active(active)

func set_highlighted(on: bool) -> void:
	if _highlight_material == null:
		_highlight_material = ShaderMaterial.new()
		_highlight_material.shader = HIGHLIGHT_SHADER
	# Keep any overlay the mesh already had (e.g. glowing veins) and restore it afterwards.
	for mesh in _meshes:
		if not is_instance_valid(mesh):
			continue
		if on:
			if mesh.material_overlay != _highlight_material:
				_previous_overlays[mesh] = mesh.material_overlay
			mesh.material_overlay = _highlight_material
		else:
			mesh.material_overlay = _previous_overlays.get(mesh)

func _apply_effects() -> void:
	if on_use_flag != "":
		GameState.set_flag(on_use_flag)
	if on_use_note != &"":
		GameState.add_note(on_use_note)
	if on_use_item != "":
		GameState.give_item(on_use_item)
	if on_use_quest != &"" and on_use_quest_entry != "":
		if not quest_only_if_active or GameState.quest_state(on_use_quest) == "active":
			GameState.quest_log(on_use_quest, on_use_quest_entry)

func _set_active(active: bool) -> void:
	if active == _active:
		return
	_active = active
	collision_layer = (1 << (INTERACTABLE_LAYER - 1)) if active else 0
	var parent := get_parent() as Node3D
	if parent and highlight_target == parent:
		parent.visible = active
	if _solid_body:
		_solid_body.process_mode = Node.PROCESS_MODE_INHERIT if active else Node.PROCESS_MODE_DISABLED
		for child in _solid_body.get_children():
			if child is CollisionShape3D:
				child.disabled = not active
	if not active:
		set_highlighted(false)

func _format_hours(hours: float) -> String:
	return str(int(hours)) if is_equal_approx(hours, floor(hours)) else "%.1f" % hours

func _collect_meshes(node: Node) -> void:
	if node is MeshInstance3D:
		_meshes.append(node)
	for child in node.get_children():
		_collect_meshes(child)

func _has_shape() -> bool:
	for child in get_children():
		if child is CollisionShape3D:
			return true
	return false

func _build_shapes() -> void:
	var bounds := _local_bounds()
	if bounds.size == Vector3.ZERO:
		push_warning("Interactable '%s' has no meshes to fit a shape to." % name)
		return
	_add_box(self, bounds.grow(padding))
	if solid:
		_solid_body = StaticBody3D.new()
		_solid_body.name = "SolidBody"
		add_child(_solid_body)
		_add_box(_solid_body, bounds)

func _add_box(parent: Node, bounds: AABB) -> void:
	var box := BoxShape3D.new()
	box.size = bounds.size
	var shape := CollisionShape3D.new()
	shape.shape = box
	shape.position = bounds.get_center()
	parent.add_child(shape)

## Merged AABB of all target meshes, in this node's local space.
func _local_bounds() -> AABB:
	var inverse := global_transform.affine_inverse()
	var bounds := AABB()
	var first := true
	for mesh in _meshes:
		if mesh.mesh == null:
			continue
		var aabb := inverse * mesh.global_transform * mesh.mesh.get_aabb()
		bounds = aabb if first else bounds.merge(aabb)
		first = false
	return bounds
