extends RigidBody2D

func _on_Timer_timeout():
	set_collision_mask_bit(0, true)
	set_collision_layer_bit(0, true)
