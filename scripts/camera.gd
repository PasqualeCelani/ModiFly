extends Camera3D


@export var zoom_speed = 2.0
@export var min_fov = 30.0
@export var default_fov = 75.0
@export var max_fov = 90.0

enum CameraState {
	IDLE_MOVEMENT,
	ZOOM_IN,
	ZOOM_OUT,
	Off
}

@onready var current_state = CameraState.Off

func _process(delta):
	var gesture_node = get_node("/root/MainScene/GestureClient")
	var voice_command = gesture_node.voice_command 
	
	#State transaction logic
	match current_state:
		CameraState.Off:
			if voice_command == "open":
				current_state = CameraState.IDLE_MOVEMENT
		CameraState.IDLE_MOVEMENT:
			if voice_command == "zoom in":
				current_state = CameraState.ZOOM_IN
			if voice_command == "zoom out":
				current_state = CameraState.ZOOM_OUT
			if voice_command == "shut down":
				current_state = CameraState.Off
		CameraState.ZOOM_IN:
			if voice_command == "shut down":
				current_state = CameraState.Off
			if voice_command == "stop":
				current_state = CameraState.IDLE_MOVEMENT
			if voice_command == "zoom out":
				current_state = CameraState.ZOOM_OUT
		CameraState.ZOOM_OUT:
			if voice_command == "shut down":
				current_state = CameraState.Off
			if voice_command == "stop":
				current_state = CameraState.IDLE_MOVEMENT
			if voice_command == "zoom in":
				current_state = CameraState.ZOOM_IN
			
	
	if current_state != CameraState.Off:
		if current_state == CameraState.ZOOM_IN:
			fov = max(min_fov, fov - zoom_speed * delta)
		elif current_state == CameraState.ZOOM_OUT:
			fov = min(max_fov, fov + zoom_speed * delta)
