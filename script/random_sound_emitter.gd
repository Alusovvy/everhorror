extends AudioStreamPlayer3D
class_name RandomSoundEmitter

## Positional one-shot that repeats with a random pause and a slight random pitch.
## For drips, creaks, distant rumbles and other occasional ambient sounds.

@export var min_interval: float = 4.0
@export var max_interval: float = 10.0
@export_range(0.0, 0.5) var pitch_variation: float = 0.1

var _time_left: float

func _ready() -> void:
	# Start somewhere inside the first interval, so emitters don't fire in sync.
	_time_left = randf_range(0.0, max_interval)

func _process(delta: float) -> void:
	_time_left -= delta
	if _time_left > 0.0:
		return
	pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	play()
	_time_left = randf_range(min_interval, max_interval)
