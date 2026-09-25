extends Node3D
class_name Npc

## An NPC standing (or sitting) in the world: model from its NpcData card, a solid body and a
## "talk" interactable (costs 1 h, opens the VN dialogue). The StoryDirector decides where it
## stands and which pose it uses on a given day.

## How long a conversation takes (GDD: "Rozmowa z NPC przesuwa czas").
const TALK_HOURS := 1.0

@export var data: NpcData
## Idle animation: Idle, Sitting_Idle, Crouch_Idle…
@export var pose: StringName = &"Idle"

var model: CharacterModel
var talk: Interactable

func _ready() -> void:
	model = data.model.instantiate() as CharacterModel
	model.name = "Model"
	model.animation = pose
	add_child(model)

	var body := StaticBody3D.new()
	body.name = "Body"
	var body_shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.32
	capsule.height = 1.7
	body_shape.shape = capsule
	body_shape.position = Vector3(0, 0.85, 0)
	body.add_child(body_shape)
	add_child(body)

	talk = Interactable.new()
	talk.name = "Talk"
	talk.display_name = data.display_name
	talk.action = Interactable.Action.DIALOGUE
	talk.prompt_text = "Porozmawiaj z %s" % data.display_name_instrumental
	talk.time_cost_hours = TALK_HOURS
	talk.time_reason = "Rozmowa z %s" % data.display_name_instrumental
	talk.dialogue = data.dialogue
	talk.speaker_npc = data.id
	talk.highlight_target = model
	talk.solid = false
	var talk_shape := CollisionShape3D.new()
	var talk_capsule := CapsuleShape3D.new()
	talk_capsule.radius = 0.45
	talk_capsule.height = 1.9
	talk_shape.shape = talk_capsule
	talk_shape.position = Vector3(0, 0.95, 0)
	talk.add_child(talk_shape)
	add_child(talk)

	VN.started.connect(_on_dialogue_started)
	VN.finished.connect(_on_dialogue_finished)

## Moves the NPC to a marker (position and facing) and sets its idle pose.
func place(marker: Node3D, new_pose: StringName) -> void:
	global_transform = marker.global_transform
	pose = new_pose
	if model:
		model.play(pose)

func _on_dialogue_started(npc_id: StringName) -> void:
	if npc_id == data.id:
		model.play(_talking_pose())

func _on_dialogue_finished(npc_id: StringName) -> void:
	if npc_id == data.id:
		model.play(pose)

func _talking_pose() -> StringName:
	match pose:
		&"Sitting_Idle":
			return &"Sitting_Talking"
		&"Idle":
			return &"Idle_Talking"
	return pose
