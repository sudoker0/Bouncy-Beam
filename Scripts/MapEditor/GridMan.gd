extends "res://Scripts/GridManager.gd"

func DrawMap(gameData):
	var data = gameData
	var width = data.size.width
	var height = data.size.height

	MakeGameBoard(width, height)
	BuildWall()
	var buildData = data.board

	for i in buildData:
		var current_block = CreateBlock(Global.BlockType[i.blockType], i.coords.x, i.coords.y, i.draggable)
		for moreData in i.externalData.keys():
			for x in current_block.externalData.keys():
				if x == moreData:
					current_block.externalData[moreData] = i.externalData[moreData]
				current_block.draggable = i.draggable
