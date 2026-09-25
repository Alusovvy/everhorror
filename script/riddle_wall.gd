extends Node3D
class_name RiddleWall

## The carved wall in the chapel (Kaplica). The riddle itself is a VN dialogue
## (dialogue/sciana.dialogue); when it is solved (flag "wall_open") the three stone rings turn
## to their answers and the slab below them sinks into the floor, opening the niche with the
## grandfather's letter and the crystal. Loading a save with the flag set opens it at once.
## Children: Pivot1..3/Ring1..3 (each ring turns around its own axis), Slab, NicheLight, Grind.

const OPEN_FLAG := "wall_open"
## Where each ring stops when the answer is set (degrees around its axis).
const RING_ANGLES: Array[float] = [150.0, -95.0, 215.0]
const SLAB_DROP := 0.9
const OPEN_SECONDS := 2.6
## Glyph glow while the wall waits, and after it has "fallen asleep" again.
const GLYPH_ENERGY := Vector2(2.2, 0.35)

var _open := false
var _slab_closed_y := 0.0

@onready var _rings: Array[Node3D] = [$Pivot1/Ring1, $Pivot2/Ring2, $Pivot3/Ring3]
@onready var _slab: Node3D = $Slab
@onready var _niche_light: Light3D = $NicheLight
@onready var _grind: AudioStreamPlayer3D = $Grind
@onready var _glyphs: ShaderMaterial = ($Glyphs as MeshInstance3D).material_override

func _ready() -> void:
	_slab_closed_y = _slab.position.y
	_niche_light.visible = false
	GameState.flags_changed.connect(_refresh.bind(false))
	GameState.state_replaced.connect(_refresh.bind(true))
	_refresh(true)

func _refresh(instant: bool) -> void:
	var should_open := GameState.has_flag(OPEN_FLAG)
	if should_open == _open:
		return
	_open = should_open
	_niche_light.visible = _open
	if not _open:
		for ring in _rings:
			ring.rotation.y = 0.0
		_slab.position.y = _slab_closed_y
		_glyphs.set_shader_parameter("energy", GLYPH_ENERGY.x)
		return
	if instant:
		for i in _rings.size():
			_rings[i].rotation.y = deg_to_rad(RING_ANGLES[i])
		_slab.position.y = _slab_closed_y - SLAB_DROP
		_glyphs.set_shader_parameter("energy", GLYPH_ENERGY.y)
		return
	# Solved in the VN: let the player close it first, so they see the wall move.
	if VN.is_active():
		await VN.finished
	_grind.play()
	var tween := create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	for i in _rings.size():
		tween.tween_property(_rings[i], "rotation:y", deg_to_rad(RING_ANGLES[i]), OPEN_SECONDS * 0.6)
	tween.tween_property(_slab, "position:y", _slab_closed_y - SLAB_DROP, OPEN_SECONDS * 0.5).set_delay(OPEN_SECONDS * 0.5)
	tween.tween_method(func(e: float): _glyphs.set_shader_parameter("energy", e), GLYPH_ENERGY.x, GLYPH_ENERGY.y, OPEN_SECONDS)
