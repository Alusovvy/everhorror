extends CanvasLayer

## Visual-novel dialogue screen for Dialogue Manager: blurred game view behind, a live 3D
## portrait of the speaking NPC, the text panel and response options.
## Based on the addon's example balloon. Opened through the VN autoload.

## Actions that advance the dialogue (mouse click also works).
const NEXT_ACTIONS: Array[StringName] = [&"ui_accept", &"interact"]
const PORTRAIT_IDLE := &"Idle"
const PORTRAIT_TALK := &"Idle_Talking"

@onready var balloon: Control = %Balloon
@onready var character_label: Label = %CharacterLabel
@onready var dialogue_label: DialogueLabel = %DialogueLabel
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu
@onready var progress: Label = %Progress
@onready var clock_label: Label = %Clock
@onready var portrait_rect: TextureRect = %PortraitRect
@onready var portrait_viewport: SubViewport = %PortraitViewport
@onready var portrait_stage: Node3D = %PortraitStage
@onready var portrait_camera: Camera3D = %PortraitCamera

var dialogue_resource: DialogueResource
var temporary_game_states: Array = []
var is_waiting_for_input := false
## Scratch values for the conversation (Dialogue Manager "locals").
var locals: Dictionary = {}

var _portrait_npc: NpcData
var _portrait_model: CharacterModel

var dialogue_line: DialogueLine:
	set(value):
		if value:
			dialogue_line = value
			apply_dialogue_line()
		else:
			queue_free()
	get:
		return dialogue_line

func _ready() -> void:
	balloon.hide()
	responses_menu.hide_failed_responses = true
	responses_menu.response_selected.connect(_on_response_selected)
	balloon.gui_input.connect(_on_balloon_gui_input)
	portrait_rect.texture = portrait_viewport.get_texture()
	portrait_rect.hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	clock_label.text = GameState.clock_text()

func _process(_delta: float) -> void:
	if is_instance_valid(dialogue_line):
		progress.visible = not dialogue_label.is_typing and dialogue_line.responses.is_empty()

func _unhandled_input(_event: InputEvent) -> void:
	# Only the dialogue handles input while it is on screen.
	get_viewport().set_input_as_handled()

func start(resource: DialogueResource, cue: String) -> void:
	dialogue_resource = resource
	temporary_game_states = [self]
	is_waiting_for_input = false
	dialogue_line = await dialogue_resource.get_next_dialogue_line(cue, temporary_game_states)

func next(next_id: String) -> void:
	dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id, temporary_game_states)

func apply_dialogue_line() -> void:
	is_waiting_for_input = false
	balloon.focus_mode = Control.FOCUS_ALL
	balloon.grab_focus()

	var speaker := dialogue_line.character
	character_label.visible = not speaker.is_empty()
	character_label.text = speaker
	_update_portrait(speaker)
	clock_label.text = GameState.clock_text()

	# Narration (no speaker) is shown in a muted colour.
	if speaker.is_empty():
		dialogue_label.add_theme_color_override(&"default_color", Color(0.74, 0.7, 0.64))
	else:
		dialogue_label.add_theme_color_override(&"default_color", Color(0.93, 0.89, 0.83))
	dialogue_label.hide()
	dialogue_label.dialogue_line = dialogue_line
	responses_menu.hide()
	responses_menu.responses = dialogue_line.responses
	balloon.show()
	dialogue_label.show()

	if not dialogue_line.text.is_empty():
		_set_talking(not speaker.is_empty())
		dialogue_label.type_out()
		await dialogue_label.finished_typing
	_set_talking(false)

	if dialogue_line.responses.size() > 0:
		balloon.focus_mode = Control.FOCUS_NONE
		responses_menu.show()
	elif dialogue_line.time != "":
		var time: float = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
		await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)
	else:
		is_waiting_for_input = true
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()

#region Portrait

func _update_portrait(speaker: String) -> void:
	if speaker.is_empty():
		# Narration: keep the last portrait, dimmed.
		portrait_rect.modulate = Color(0.55, 0.55, 0.6, 1.0)
		return
	portrait_rect.modulate = Color.WHITE
	var npc := GameState.npc_by_dialogue_name(speaker)
	if npc == _portrait_npc:
		return
	_portrait_npc = npc
	if is_instance_valid(_portrait_model):
		_portrait_model.queue_free()
		_portrait_model = null
	if npc == null or npc.model == null:
		portrait_rect.hide()
		return
	_portrait_model = npc.model.instantiate() as CharacterModel
	_portrait_model.animation = PORTRAIT_IDLE
	portrait_stage.add_child(_portrait_model)
	# Upper-body framing, slightly from the side like a painted portrait.
	var eyes := npc.portrait_eye_height
	portrait_camera.position = Vector3(0.3, eyes + 0.02, 1.5)
	portrait_camera.look_at(Vector3(0.0, eyes - 0.1, 0.0))
	portrait_rect.show()

func _set_talking(on: bool) -> void:
	if is_instance_valid(_portrait_model):
		_portrait_model.play(PORTRAIT_TALK if on else PORTRAIT_IDLE)

#endregion

#region Input

func _on_balloon_gui_input(event: InputEvent) -> void:
	var clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
	var pressed_next := false
	for action in NEXT_ACTIONS:
		if event.is_action_pressed(action):
			pressed_next = true
	if dialogue_label.is_typing:
		if clicked or pressed_next or event.is_action_pressed(&"ui_cancel"):
			get_viewport().set_input_as_handled()
			dialogue_label.skip_typing()
		return
	if not is_waiting_for_input or dialogue_line.responses.size() > 0:
		return
	if clicked or pressed_next:
		get_viewport().set_input_as_handled()
		next(dialogue_line.next_id)

func _on_response_selected(response: DialogueResponse) -> void:
	next(response.next_id)

#endregion
