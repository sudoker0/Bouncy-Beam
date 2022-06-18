extends Node2D

var draggedBlock = null;
var offsetPos;
var oldPos;

func CanDrag(x, y):
	if x >= 0 and y >= 0 and x < Global.gridWidth and y < Global.gridHeight:
		if not is_instance_valid(Global.blockGrid[x][y]) or Global.blockGrid[x][y] == null:
			return false
		return Global.blockGrid[x][y].draggable
	return false

func DragStart():
	if Global.enabledCameraMovement or Global.blockIsMoving or Global.beginSimulation or Global.isEditingProperty:
		return
	var currentBlockCoords = (get_node("../GridManager").get_global_mouse_position() / Global.blockSize[0]).round()
	var x = currentBlockCoords.x
	var y = currentBlockCoords.y
	if not CanDrag(x, y):
		return

	Global.playSoundEffect("pickup")

	var currentBlock = Global.blockGrid[x][y]

	oldPos = Vector2(x, y)
	draggedBlock = currentBlock
	offsetPos = currentBlockCoords * 64 - draggedBlock.get_global_mouse_position()
	offsetPos *= -1
	draggedBlock.z_index = Global.Z_PICKUP_BLOCK

	Global.blockIsMoving = true

func Draging():
	if Global.enabledCameraMovement or Global.beginSimulation:
		return
	if Global.blockIsMoving:
		draggedBlock.position = get_node("../GridManager").get_global_mouse_position() - offsetPos

		var blockHoverPos = (draggedBlock.position / 64).round()
		if blockHoverPos.x > 0 and blockHoverPos.x < Global.gridWidth - 1 and blockHoverPos.y > 0 and blockHoverPos.y < Global.gridHeight - 1:
			$SelectBlock.visible = true
			$SelectBlock.get_node("Texture").texture = Global.blockSelected if Global.blockGrid[blockHoverPos.x][blockHoverPos.y] == null or blockHoverPos == oldPos else Global.blockSelectedBad
			$SelectBlock.position = Vector2(blockHoverPos * 64)
		else:
			$SelectBlock.visible = false

func DragEnd():
	if Global.enabledCameraMovement or draggedBlock == null or not Global.blockIsMoving or Global.beginSimulation or Global.isEditingProperty:
		return
	Global.blockIsMoving = false

	Global.playSoundEffect("putdown")

	var pos = (draggedBlock.position / 64).round()
	if pos.x >= 0 and pos.x < Global.gridWidth and pos.y >= 0 and pos.y < Global.gridHeight:
		if Global.blockGrid[pos.x][pos.y] == null:
			draggedBlock.SetPosition(pos.x, pos.y)
			draggedBlock.position = pos * 64
		else:
			draggedBlock.position = oldPos * 64
	else:
		draggedBlock.position = oldPos * 64

	draggedBlock.z_index = Global.Z_NORMAL_BLOCK

func _ready():
	$SelectBlock.z_index = 5

func _process(_delta):
	pass

func _unhandled_input(event):

	if Input.is_action_just_pressed("left_button"):
		DragStart()
	if Input.is_action_just_released("left_button"):
		DragEnd()

	var blockPos = (get_global_mouse_position() / Global.blockSize[0]).round()
	if blockPos.x > 0 and blockPos.x < Global.gridWidth - 1 and blockPos.y > 0 and blockPos.y < Global.gridHeight - 1 and not Global.beginSimulation and not Global.blockIsMoving:

		var currentBlock = Global.blockGrid[blockPos.x][blockPos.y]
		if not currentBlock == null and is_instance_valid(currentBlock):

			$SelectBlock.visible = true
			$SelectBlock.get_node("Texture").texture = Global.blockSelectedGood if currentBlock.draggable else Global.blockSelectedBad
			$SelectBlock.position = Vector2(blockPos * 64)

		else:
			$SelectBlock.visible = false

	else:
		$SelectBlock.visible = false

	if event is InputEventMouseMotion:
		Draging()
