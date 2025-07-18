extends CharacterBody3D

@export var speed = 20
@export var vertical_speed: float = 2.0
@export var rotation_speed: float = 30.0 

var target_velocity = Vector3.ZERO

func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	var gesture_node = get_node("/root/MainScene/GestureClient")
	var command = gesture_node.current_command
	
	if command["left"] == "right":
		direction.x += 1
	if command["left"]  == "left":
		direction.x -= 1
	if command["left"]  == "backward":
		direction.z += 1
	if command["left"]  == "forward":
		direction.z -= 1
		
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		direction = global_transform.basis * direction
		
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	if command["left"]  == "up":
		target_velocity.y = vertical_speed
	elif  command["left"]  == "down":
		target_velocity.y = -vertical_speed
	else:
		target_velocity.y = 0
		
	if command["right"]  == "rotate_right":
		rotation_degrees.y -= rotation_speed * delta
	elif command["right"]  == "rotate_left":
		rotation_degrees.y += rotation_speed * delta
	
	velocity = target_velocity
	move_and_slide()
