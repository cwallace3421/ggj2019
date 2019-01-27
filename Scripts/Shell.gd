extends RigidBody2D

export (String) var shell_type = "unkown"

func _ready():
	print(shell_type)
	if (shell_type == "none"):
		$Sprite.frame = 0		
	if (shell_type == "plain"):
		$Sprite.frame = 3
	if (shell_type == "can"):
		$Sprite.frame = 1
	if (shell_type == "fancy"):
		$Sprite.frame = 2

func _on_Timer_timeout():
	set_collision_mask_bit(0, true)
	set_collision_layer_bit(0, true)

func get_shell_type():
	return shell_type
