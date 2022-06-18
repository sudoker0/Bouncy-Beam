extends Control
export (PackedScene) var button
signal loadLevel
func _ready():
	Global.customMap = false
	var file = File.new()
	var num = 1
	file.open("res://GameData.json", File.READ)
	var content_as_text = file.get_as_text()
	var data = parse_json(content_as_text)
	file.close()
	for i in data:
		var newButton = button.instance()
		if num > Global.persistentGameData.currentLevel:
			newButton.disabled = true
		newButton.text = str(i.level_name)
		newButton.connect("button_down", self, "_on_load_game", [i])
		#connect("button_down", newButton, "_on_load_game", [i])
		$ScrollContainer/LevelList.add_child(newButton)
		num += 1

func _on_load_game(data):
	Global.playSoundEffect("pressedButton")
	Global.gameDataJSON = data
	get_tree().change_scene(Global.gameboard)

func _on_BackButton_button_down():
	Global.playSoundEffect("pressedButton")
	get_tree().change_scene(Global.intro)

func _on_LoadButton_button_down():
	Global.playSoundEffect("pressedButton")
	$OpenFile.popup_centered()

func _on_OpenFile_file_selected(path):
	var file = File.new()
	if file.file_exists(path):
		file.open(path, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			Global.customMap = true
			Global.gameDataJSON = data
			get_tree().change_scene(Global.gameboard)
		else:
			$InvalidFileDialog.popup_centered()
			printerr("Corrupted data!")
	else:
		$InvalidFileDialog.popup_centered()
		printerr("No saved data!")
