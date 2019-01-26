extends RigidBody2D

export (String) var shell_type = "unkown"

func _on_Timer_timeout():
	set_collision_mask_bit(0, true)
	set_collision_layer_bit(0, true)

func get_shell_type():
	return shell_type
