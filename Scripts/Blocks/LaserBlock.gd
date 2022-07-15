extends Block

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
			print(ray.is_colliding())
			if not ray.is_colliding():
				var pt = ray.global_position + ray.cast_to
				line.add_point(line.to_local(pt))
				break

			var coll = ray.get_collider()
			#print(coll)
			var pt = ray.get_collision_point()
			print(coll, " | ", pt)
			line.add_point(line.to_local(pt))

			if coll.is_in_group("receiver"):
				coll.get_parent().hit = Color(externalData.laserColor) == Color(coll.get_parent().externalData.receiverColor)

			if coll.is_in_group("switch"):
				for i in Global.gateList:
					if Color(i.get_node("Gate/ColorRect").color) == Color(coll.get_node("ColorRect").color) and Color(externalData.laserColor) == Color(coll.get_node("ColorRect").color):
						i.get_node("Gate/Collision").disabled = true
						i.get_node("Gate").visible = false

			if coll.is_in_group("colorfilter"):
				coll.get_parent().get_node("Indicator")

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
		for i in Global.receiverList:
			i.hit = false

		for i in Global.gateList:
			i.get_node("Gate/Collision").disabled = false
			i.get_node("Gate").visible = true
