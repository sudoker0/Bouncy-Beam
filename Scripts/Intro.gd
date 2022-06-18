extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.loadPersistentData()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Play_button_down():
	Global.playSoundEffect("pressedButton")
	get_tree().change_scene(Global.levelChooser)

func _on_Exit_button_down():
	Global.playSoundEffect("pressedButton")
	get_tree().quit(1)

func _on_MapEditor_button_down():
	Global.playSoundEffect("pressedButton")
	get_tree().change_scene(Global.mapEditor)

func _on_HelpNAbout_button_down():
	Global.playSoundEffect("pressedButton")
	get_tree().change_scene(Global.helpAndAbout)

func _on_Settings_button_down():
	Global.playSoundEffect("pressedButton")
	get_tree().change_scene(Global.settings)
