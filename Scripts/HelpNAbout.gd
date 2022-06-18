extends Control

func _on_BackButton_button_down():
	Global.playSoundEffect("pressedButton")
	get_tree().change_scene(Global.intro)

func _on_Open_Content_clicked(meta):
	var node = get_tree().get_nodes_in_group(parse_json(meta)["open_text"])[0]
	node.visible = false if node.visible else true
