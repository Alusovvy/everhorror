extends Resource
class_name QuestData

## A quest in the notebook. Entries are revealed one by one with GameState.quest_log().

@export var id: StringName
@export var title: String
## Who gave the quest (shown under the title), e.g. "Mirosław z Głuszy".
@export var giver: String
## Entry id → text written in the hero's voice.
@export var entries: Dictionary = {}
