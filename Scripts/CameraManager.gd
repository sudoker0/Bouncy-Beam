extends Node2D

func zoom(mode):
	var speed = Global.persistentGameData.settings.cameraZoomSpeed * $Camera.zoom.x
	match mode:
		"in":
			print("Camera zoom in")
			$Camera.zoom += Vector2(-0.05 * speed, -0.05 * speed)
		"out":
			print("Camera zoom out")
			$Camera.zoom += Vector2(0.05 * speed, 0.05 * speed)
	$Camera.zoom.x = clamp($Camera.zoom.x, Global.persistentGameData.settings.cameraMinZoom, Global.persistentGameData.settings.cameraMaxZoom)
	$Camera.zoom.y = clamp($Camera.zoom.y, Global.persistentGameData.settings.cameraMinZoom, Global.persistentGameData.settings.cameraMaxZoom)

func _ready():
	pass

func _process(_delta):
	pass

var mousePrePos = Vector2(0, 0)
func _unhandled_input(event):
	#print("fdsafdasfdsafsda")
	# Camera movement
	if event is InputEventMouseMotion and Global.cameraIsMoving:
		var mousePos = get_viewport().get_mouse_position()
		var delta = mousePos - mousePrePos
		mousePrePos = mousePos
		$Camera.position -= delta * $Camera.zoom.x * Global.persistentGameData.settings.cameraMoveSpeed

	# Camera zooming using scroll wheel
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_WHEEL_UP:
				zoom("in")
			BUTTON_WHEEL_DOWN:
				zoom("out")

	# Handle camera zooming
	# if Input.is_action_pressed("zoom_in"):
	# 	zoom("in")
	# if Input.is_action_pressed("zoom_out"):
	# 	zoom("out")

	# If user hold the Ctrl key, enable movement
	if Input.is_action_just_pressed("start_camera_movement"):
		print("Begin movement")
		Global.enabledCameraMovement = true
	if Input.is_action_just_released("start_camera_movement"):
		print("End movement")
		Global.enabledCameraMovement = false

	# Handle camera moving
	if Global.enabledCameraMovement and Input.is_action_pressed("left_button"):
		print("Moving")
		Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		Global.cameraIsMoving = true
		mousePrePos = get_viewport().get_mouse_position()
	if Input.is_action_just_released("left_button"):
		print("End moving")
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		Global.cameraIsMoving = false
