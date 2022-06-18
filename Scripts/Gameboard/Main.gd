extends Node2D
var data
var noLimit = false

func check():
	if Global.triesLeft > 0 or noLimit:
		return
	Global.playSoundEffect("lose")
	$UI/CanvasLayer/YOUUHH.text = "You Lost!!!"
	$UI/CanvasLayer/YOUUHH.visible = true
	$UI/CanvasLayer/PlayButton.visible = false

func _on_PlayButton_button_down():
	Global.beginSimulation = false if Global.beginSimulation else true
	if not Global.beginSimulation:
		Global.triesLeft -= 1
		check()
	else:
		Global.playSoundEffect("laserShooting")
	$UI/CanvasLayer/PlayButton.texture_normal = Global.stopButton if Global.beginSimulation else Global.playButton

func _on_BackButton_button_down():
	Global.playSoundEffect("pressedButton")
	pass # Replace with function body.
	get_tree().change_scene(Global.levelChooser)

func _ready():
	Global.beginSimulation = false
	var file = File.new()
	file.open("res://GameData.json", File.READ)
	var content_as_text = file.get_as_text()
	file.close()
	data = parse_json(content_as_text)
	Global.triesLeft = Global.gameDataJSON.max_number_of_tries
	if Global.triesLeft <= 0:
		noLimit = true

func _process(_delta):
	$UI/CanvasLayer/TriesLeft.text = "Unlimited Lives!" if noLimit else ("Lives Left: %s" % Global.triesLeft)
	if not Global.beginSimulation:
		return

	var didIWin = []
	for i in Global.laserList:
		didIWin.append(i.IWIN)
	if didIWin.has(false):
		return

	var newLevel = int(Global.gameDataJSON.level_name) + 1
	if $UI/CanvasLayer/YOUUHH.text == "You Won!!!":
		return
	$UI/CanvasLayer/YOUUHH.visible = true
	$UI/CanvasLayer/YOUUHH.text = "You Win!!!"
	$UI/CanvasLayer/PlayButton.visible = false

	if Global.customMap:
		return

	if len(data) >= newLevel:
		$UI/CanvasLayer/NextButton.visible = true
	else:
		return

	Global.persistentGameData.currentLevel = max(newLevel, Global.persistentGameData.currentLevel)
	Global.savePersistentData()

func _on_NextButton_button_down():
	Global.playSoundEffect("pressedButton")
	Global.gameDataJSON = data[min(int(Global.gameDataJSON.level_name) + 1, len(data)) - 1]
	get_tree().change_scene(Global.gameboard)
