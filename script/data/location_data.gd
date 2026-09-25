extends Resource
class_name LocationData

## A place an expedition can reach (docs_v2/systemy/eksploracja_kopalni.md). Places form a graph
## with the camp ("oboz") in the middle; `links` give travel hours to the neighbours. The map
## table sends the player to any known place along the shortest path, [M] in the field goes to a
## neighbour or back to the camp (Expeditions).

@export var id: StringName
@export var display_name: String
## Shown on the map while the place is still locked, e.g. "Znak zapytania".
@export var unknown_name: String
## Short hint where it is, e.g. "wschód, w dół".
@export var direction: String
@export_multiline var text: String
## Neighbour id → hours of travel ("oboz" is the camp).
@export var links: Dictionary = {}
## All must hold to go there: "flag:<name>" or "item:<id>".
@export var requires: PackedStringArray = []
## Requirement → why it doesn't hold, shown on the map.
@export var locked: Dictionary = {}
## Marker the player arrives at (Camp/Markers or Locations/Markers).
@export var entry: String
## Blue-iron nodes found here; marking one sets the flag "vein_<id>".
@export var veins: PackedStringArray = []
## Distance from the camp in steps (1 = next to it); deeper places are darker on the map.
@export var depth: int = 1
## Where it is drawn on the map (0..1 of the drawing).
@export var map_pos: Vector2 = Vector2(0.5, 0.5)
## Sanity the hero loses on the first visit (bones, whispers, the dark).
@export var dread: int = 0
## Said on the first arrival (one line, the hero's impression).
@export var arrival_text: String
