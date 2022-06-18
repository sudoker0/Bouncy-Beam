extends "res://Scripts/DragManager.gd"

signal editBlock

onready var itemList = get_node("../UI/CanvasLayer/Window/Blocks/Content/TabContainer/Blocks/ItemList")
func _ready():
	Global.selectedBlockToEdit = Vector2(-1, -1)
	Global.isEditingProperty = false
	emit_signal("editBlock")

func _process(delta):
	._process(delta)

	if Input.is_action_just_pressed("right_button"):
		var editBlock = Global.EditBlock.instance()
		editBlock.add_to_group("EditBlock")
		var blockPos = (get_global_mouse_position() / Global.blockSize[0]).round()

		if Global.beginSimulation:
			return

		if Input.is_action_pressed("start_camera_movement") and not Global.isEditingProperty:
			Global.playSoundEffect("putdown")
			get_node("../GridManager").DeleteBlock(blockPos.x, blockPos.y)
		else:
			var selectedBlockInList = itemList.get_selected_items()

			if not (blockPos.x > 0 and blockPos.x < Global.gridWidth - 1 and blockPos.y > 0 and blockPos.y < Global.gridHeight - 1):
				return

			var currentBlock = Global.blockGrid[blockPos.x][blockPos.y]
			if currentBlock == null and selectedBlockInList.size() > 0 and not Global.isEditingProperty:
				Global.playSoundEffect("putdown")
				get_node("../GridManager").CreateBlock(Global.BlockType[itemList.get_item_metadata(selectedBlockInList[0])], blockPos.x, blockPos.y, Global.makeBlockDraggable)

			elif currentBlock != null:
				Global.playSoundEffect("pressedButton")
				Global.selectedBlockToEdit = blockPos
				#if Global.selectedBlockToEdit == Vector2(-1, -1):
				#	Global.selectedBlockToEdit = blockPos
				Global.blockGrid[Global.selectedBlockToEdit.x][Global.selectedBlockToEdit.y].get_tree().call_group("EditBlock", "queue_free")
				currentBlock.add_child(editBlock)
				editBlock.get_node("Animation").play("flashing")

				if Global.isEditingProperty and Global.selectedBlockToEdit == blockPos:
					Global.isEditingProperty = false
					currentBlock.get_tree().call_group("EditBlock", "queue_free")
				else:
					Global.isEditingProperty = true

				#Global.selectedBlockToEdit = blockPos
				emit_signal("editBlock")
