extends Node2D

export var selectedIndex = 0
onready var mapDialog = $UI/CanvasLayer/Window/Map
onready var blockDialog = $UI/CanvasLayer/Window/Blocks
onready var itemList = blockDialog.get_node("Content/TabContainer/Blocks/ItemList")
onready var propertiesTab = $UI/CanvasLayer/Window/Blocks/Content/TabContainer/Properties

onready var inspector = propertiesTab.get_node("Inspector")
onready var no_block = propertiesTab.get_node("NoBlockSelected")
onready var saveProperties = propertiesTab.get_node("SaveProperties")
var data_to_save
var propertyList = []

func _ready():
	Global.loadedFile = ""
	Global.gridWidth = 0
	Global.gridHeight = 0
	Global.isEditingProperty = false
	Global.beginSimulation = false
	no_block.visible = true
	inspector.visible = false
	saveProperties.visible = false
	var count = 0
	for i in Global.BlockType:
		if i in ["Empty", "Wall"]:
			continue
		# var texture = ImageTexture.new()
		# var image = Image.new()
		# image.load(Global.BlockType[i].block.get_root().get_node("Texture").texture)
		# texture.create_from_image(image)
		itemList.add_item(Global.BlockType[i].name, Global[Global.BlockType[i].texture])
		#itemList.add_item(Global.BlockType[i].name)
		itemList.set_item_metadata(count, i)
		count += 1
	itemList.select(0)

func _on_BackButton_button_down():
	Global.playSoundEffect("pressedButton")
	Global.isEditingProperty = false
	get_tree().change_scene(Global.intro)

func _on_Button_button_down():
	Global.receiverList = []
	Global.gateList = []
	$GridManager.MakeGameBoard(mapDialog.get_node("Content/VBoxContainer/Width").value, mapDialog.get_node("Content/VBoxContainer/Height").value)
	$GridManager.BuildWall()
	Global.isEditingProperty = false
	no_block.visible = true
	inspector.visible = false
	saveProperties.visible = false
	pass # Replace with function body.

func _on_Button3_button_down():
	var block_to_save = []
	for x in range(0, Global.gridWidth):
		for y in range(0, Global.gridHeight):
			var currentBlock = Global.blockGrid[x][y]
			if currentBlock == null or not is_instance_valid(currentBlock):
				continue
			if currentBlock.blockType.type in ["Empty", "Wall"]:
				continue
			block_to_save.append({
				"coords": {
					"x": x,
					"y": y
				},
				"draggable": currentBlock.draggable,
				"blockType": currentBlock.blockType.type,
				"externalData": currentBlock.externalData
			})
	data_to_save = {
		"level_name": mapDialog.get_node("Content/VBoxContainer/NameOfMap").text,
		"size": {
			"width": Global.gridWidth,
			"height": Global.gridHeight
		},
		"max_number_of_tries": mapDialog.get_node("Content/VBoxContainer/MaxNumberOfTries").value,
		"board": block_to_save,
	}
	if Global.loadedFile != "":
		var file = File.new()
		file.open(Global.loadedFile, File.WRITE)
		file.store_string(JSON.print(data_to_save, "" if mapDialog.get_node("Content/VBoxContainer/MinifyJSON").pressed else "    "))
		file.close()
	else:
		$UI/CanvasLayer/SaveFile.popup_centered()

func _on_ItemList_item_selected(index):
	selectedIndex = index

func _on_FileDialog_file_selected(path):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(JSON.print(data_to_save, "" if mapDialog.get_node("Content/VBoxContainer/MinifyJSON").pressed else "    "))
	file.close()
	if Global.loadedFile == "":
		Global.loadedFile = path

func _on_Button2_button_down():
	$UI/CanvasLayer/OpenFile.popup_centered()

