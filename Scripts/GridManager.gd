extends Node2D

func _ready():
	Global.blockGrid = [[]]
	Global.emptyBlockGrid = [[]]
	Global.receiverList = []
	Global.gateList = []

func CreateBlock(blockType, x, y, isDraggable = true):
	var block: Block = null
	match blockType:
		Global.BlockType.ColorFilter:
			block = Global.ColorFilterBlock.instance()
			block.get_node("Body").add_to_group("colorfilter")
		Global.BlockType.DeadZone:
			block = Global.DeadZoneBlock.instance()
		Global.BlockType.Gate:
			block = Global.GateBlock.instance()
			Global.gateList.append(block)
		Global.BlockType.GateSwitch:
			block = Global.GateSwitchBlock.instance()
			block.get_node("Switch").add_to_group("switch")
		Global.BlockType.Glass:
			block = Global.GlassBlock.instance()
			block.get_node("GlassPane").add_to_group("mirrors")
		Global.BlockType.Laser:
			block = Global.LaserBlock.instance()
		Global.BlockType.LightBlock:
			block = Global.LightBlockBlock.instance()
		Global.BlockType.Receiver:
			block = Global.ReceiverBlock.instance()
			Global.receiverList.append(block)
			block.get_node("Body").add_to_group("receiver")
		Global.BlockType.Wall:
			block = Global.WallBlock.instance()
			#block.add_to_group("outside")
		Global.BlockType.Empty:
			block = Global.EmptyBlock.instance()
			#block.add_to_group("outside", true)
			#block.add_to_group("empty", true)
	if block == null or Global.blockGrid[x][y] != null:
		printerr("GridManager.gd | Function CreateBlock: Block is null or already occupied")
		return
	block.SetPosition(x, y)
	block.draggable = isDraggable
	block.blockType = blockType
	block.position = Vector2(x * Global.blockSize[0], y * Global.blockSize[1])
	add_child(block)
	return block

func DeleteBlock(x, y):
	if Global.blockGrid[x][y] == null:
		printerr("GridManager.gd | Function DeleteBlock: Block is null")
		return false
	match Global.blockGrid[x][y].blockType:
		Global.BlockType.Receiver:
			Global.receiverList.erase(Global.blockGrid[x][y])
		Global.BlockType.Gate:
			Global.gateList.erase(Global.blockGrid[x][y])
	if Global.blockGrid[x][y].blockType in [Global.BlockType.Wall]:
		return
	remove_child(Global.blockGrid[x][y])
	Global.blockGrid[x][y] = null
	#CreateBlock(Global.BlockType.Empty, x, y, false, true)
	# var emptyBlock = Global.EmptyBlock.instance()
	# if Global.blockGrid[x][y].is_in_group("outside") or Global.blockGrid[x][y] == null:
	# 	return false
	# emptyBlock.add_to_group("empty", true)
	# emptyBlock.add_to_group("outside", true)
	# emptyBlock.draggable = false
	# emptyBlock.blockType = Global.BlockType.Empty
	# remove_child(Global.blockGrid[x][y])
	# emptyBlock.position = Vector2(x * Global.blockSize[0], y * Global.blockSize[1])
	# Global.blockGrid[x][y] = emptyBlock
	# add_child(emptyBlock)

func BuildGrid():
	for x in range(0, Global.gridWidth):
		Global.blockGrid.append([])
		Global.emptyBlockGrid.append([])
		for y in range(0, Global.gridHeight):
			var block = Global.EmptyBlock.instance()
			#block.add_to_group("empty", true)
			#block.add_to_group("outside", true)
			block.draggable = false
			block.blockType = Global.BlockType.Empty
			block.position = Vector2(x * Global.blockSize[0], y * Global.blockSize[1])
			Global.emptyBlockGrid[x].append(block)
			add_child(block)
			Global.blockGrid[x].append(null)

func BuildWall():
	for x in range(0, Global.gridWidth):
		for y in range(0, Global.gridHeight):
			if x == 0 or x == Global.gridWidth - 1 or y == 0 or y == Global.gridHeight - 1:
				#remove_child(Global.blockGrid[x][y])
				print(x, " | ", y, " | ", Global.blockGrid[x][y])
				CreateBlock(Global.BlockType.Wall, x, y, false)

func MakeGameBoard(newW, newH):
	for i in get_children():
		remove_child(i)
	Global.blockGrid = [[]]
	Global.emptyBlockGrid = [[]]
	Global.gridWidth = newW
	Global.gridHeight = newH
	BuildGrid()
