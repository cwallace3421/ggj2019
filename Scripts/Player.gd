extends KinematicBody2D

onready var Dot = preload("res://Objects/Dot.tscn")

onready var trajectory: = $Trajectory
onready var camera: = $Camera2D
onready var traj_raycast : = $TrajRayCast2D
onready var floor_raycast : = $FloorRayCast2D

var starting_pos:Vector2 = Vector2(self.position.x, self.position.y)
var dead_zone:float = 0.2
var speed_multipler:float = 4

var throw_direction:Vector2 = Vector2.ZERO
var is_throwing : = false

var is_walking_ani : = false
var is_idle_ani : = false

var velocity : = Vector2.ZERO
var prev_velocity : = Vector2.ZERO
var jump_velocity : = Vector2.ZERO
var gravity:float = 600
var damping:float = 100 

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
	

func right_trigger_unpressed(delta:float):
	if (throw_direction == Vector2.ZERO):
		is_throwing = false
		lerp_zoom_to(1.2, false)
		trajectory.set_active(false)
	else:
		traj_raycast.cast_to = throw_direction * 500
		traj_raycast.force_raycast_update()
		if (traj_raycast.is_colliding() and traj_raycast.get_collider() is StaticBody2D):
			$ShellLauncher.place_shell("type", traj_raycast.get_collision_point())
			jump_velocity = throw_direction.reflect(throw_direction.tangent()) * 350
		else:
			is_throwing = true
			jump_velocity = Vector2.ZERO
			$ShellLauncher.throw_shell("type", throw_direction, traj_raycast.get_global_transform().get_origin())
		throw_direction = Vector2.ZERO
		right_trigger_unpressed(delta)

#
### Physics
#
func _physics_process(delta:float):
	velocity.x = 0
	
	var x_axis = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if (jump_velocity != Vector2.ZERO):
		velocity.y += jump_velocity.y
		jump_velocity.y += 1200 * delta
		velocity.x += jump_velocity.x
	
	if (is_on_floor()):
		if (x_axis < 0):
			velocity.x -= 450
		if (x_axis > 0):
			velocity.x += 450
	
	if (!is_on_floor() or jump_velocity != Vector2.ZERO):
		velocity.y += 1200 * delta
	else:
		velocity.y = 0

	move_and_slide(velocity, Vector2.UP)
	
	if (is_on_floor()):
		jump_velocity = Vector2.ZERO
	
	if (x_axis < 0):
		move_animation(true)
	elif (x_axis > 0):
		move_animation(false)
	else:
		idle_animation()
	
#	if (is_on_floor()):
#		if (x_axis < 0):
#			vel.x = -get_speed(delta, x_axis)
#		if (x_axis > 0):
#			vel.x = +get_speed(delta, x_axis)
#
#	if (jump_velocity != Vector2.ZERO):
#		vel = jump_velocity * delta
#		jump_velocity.y = jump_velocity.y + (gravity / 4)
#		jump_velocity.x = jump_velocity.x + (damping * (sign(jump_velocity.x) * -1))
#
#	vel = move_and_slide(vel, Vector2.UP) # can raycast to floor to get normal
#	move_and_collide(vel)
#
#	if (is_on_floor()):
#		jump_velocity = Vector2.ZERO
#
#	if (x_axis < 0):
#		move_animation(true)
#	elif (x_axis > 0):
#		move_animation(false)
#	else:
#		idle_animation()

#
### Helpers
#
func move_animation(left:bool):
	if (left):
		$CrabSprite.scale.x = 1
	else:
		$CrabSprite.scale.x = -1
	
	is_idle_ani = false
	if (is_walking_ani == false):
		is_walking_ani = true
		$CrabSprite/AnimationPlayer.play("Walk")

func idle_animation():
	is_walking_ani = false
	if (is_idle_ani == false):
		is_idle_ani = true
		$CrabSprite/AnimationPlayer.play("Idle")

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