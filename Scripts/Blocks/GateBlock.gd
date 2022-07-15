extends Block

func _ready():
	externalData = {
		"gateColor": "#00ff00",
		"rotation": {
			"data": [
				"Horizontal",
				"Vertical"
			],
			"selected": 1
		}
	}

func _process(_delta):
	$Gate/ColorRect.color = Color(externalData.gateColor)
	var rotation = 0
	if externalData.rotation.selected == 0:
		rotation = 90
	
	$Pipe1.rotation_degrees = rotation
	$Pipe2.rotation_degrees = rotation
	$Gate.rotation_degrees = rotation
