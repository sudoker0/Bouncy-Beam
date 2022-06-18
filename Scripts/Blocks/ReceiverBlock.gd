extends Block

func _ready():
	externalData = {
		"receiverColor": "#ff0000"
	}

func _process(_delta):
	$indicator.color = externalData.receiverColor
