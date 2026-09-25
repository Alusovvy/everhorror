extends RefCounted
class_name FieldSchedule

## Who the hero meets out in the tunnels (docs_v2/systemy/npc.md): miners at work in their
## places during the day, and the Drudzy from Exitium after their expedition has arrived.
## Returns {"place", "marker", "pose"} like CampSchedule, or {} when the NPC isn't here.
## Only asked about NPCs whom CampSchedule doesn't keep in the camp.
## Drudzy encounters are rolled by the StoryDirector on arrival and kept in the flags
## "encounter_place" and "encounter_npcs" until the hero leaves.

## The Exitium expedition met on day 3 (plus Sabina before she joins the camp).
const DRUDZY: Array[StringName] = [&"ottokar", &"sabina", &"hieronim", &"welf"]
## Poses for NPCs met in the tunnels: mages hold their staffs upright (Idle_Torch raises the
## left fist), Welf has no staff and stands ready to cast.
const STAFF_POSE := &"Idle_Torch"
const CAST_POSE := &"Spell_Simple_Idle"

static func placement(npc_id: StringName, place_id: StringName) -> Dictionary:
	if place_id == &"oboz":
		return {}
	var met: Array = GameState.get_flag("encounter_npcs", [])
	if String(GameState.get_flag("encounter_place", "")) == String(place_id) and String(npc_id) in met:
		var slot := met.find(String(npc_id)) + 1
		return _at(place_id, slot, _encounter_pose(npc_id))
	if GameState.part_of_day() != "dzien" or GameState.npc_status(npc_id) in ["gone", "dead"]:
		return {}
	match npc_id:
		&"wszebor":
			if place_id == &"wyrobisko":
				return _work(place_id)
		&"nasir":
			if place_id == &"pompy" and CampSchedule.nasir_at_pumps() and not GameState.has_fever(&"nasir"):
				return _work(place_id)
	return {}

## A miner at work: marker "<Place>Work", kneeling at the rock or the pump.
static func _work(place_id: StringName) -> Dictionary:
	return {"place": "teren", "marker": "%sWork" % String(place_id).capitalize(), "pose": &"Fixing_Kneeling"}

static func _encounter_pose(npc_id: StringName) -> StringName:
	match npc_id:
		&"welf":
			return &"Crouch_Idle" if GameState.has_flag("welf_wounded") and not GameState.has_flag("welf_helped") else CAST_POSE
		&"hieronim":
			return &"Crouch_Idle" if GameState.has_flag("drudzy_met") else STAFF_POSE
	return STAFF_POSE

## Marker "<Place>Spot<n>", e.g. "GrotaSpot1", in Locations/Markers or Camp/Markers.
static func _at(place_id: StringName, slot: int, pose: StringName) -> Dictionary:
	return {"place": "teren", "marker": "%sSpot%d" % [String(place_id).capitalize(), slot], "pose": pose}
