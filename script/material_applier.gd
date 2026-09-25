extends Node3D

## Applies `material` as material_override to every mesh below this node at startup.
## Used to re-skin instanced pack props (e.g. flat-coloured Kenney models) without editing them.

@export var material: Material

func _ready() -> void:
	_apply(self)

func _apply(node: Node) -> void:
	if node is MeshInstance3D:
		node.material_override = material
	for child in node.get_children():
		_apply(child)
