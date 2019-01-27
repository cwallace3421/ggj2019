extends Sprite



#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x += 30 * delta