func _on_OpenFile_file_selected(path):
	var file = File.new()
	if file.file_exists(path):
		file.open(path, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			Global.receiverList = []
			Global.gateList = []
			$GridManager.DrawMap(data)
			mapDialog.get_node("Content/VBoxContainer/Width").value = int(data.size.width)
			mapDialog.get_node("Content/VBoxContainer/Height").value = int(data.size.height)
			mapDialog.get_node("Content/VBoxContainer/NameOfMap").text = str(data.level_name)
			mapDialog.get_node("Content/VBoxContainer/MaxNumberOfTries").value = int(data.max_number_of_tries)
			Global.loadedFile = path
		else:
			$UI/CanvasLayer/InvalidFileDialog.popup_centered()
			printerr("Corrupted data!")
	else:
		$UI/CanvasLayer/InvalidFileDialog.popup_centered()
		printerr("No saved data!")

func _on_DragManager_editBlock():
	var selected = Global.selectedBlockToEdit
	if selected == Vector2(-1, -1):
		return
	var selectedBlock = Global.blockGrid[selected.x][selected.y]
	if selectedBlock == null or not is_instance_valid(selectedBlock):
		return

	var externalData = selectedBlock.externalData
	propertyList = []

	if not Global.isEditingProperty:
		no_block.visible = true
		inspector.visible = false
		saveProperties.visible = false
		return

	no_block.visible = false
	inspector.visible = true
	saveProperties.visible = true

	for n in inspector.get_children():
		if n.is_in_group("exclude_remove"):
			continue
		inspector.remove_child(n)
		n.queue_free()

	for i in externalData.keys():
		var property = HSplitContainer.new()
		var name = Label.new()
		var input
		var type = ""

		match typeof(externalData[i]):
			TYPE_STRING:
				print("string: ", i)
				type = "string"
				input = LineEdit.new()
				input.text = str(externalData[i])
			TYPE_INT, TYPE_REAL:
				print("int: ", i)
				type = "int"
				input = SpinBox.new()
				input.min_value = -2147483648
				input.max_value = 2147483647
				input.value = int(externalData[i])
			TYPE_BOOL:
				print("bool: ", i)
				type = "bool"
				input = CheckBox.new()
				input.pressed = bool(externalData[i])
			TYPE_DICTIONARY:
				print("dict: ", i)
				type = "dict"
				input = OptionButton.new()
				for j in externalData[i].data:
					input.add_item(j)
				input.select(externalData[i].selected)
		name.text = i
		name.clip_text = true
		property.add_child(name)
		property.add_child(input)
		property.split_offset = 300
		property.dragger_visibility = SplitContainer.DRAGGER_HIDDEN
		inspector.add_child(property)
		propertyList.append({
			"name": i,
			"field": input,
			"type": type
		})
	$UI/CanvasLayer/Window/Blocks/Content/TabContainer/Properties/Inspector/Draggable/CheckBox.pressed = selectedBlock.draggable

func _on_SaveProperties_button_down():
	var selected = Global.selectedBlockToEdit
	var data
	for i in propertyList:
		match i.type:
			"string":
				print("string: ", i)
				data = str(i.field.text)
			"int":
				print("int: ", i)
				data = int(i.field.value)
			"bool":
				print("bool: ", i)
				data = bool(i.field.pressed)
			"dict":
				print("dict: ", i)
				data = Global.blockGrid[selected.x][selected.y].externalData[i.name]
				data.selected = int(i.field.selected)

		Global.blockGrid[selected.x][selected.y].externalData[i.name] = data
	Global.blockGrid[selected.x][selected.y].draggable = $UI/CanvasLayer/Window/Blocks/Content/TabContainer/Properties/Inspector/Draggable/CheckBox.pressed

func _on_PlayButton_button_down():
	Global.beginSimulation = false if Global.beginSimulation else true
	if Global.beginSimulation:
		Global.playSoundEffect("laserShooting")
	$UI/CanvasLayer/PlayButton.texture_normal = Global.stopButton if Global.beginSimulation else Global.playButton

func _process(_delta):
	if len(Global.receiverList) <= 0:
		$UI/CanvasLayer/PlayButton.disabled = true
		return
	else:
		$UI/CanvasLayer/PlayButton.disabled = false

	if not Global.beginSimulation or len(Global.receiverList) <= 0:
		$UI/CanvasLayer/DidYouWin.text = "Did you win? No"
		return
	var didIWin = []
	for i in Global.receiverList:
		didIWin.append(i.hit)
	print(didIWin)
	$UI/CanvasLayer/DidYouWin.text = "Did you win? %s" % ("No" if didIWin.has(false) else "Yes")

func _on_CheckBox_button_up():
	Global.makeBlockDraggable = $UI/CanvasLayer/Window/Blocks/Content/TabContainer/Blocks/MakeBlockDraggable/CheckBox.pressed
