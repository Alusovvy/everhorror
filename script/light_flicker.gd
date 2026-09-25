extends Light3D
class_name LightFlicker

## Animates light energy: FLICKER for flames (noise), PULSE for slow glows (sine).

enum Mode { FLICKER, PULSE }

@export var mode: Mode = Mode.FLICKER
## Fraction of the base energy that the animation can add or remove.
@export_range(0.0, 1.0) var strength: float = 0.18
@export var speed: float = 6.0
## When false, meshes of the parent (the lamp housing) don't cast shadows from any light,
## so a light placed inside a lantern isn't blocked by its own cage.
@export var housing_casts_shadow: bool = true

var _base_energy: float
var _noise := FastNoiseLite.new()
var _time: float

func _ready() -> void:
	_base_energy = light_energy
	_noise.seed = randi()
	_noise.frequency = 1.0
	_time = randf() * 100.0
	if not housing_casts_shadow and get_parent():
		_disable_shadows(get_parent())

func _process(delta: float) -> void:
	_time += delta * speed
	var t: float
	if mode == Mode.FLICKER:
		t = _noise.get_noise_1d(_time)
	else:
		t = sin(_time)
	light_energy = _base_energy * (1.0 + t * strength)

func _disable_shadows(node: Node) -> void:
	if node is GeometryInstance3D:
		node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for child in node.get_children():
		if child != self:
			_disable_shadows(child)
