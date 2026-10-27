extends Resource
class_name ItemData

## An item the player can carry (spec 03_mechaniki/ekwipunek.md, EKW-1). How many the player has lives in
## GameState.items; this resource only holds the definition. Medicine and drink can be used by
## the player (inventory [I]) or given to an NPC in a dialogue (GameState.give_to_npc).

enum Category { TOOL, MEDICINE, SUPPLY, QUEST, VALUABLE }

@export var id: StringName
@export var display_name: String
## Accusative, for messages and dialogue options ("Dajesz mu nalewkę").
@export var name_accusative: String
@export_multiline var description: String
@export var category: Category = Category.SUPPLY

@export_group("Use")
## Health restored (the player's or an NPC's).
@export var heal: int = 0
## Sanity restored.
@export var sanity: int = 0
## Cures the fever.
@export var cures_fever: bool = false
## Used up when used or given away.
@export var consumable: bool = true
## Hours it takes to use it (dressing a wound, a quiet moment with a candle).
@export var use_hours: float = 0.0
## What the hero does when using it, shown after using.
@export_multiline var use_text: String

## True if the player can use it on themselves from the inventory.
func is_usable() -> bool:
	return heal > 0 or sanity > 0 or cures_fever

func category_name() -> String:
	match category:
		Category.TOOL:
			return "narzędzie"
		Category.MEDICINE:
			return "lek"
		Category.QUEST:
			return "sprawa do załatwienia"
		Category.VALUABLE:
			return "cenne"
	return "zapasy"
