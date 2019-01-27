extends Control

var Beach = preload("res://Scenes/Beach.tscn")

var screen_id:int = 0

func _process(delta):
	if (Input.is_action_just_pressed("action")):
		if (screen_id == 0):
			screen_id += 1
			$Main.visible = false
			$Instructions.visible = true
		elif (screen_id == 1):
			get_tree().change_scene("res://Scenes/Beach.tscn")
		
