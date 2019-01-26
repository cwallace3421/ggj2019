extends Node2D

#onready var Dot = preload("res://Objects/Dot.tscn")
onready var Shell = preload("res://Objects/Shell.tscn")
onready var Shell_Can = preload("res://Objects/Shell_Can.tscn")
onready var Shell_Fancy = preload("res://Objects/Shell_Fancy.tscn")

export var force = 1200

func throw_shell(type:String, direction:Vector2, position:Vector2):
	var o = get_shell(type)
	o.position = position + (direction * 200)
	get_tree().get_nodes_in_group("level_root")[0].add_child(o)
	print(str(direction))
	print(str(force))
	o.apply_impulse(Vector2.ZERO, direction * force)
#	var d = Dot.instance()
#	d.position = o.position
#	get_tree().get_nodes_in_group("level_root")[0].add_child(d)

func place_shell(type:String, point:Vector2):
	var o = get_shell(type)
	o.position.x = point.x
	o.position.y = point.y - 140
	get_tree().get_nodes_in_group("level_root")[0].add_child(o)	
#	var d = Dot.instance()
#	d.position = o.position
#	get_tree().get_nodes_in_group("level_root")[0].add_child(d)

func get_shell(type:String) -> Object:
	if (type == "plain"):
		return Shell.instance()
	if (type == "can"):
		return Shell_Can.instance()
	if (type == "fancy"):
		return Shell_Fancy.instance()
	return null