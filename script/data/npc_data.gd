extends Resource
class_name NpcData

## An NPC card (GDD §5 / docs_v2/szablony/npc.md). Runtime values (current sanity,
## reputation…) live in GameState; this resource only holds the definition.

enum Faction { DRUDZY, EKSPEDYCJA, INNA }

@export var id: StringName
## Full name shown in the UI, e.g. "Mirosław z Głuszy".
@export var display_name: String
## Name used as the speaker in .dialogue files, e.g. "Mirosław".
@export var dialogue_name: String
## Instrumental case for prompts ("Porozmawiaj z Mirosławem").
@export var display_name_instrumental: String
@export var faction: Faction = Faction.EKSPEDYCJA
@export var role: String
@export var max_sanity: int = 100
@export var start_sanity: int = 100
@export var max_health: int = 100
@export var start_reputation: int = 0
@export_multiline var history: String
@export_multiline var sanity_zero_effect: String
## CharacterModel scene used in the world and in the VN portrait.
@export var model: PackedScene
@export var dialogue: DialogueResource
## Height of the eyes in the model, used to frame the VN portrait.
@export var portrait_eye_height: float = 1.6
