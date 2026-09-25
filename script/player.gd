extends CharacterBody3D
class_name Player

@export var mouse_sensitivity: float = 0.001;
@onready var head: Node3D = $Head
@onready var eye_camera: Camera3D = $Head/EyeCamera
@onready var player_walking_sound: AudioStreamPlayer3D = $PlayerWalkingSound

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var old_pos:Vector3 = Vector3(0,0,0)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (eye_camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		
	move_and_slide()
	var is_moving := Vector2(velocity.x, velocity.z).length() > 0.1
	
	if is_moving:
		if not player_walking_sound.playing:
			player_walking_sound.play()
			print("Playing")
	else:
		print("Stopping playing")
		player_walking_sound.stop()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var relative = event.relative * mouse_sensitivity
		head.rotate_y(-relative.x)
		eye_camera.rotate_x(-relative.y)
		eye_camera.rotation.x = clamp(eye_camera.rotation.x, deg_to_rad(-40), deg_to_rad(40))
