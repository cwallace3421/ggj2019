extends Sprite

var move_speed : int = 60

func _ready():
	move_speed -= (floor(randi() * 20))

#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x += 30 * delta
