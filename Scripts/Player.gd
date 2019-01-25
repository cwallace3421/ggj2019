extends KinematicBody2D

onready var trajectory: = $Trajectory

var starting_pos:Vector2 = Vector2(self.position.x, self.position.y)
var dead_zone:float = 0.2
var speed_multipler:float = 4
var gravity:float = 290

func _ready():
	Input.connect("joy_connection_changed", self, "joy_changed")


func _process(delta):
	if (Input.is_action_just_pressed("ui_accept")):
		print("'A' Pressed")
		
	if (Input.is_action_pressed("right_trigger")):
		trajectory.set_active(true)
		var x_axis_alt = Input.get_action_strength("alt_right") - Input.get_action_strength("alt_left")
		var y_axis_alt = Input.get_action_strength("alt_down") - Input.get_action_strength("alt_up")
		trajectory.set_vector(Vector2(x_axis_alt, y_axis_alt).normalized())
	else:
		trajectory.set_active(false)


func _physics_process(delta:float):
	var vel:Vector2 = Vector2(0, 0)
	vel.y = get_gravity(delta)
	
	var x_axis = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if (is_on_floor()):
		if (x_axis < 0):
			vel.x = -get_speed(delta, x_axis)
		if (x_axis > 0):
			vel.x = +get_speed(delta, x_axis)
	
	vel = move_and_slide(vel, Vector2.UP)
	move_and_collide(vel)


func get_speed(delta:float, axis:float) -> float:
	return (100 * delta * (speed_multipler * abs(axis)))

func get_gravity(delta:float) -> float:
	return gravity * delta

func joy_changed(id, is_connected):
	if (is_connected):
		print("Joystick" + str(id) + " connected")
		if (Input.is_joy_known(0)):
			print("Recognised and compatible joystick")
			print(Input.get_joy_name(0) + " device connected")
		else:
			print("Joystick " + str(id) + " disconnected")