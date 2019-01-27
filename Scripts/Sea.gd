extends Area2D

func _on_Sea_body_entered(body):
	if (body.has_method("win")):
		get_tree().get_nodes_in_group("win")[0].visible = true
		body.win()
