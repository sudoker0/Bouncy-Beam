extends Block

func _ready():
	externalData = {
		"rotation": 0
	}

func _process(_delta):
	$GlassPane.rotation_degrees = externalData.rotation
	$DeadGlassPane.rotation_degrees = externalData.rotation
