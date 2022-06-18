extends Control

func _on_BackButton_button_down():
	Global.playSoundEffect("pressedButton")
	get_tree().change_scene(Global.intro)

func _on_ResetLP_button_down():
	$Dialog/ResetLPConfirm.popup_centered()

func _on_ResetLPConfirm_confirmed():
	Global.persistentGameData.currentLevel = 1
	Global.savePersistentData()

func _on_ResetE_button_down():
	$Dialog/ResetEConfirm.popup_centered()

func _on_ResetE_confirmed():
	Global.persistentGameData = Global.defaultPersistentGameData
	Global.savePersistentData()
