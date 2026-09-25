extends CharacterBody3D
class_name Player

## Emitted when the object under the crosshair changes (null when nothing is aimed at).
signal focus_changed(target: Interactable)
## Emitted when the player presses the interact action while aiming at an object.
signal interacted(target: Interactable)

@onready var head: Node3D = $Head
@onready var eye_camera: Camera3D = $Head/EyeCamera
@onready var interact_ray: RayCast3D = $Head/EyeCamera/InteractRay
@onready var player_walking_sound: AudioStreamPlayer3D = $PlayerWalkingSound

const SPEED = 5.0
## Camera pitch limits in degrees.
const MAX_LOOK_UP = 40.0
const MAX_LOOK_DOWN = 70.0

var focused: Interactable

func _ready() -> void:
	interact_ray.add_exception(self)
	add_to_group(SaveManager.PERSIST_GROUP)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# No jump: a horror game without combat has no business letting the player
	# hop over ledges, ropes and water (team decision, 2026-09-25).

	# Get the input direction and handle the movement/deceleration.
	# Head only yaws, so moving forward keeps full speed regardless of camera pitch.
	var input_dir := Vector2.ZERO
	if not GameState.is_modal():
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	_update_walking_sound()
	_update_focus()

func _update_walking_sound() -> void:
	var is_moving := is_on_floor() and Vector2(velocity.x, velocity.z).length() > 0.1
	if is_moving and not player_walking_sound.playing:
		player_walking_sound.play()
	elif not is_moving and player_walking_sound.playing:
		player_walking_sound.stop()

func _update_focus() -> void:
	var target := interact_ray.get_collider() as Interactable
	if GameState.is_modal() or (target and not target.is_active()):
		target = null
	if target == focused:
		return
	if is_instance_valid(focused):
		focused.set_highlighted(false)
	focused = target
	if focused:
		focused.set_highlighted(true)
	focus_changed.emit(focused)

func _unhandled_input(event: InputEvent) -> void:
	if GameState.is_modal():
		return
	if event is InputEventMouseMotion:
		var relative = event.relative * Settings.mouse_sensitivity
		head.rotate_y(-relative.x)
		eye_camera.rotate_x(-relative.y)
		eye_camera.rotation.x = clamp(eye_camera.rotation.x, deg_to_rad(-MAX_LOOK_DOWN), deg_to_rad(MAX_LOOK_UP))
	elif event.is_action_pressed("interact") and focused:
		# Locked (no crowbar, too late): say why and don't open the description.
		var blocked := focused.blocked_reason()
		if blocked != "":
			GameState.message.emit(blocked)
			return
		# The HUD reads the target first (a pickup disappears on use).
		interacted.emit(focused)
		focused.interact()

func save_state() -> Dictionary:
	return {
		"position": [global_position.x, global_position.y, global_position.z],
		"yaw": rotation.y,
		"head_yaw": head.rotation.y,
		"pitch": eye_camera.rotation.x,
	}

func load_state(data: Dictionary) -> void:
	var pos: Array = data.get("position", [])
	if pos.size() == 3:
		global_position = Vector3(pos[0], pos[1], pos[2])
	rotation.y = data.get("yaw", rotation.y)
	head.rotation.y = data.get("head_yaw", head.rotation.y)
	eye_camera.rotation.x = data.get("pitch", eye_camera.rotation.x)
	velocity = Vector3.ZERO
