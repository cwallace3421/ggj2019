extends Area2D

var id:int = floor(randf() * 10000)

func _on_EnemyBarrier_body_entered(body):
	if (body.has_method("trigger")):
		body.trigger(id)