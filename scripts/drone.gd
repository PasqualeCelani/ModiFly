extends CharacterBody3D

const GRAVITY = 9.8

@export var max_speed: float = 50.0
@export var vertical_speed: float = 5.0
@export var rotation_speed: float = 30.0

@export var acceleration: float = 10.0
@export var deceleration: float = 8.0
@export var vertical_acceleration: float = 5.0
@export var vertical_deceleration: float = 5.0
@export var speed_ramp_rate: float = 10.0  # How fast speed increases/decreases

@export var terminal_velocity: float = -100.0
@export var fall_drag: float = 0.2  # Lower = falls faster; higher = air resistance
var fall_velocity: float = 0.0


var current_speed: float = 0.0  # Incremental horizontal speed
var current_velocity = Vector3.ZERO
var target_direction = Vector3.ZERO

var animator

var isOpen = false

@onready var fps_camera = $FPSCamera
@onready var tps_camera = $ThirdPersonCamera


func _ready() -> void:
	animator = $"Sketchfab_Scene/AnimationPlayer"
	

func _input(event):
	if event.is_action_pressed("switch_camera"):
		if fps_camera.current:
			fps_camera.current = false
			tps_camera.current = true
		else:
			fps_camera.current = true
			tps_camera.current = false

func _physics_process(delta: float) -> void:
	var gesture_node = get_node("/root/MainScene/GestureClient")
	var command = gesture_node.current_command
	var voice_command = gesture_node.voice_command 
	
	if voice_command == "open": 
		isOpen = true
	elif voice_command == "shut down":
		isOpen = false
	
	if isOpen:
		animator.play("Vole stationnaire")
		
		if not $IdleStream.is_playing():
			$IdleStream.play()
		
		target_direction = Vector3.ZERO
		
		if command["left"] == "right":
			target_direction.x += 1
		if command["left"] == "left":
			target_direction.x -= 1
		if command["left"] == "backward":
			target_direction.z += 1
		if command["left"] == "forward":
			target_direction.z -= 1

		var input_active = target_direction != Vector3.ZERO
		
		if input_active:
			target_direction = global_transform.basis * target_direction.normalized()
		
		if input_active:
			current_speed = move_toward(current_speed, max_speed, speed_ramp_rate * delta)
		else:
			current_speed = move_toward(current_speed, 0.0, speed_ramp_rate * delta)
		
		var desired_velocity = target_direction * current_speed
		current_velocity.x = move_toward(current_velocity.x, desired_velocity.x, acceleration * delta)
		current_velocity.z = move_toward(current_velocity.z, desired_velocity.z, acceleration * delta)
		
		if command["left"] == "up":
			current_velocity.y = move_toward(current_velocity.y, vertical_speed, vertical_acceleration * delta)
		elif command["left"] == "down":
			current_velocity.y = move_toward(current_velocity.y, -vertical_speed, vertical_acceleration * delta)
		else:
			current_velocity.y = move_toward(current_velocity.y, 0.0, vertical_deceleration * delta)
		
		if command["right"] == "rotate_right":
			rotation_degrees.y -= rotation_speed * delta
		elif command["right"] == "rotate_left":
			rotation_degrees.y += rotation_speed * delta
			

		velocity = current_velocity
		move_and_slide()
	else:
		$IdleStream.stop()
		animator.stop()
		target_direction = Vector3.ZERO
		current_speed = 0.0
		current_velocity = Vector3.ZERO

		if not is_on_floor():
			fall_velocity = move_toward(fall_velocity, terminal_velocity, GRAVITY * (1.0 - fall_drag) * delta)
		else:
			fall_velocity = 0.0

		velocity = Vector3(0, fall_velocity, 0)
		move_and_slide()

		
