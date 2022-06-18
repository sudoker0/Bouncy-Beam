extends Node2D

class_name Block

export var x: int = -1
export var y: int = -1
export var blockType = 0
export var draggable = false
#export var onGrid = false
export var externalData = {}

# !ATTENTION NEEDED

func SetPosition(newX, newY):
	var oldBlock = Global.blockGrid[newX][newY]
	Global.blockGrid[newX][newY] = self
	if x != -1 and y != -1:
		Global.blockGrid[x][y] = oldBlock
	x = newX
	y = newY
