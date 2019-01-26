extends Node2D

onready var Shell = preload("res://Objects/Shell.tscn")

export var force = 20

func throw_shell(type:String, direction:Vector2, position:Vector2):
	var o = Shell.instance()
	o.position = position + (direction * 200)
	get_tree().get_nodes_in_group("level_root")[0].add_child(o)
	o.apply_impulse(Vector2.ZERO, direction * force)