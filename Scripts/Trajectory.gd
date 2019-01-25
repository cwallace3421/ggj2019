extends Node2D

var is_active:bool = false
var dots:Array = []
var spacing = 0
var default_pos = Vector2(position.x, position.y)

func _ready():
	dots = get_children()
	for dot in dots:
		dot.scale.x = 0.2
		dot.scale.y = 0.2
	set_visibilty(false)
	spacing = (dots[0].texture.get_size().x * dots[0].scale.x) * 2
	print("Spacing " + str(spacing))

func set_vector(v:Vector2):
	var direction : = v.normalized()
	var count : = 0
	print(str(direction))
	for dot in dots:
		dot.position.x = direction.x * ((spacing * count) + 80)
		dot.position.y = direction.y * ((spacing * count) + 80)
#		if (direction.x != 0):
##			print("Blah X")
#			dot.position.x = direction.x * (spacing * count)
#		else:
#			dot.position = default_pos
#		if (direction.y != 0):
##			print("Blah Y")
#			dot.position.y = direction.y * (spacing * count)
#		else:
#			dot.position = default_pos
		count += 1

func set_active(active:bool):
	is_active = active
	set_visibilty(active)

func set_visibilty(visible:bool):
	if (dots.size() > 0):
		for dot in dots:
			dot.visible = visible