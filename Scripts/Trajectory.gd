extends Node2D

var is_active:bool = false
var dots:Array = []
var spacing = 0
var default_pos = Vector2(position.x, position.y)
var direction:Vector2 = Vector2.ZERO

func _ready():
	dots = get_children()
	for dot in dots:
		dot.scale.x = 0.2
		dot.scale.y = 0.2
	set_visibilty(false)
	spacing = (dots[0].texture.get_size().x * dots[0].scale.x) * 2

func set_vector(v:Vector2):
	direction = v.normalized()
	var count : = 0
	for dot in dots:
		dot.position.x = direction.x * ((spacing * count) + 80)
		dot.position.y = direction.y * ((spacing * count) + 80)
		count += 1

func get_vector() -> Vector2:
	return direction

func set_active(active:bool):
	is_active = active
	set_visibilty(active)

func set_visibilty(visible:bool):
	if (dots.size() > 0):
		for dot in dots:
			dot.visible = visible