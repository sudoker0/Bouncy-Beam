extends Block

export var IWIN = false

onready var ray = $LaserPointer/Raycast
onready var line = $LaserPointer/Pointer

func StartLaser():
	pass

func _ready():
	externalData = {
		"rotation": 0,
		"laserColor": "#ff0000",
		"maxBounces": 100,
		"maxLength": 10000,
	}

func _process(_delta):
	line.clear_points()
	line.default_color = Color(externalData.laserColor)
	$LaserPointer/LC/LaserColor.color = line.default_color
	$LaserPointer/Texture.rotation_degrees = externalData.rotation
	if Global.beginSimulation:
		line.add_point(Vector2.ZERO)

		ray.global_position = line.global_position
		#ray.cast_to = (get_global_mouse_position() - line.global_position).normalized() * 1000
		ray.cast_to = Vector2.RIGHT.rotated(deg2rad(externalData.rotation - 90)).normalized() * externalData.maxLength
		ray.force_raycast_update()

		var prev = null
		var bounces = 0
		while true:
			if not ray.is_colliding():
				var pt = ray.global_position + ray.cast_to
				line.add_point(line.to_local(pt))
				break

			var coll = ray.get_collider()
			#print(coll)
			var pt = ray.get_collision_point()

			line.add_point(line.to_local(pt))

			if coll.is_in_group("receiver"):
				IWIN = Color(externalData.laserColor) == Color(coll.get_parent().externalData.receiverColor)

			if coll.is_in_group("mirrors"):
				var normal = ray.get_collision_normal()

				if normal == Vector2.ZERO:
					break

				if prev != null:
					prev.collision_mask = 3
					prev.collision_layer = 3

				prev = coll
				prev.collision_mask = 0
				prev.collision_layer = 0

				ray.global_position = pt
				ray.cast_to = ray.cast_to.bounce(normal)
				ray.force_raycast_update()

				bounces += 1
				if bounces >= externalData.maxBounces:
					break
			else:
				break

		if prev != null:
			prev.collision_mask = 3
			prev.collision_layer = 3
	else:
		IWIN = false
