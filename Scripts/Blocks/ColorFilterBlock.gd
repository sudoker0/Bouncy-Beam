extends Block

func _ready():
	externalData = {
		"filterColor": "#ff0000"
	}

func _process(_delta):
	$Indicator.color = externalData.filterColor
