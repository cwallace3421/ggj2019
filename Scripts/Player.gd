extends KinematicBody2D

onready var trajectory: = $Trajectory
onready var camera: = $Camera2D

var starting_pos:Vector2 = Vector2(self.position.x, self.position.y)
var dead_zone:float = 0.2
var speed_multipler:float = 4
var gravity:float = 290

var throw_direction:Vector2 = Vector2.ZERO
var is_throwing : = false

func _ready():
	Input.connect("joy_connection_changed", self, "joy_changed")

#
### Main Loop
#
func _process(delta):
	if (Input.is_action_just_pressed("action")):
		print("'A' Pressed")
		
	if (Input.is_action_pressed("right_trigger")):
		right_trigger_pressed(delta)
	else:
		right_trigger_unpressed(delta)

#
### Right Trigger
#
func right_trigger_pressed(delta:float):
	trajectory.set_active(true)
	var x_axis_alt = Input.get_action_strength("alt_right") - Input.get_action_strength("alt_left")
	var y_axis_alt = Input.get_action_strength("alt_down") - Input.get_action_strength("alt_up")
	lerp_zoom_to(2.2, true)
	trajectory.set_vector(Vector2(x_axis_alt, y_axis_alt).normalized())
	throw_direction = trajectory.get_vector()
	
	$RayCast2D.enabled = true
	$RayCast2D.cast_to(throw_direction * 150)
	

func right_trigger_unpressed(delta:float):
	if (throw_direction == Vector2.ZERO):
		is_throwing = false
		lerp_zoom_to(1.2, false)
		trajectory.set_active(false)
		$RayCast2D.enabled = false
	elif ($RayCast2D.is_colliding()):
		print(str($RayCast2D.get_collider()))
		throw_direction = Vector2.ZERO
		right_trigger_unpressed(delta)
	else:
		var raycaster:RayCast2D = $RayCast2D
		raycaster.cast_to(throw_direction * 150)
		raycaster.force_raycast_update()
		if ($RayCast2D.is_colliding()):
			is_throwing = true
			$ShellLauncher.throw_shell("type", throw_direction, position)
			throw_direction = Vector2.ZERO
			right_trigger_unpressed(delta)

#
### Physics
#
func _physics_process(delta:float):
	var vel:Vector2 = Vector2(0, 0)
	vel.y = get_gravity(delta)
	
	var x_axis = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if (is_on_floor()):
		if (x_axis < 0):
			vel.x = -get_speed(delta, x_axis)
		if (x_axis > 0):
			vel.x = +get_speed(delta, x_axis)
	
	vel = move_and_slide(vel, Vector2.UP) # can raycast to floor to get normal
	move_and_collide(vel)

#
### Helpers
#
func get_speed(delta:float, axis:float) -> float:
	return (100 * delta * (speed_multipler * abs(axis)))

func get_gravity(delta:float) -> float:
	return gravity * delta

func lerp_zoom_to(value:float, pin_bottom:bool):
	if (camera.zoom.x != value):
		camera.zoom = camera.zoom.linear_interpolate(Vector2(value, value), .35)
	if (pin_bottom):
		camera.offset = camera.offset.linear_interpolate(Vector2(0, -500), .5)
	else:
		camera.offset = camera.offset.linear_interpolate(Vector2(0, 0), .5)

func joy_changed(id, is_connected):
	if (is_connected):
		print("Joystick" + str(id) + " connected")
		if (Input.is_joy_known(0)):
			print("Recognised and compatible joystick")
			print(Input.get_joy_name(0) + " device connected")
		else:
			print("Joystick " + str(id) + " disconnected")