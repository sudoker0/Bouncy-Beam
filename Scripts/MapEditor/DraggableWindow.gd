extends Control
signal move_to_top

var drag_position = null
var viewport_size = null
var content_size = 0

func _ready():
	content_size = $Content.rect_size.y

func _process(_delta):
	viewport_size = get_viewport_rect().size

func _on_Close_button_down():
	var isClosed = !$Titlebar/Close.flip_v
	$Content.visible = false if isClosed else true
	$Titlebar/Close.flip_v = true if isClosed else false
	rect_size.y += content_size * (-1 if isClosed else 1)

func _on_Titlebar_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			drag_position = get_global_mouse_position() - rect_global_position
			emit_signal("move_to_top", self)
		else:
			drag_position = null

	if event is InputEventMouseMotion and drag_position:
		rect_global_position = get_global_mouse_position() - drag_position
		rect_global_position.x = clamp(rect_global_position.x, 0, viewport_size.x - rect_size.x)
		rect_global_position.y = clamp(rect_global_position.y, 0, viewport_size.y - rect_size.y)
