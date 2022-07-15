extends Block

func _ready():
	externalData = {
		"switchColor": "#00ff00"
	}

func _process(_delta):
	$Switch/ColorRect.color = Color(externalData.switchColor)
