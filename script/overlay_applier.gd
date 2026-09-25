extends Node3D

## Applies `overlay` as material_overlay to every mesh below this node at startup.
## Used to add effects (e.g. blue-iron veins) to instanced pack pieces without editing them.

@export var overlay: Material

func _ready() -> void:
	_apply(self)

func _apply(node: Node) -> void:
	if node is MeshInstance3D:
		node.material_overlay = overlay
	for child in node.get_children():
		_apply(child)
