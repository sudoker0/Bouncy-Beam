extends Block

export var hit = false

func _ready():
	externalData = {
		"receiverColor": "#ff0000"
	}

func _process(_delta):
	$Indicator.color = externalData.receiverColor
