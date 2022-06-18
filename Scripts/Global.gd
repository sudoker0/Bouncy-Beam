extends Node

# Camera variables
var cameraIsMoving = false
var enabledCameraMovement = false

# Grid variables
var blockGrid = [[]]
var emptyBlockGrid = [[]]
var gridWidth = 0
var gridHeight = 0

# Drag variables
var blockIsMoving = false
var blockSize = [64, 64]
var laserList = []

# Constants
const Z_NORMAL_BLOCK = 2
const Z_PICKUP_BLOCK = 10
const defaultPersistentGameData = {
	"currentLevel": 1,
	"settings": {
		"cameraMinZoom": 0.2,
		"cameraMaxZoom": 1000,
		"cameraZoomSpeed": 2,
		"cameraMoveSpeed": 1,
	},
	"soundVolume": 1
}

# General variables
var customMap = false
var beginSimulation = false
var gameDataJSON = {}
var currentlyPlaying = 0
var triesLeft = 0

var persistentGameData = {
	"currentLevel": 1,
	"settings": {
		"cameraMinZoom": 0.2,
		"cameraMaxZoom": 1000,
		"cameraZoomSpeed": 2,
		"cameraMoveSpeed": 1,
	},
	"soundVolume": 1
}

# Scene variables
export (String, FILE, "*.tscn") var intro
export (String, FILE, "*.tscn") var gameboard
export (String, FILE, "*.tscn") var levelChooser
export (String, FILE, "*.tscn") var settings
export (String, FILE, "*.tscn") var mapEditor
export (String, FILE, "*.tscn") var helpAndAbout

# Block variables
export (PackedScene) var DeadZoneBlock
export (PackedScene) var EmptyBlock
export (PackedScene) var GlassBlock
export (PackedScene) var LaserBlock
export (PackedScene) var LightBlockBlock
export (PackedScene) var ReceiverBlock
export (PackedScene) var WallBlock

# Block texture variables
export (StreamTexture) var DeadZoneBlockTexture
export (StreamTexture) var EmptyBlockTexture
export (StreamTexture) var GlassBlockTexture
export (StreamTexture) var LaserBlockTexture
export (StreamTexture) var LightBlockBlockTexture
export (StreamTexture) var ReceiverBlockTexture
export (StreamTexture) var WallBlockTexture

# Map editor variables
export (PackedScene) var EditBlock
var isEditingProperty = false
var selectedBlockToEdit = Vector2(-1, -1)
var makeBlockDraggable = true
var loadedFile = ""

# Audio variables
export (AudioStream) var pressedButtonSoundFile
export (AudioStream) var laserShootingSoundFile
export (AudioStream) var loseSoundFile
export (AudioStream) var pickupFile
export (AudioStream) var putdownFile

# UI variables
export (StreamTexture) var blockSelected
export (StreamTexture) var blockSelectedGood
export (StreamTexture) var blockSelectedBad
export (StreamTexture) var stopButton
export (StreamTexture) var playButton

# Block type
const BlockType = {
	"DeadZone": {
		"name": "Dead Zone Block",
		"type": "DeadZone",
		"texture": "DeadZoneBlockTexture",
	},
	"Empty": {
		"name": "Empty Block",
		"type": "Empty",
		"texture": "EmptyBlockTexture",
	},
	"Glass": {
		"name": "Glass Block",
		"type": "Glass",
		"texture": "GlassBlockTexture",
	},
	"Laser": {
		"name": "Laser Block",
		"type": "Laser",
		"texture": "LaserBlockTexture",
	},
	"LightBlock": {
		"name": "Block that block light Block",
		"type": "LightBlock",
		"texture": "LightBlockBlockTexture",
	},
	"Receiver": {
		"name": "Receiver Block",
		"type": "Receiver",
		"texture": "ReceiverBlockTexture",
	},
	"Wall": {
		"name": "Wall Block",
		"type": "Wall",
		"texture": "WallBlockTexture",
	}
}

var audioPlayer = AudioStreamPlayer.new()

func _ready():
	add_child(audioPlayer)
	pass

func _process(_delta):
	#._input(event)
	if Input.is_action_just_released("full_screen"):
		OS.window_fullscreen = !OS.window_fullscreen

func playSoundEffect(sound):
	match sound:
		"pressedButton":
			audioPlayer.stream = pressedButtonSoundFile
		"laserShooting":
			audioPlayer.stream = laserShootingSoundFile
		"lose":
			audioPlayer.stream = loseSoundFile
		"pickup":
			audioPlayer.stream = pickupFile
		"putdown":
			audioPlayer.stream = putdownFile

	audioPlayer.play()

func savePersistentData():
	var save_game = File.new()
	save_game.open("user://player_data.save", File.WRITE)
	save_game.store_string(to_json((persistentGameData)))
	save_game.close()

func loadPersistentData():
	var load_game = File.new()
	if not load_game.file_exists("user://player_data.save"):
		return
	load_game.open("user://player_data.save", File.READ)
	persistentGameData = parse_json(load_game.get_as_text())
	load_game.close()

func _input(_event):
	if Input.is_action_just_pressed("debug_dump_map"):
		print("List of lasers:", Global.laserList)
		print("Global W | H: ", gridWidth, " | ", gridHeight)
		for i in range(0, len(Global.blockGrid)):
			var blocc = ""
			for j in range(0, len(Global.blockGrid[i])):
				#print("Block | X | Y: ", Global.blockGrid[i][j], " | ", i, " | ", j)
				if Global.blockGrid[i][j] == null:
					blocc += " "
					continue
				match Global.blockGrid[i][j].blockType:
					BlockType.DeadZone:
						blocc += "$"
					BlockType.Glass:
						blocc += "|"
					BlockType.Laser:
						blocc += "/"
					BlockType.LightBlock:
						blocc += "O"
					BlockType.Receiver:
						blocc += "@"
					BlockType.Wall:
						blocc += "#"
			print(blocc)
