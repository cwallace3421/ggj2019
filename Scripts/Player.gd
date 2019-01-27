extends RigidBody2D
onready var trajectory: = $Trajectory
onready var camera: = $CameraPoint/Camera2D
onready var traj_raycast : = $TrajRayCast2D
onready var floor_raycast_1 : = $FloorRayCast2D1
onready var floor_raycast_2 : = $FloorRayCast2D2
onready var floor_raycast_3 : = $FloorRayCast2D3
onready var shell_character : = $CrabSprite/Base/Hip/Shell1
onready var pickup_area : = $PickupArea

var shell_type = "plain"

var throw_direction:Vector2 = Vector2.ZERO
var is_throwing : = false

var is_walking_ani : = false
var is_idle_ani : = false

var velocity : = Vector2.ZERO
var jump_velocity : = Vector2.ZERO

var shell_to_pickup

var is_dead
var is_win
var ani_block

func _ready():
	is_win = false
	is_dead = false
	ani_block = false
	set_shell(shell_type)
	Input.connect("joy_connection_changed", self, "joy_changed")
	$CrabSprite/AnimationPlayer.connect("animation_finished", self, "_animation_finished")

#
### Main Loop
#
func _process(delta):
	if (is_dead or is_win): return
	
	if (Input.is_action_just_pressed("action")):
		a_button_pressed(delta)
		
	if (Input.is_action_pressed("right_trigger") and shell_type != "none"):
		right_trigger_pressed(delta)
	else:
		right_trigger_unpressed(delta)

#
### 'A' Button
#
func a_button_pressed(delta:float):
	if (shell_to_pickup != null):
		set_shell(shell_to_pickup.get_shell_type())
		shell_to_pickup.free()
		shell_to_pickup = null

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
			$ShellLauncher.place_shell(shell_type, traj_raycast.get_collision_point())
			set_shell("none")
			jump_velocity = throw_direction.reflect(throw_direction.tangent()) * 1300
		else:
			is_throwing = true
			$ShellLauncher.throw_shell(shell_type, throw_direction, traj_raycast.get_global_transform().get_origin())
			set_shell("none")
			jump_velocity = Vector2.ZERO
		throw_direction = Vector2.ZERO
		right_trigger_unpressed(delta)

#
### Physics
#
func _physics_process(delta:float):
	if (is_dead or is_win): return
	velocity.x = linear_velocity.x
	velocity.y = linear_velocity.y
	
	linear_damp = -1
	
	var x_axis = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if (jump_velocity != Vector2.ZERO):
		velocity += jump_velocity
		jump_velocity = Vector2.ZERO
	else:
		if (is_on_floor()):
			if (x_axis < 0):
				velocity.x = -450
			if (x_axis > 0):
				velocity.x = 450
			linear_damp = 4
	
	set_linear_velocity(velocity)
	
	if (x_axis < 0):
		move_animation(true)
	elif (x_axis > 0):
		move_animation(false)
	else:
		idle_animation()

#
### Helpers
#
func is_on_floor():
	return floor_raycast_1.is_colliding() or floor_raycast_2.is_colliding() or floor_raycast_3.is_colliding()

func set_shell(type:String):
	shell_type = type
	if (type == "none"):
		shell_character.frame = 0
		if (!ani_block):
			if (is_idle_ani):
				$CrabSprite/AnimationPlayer.play("IdleNoShell")
			if (is_walking_ani):
				$CrabSprite/AnimationPlayer.play("WalkNoShell")
		return
		
	if (type == "plain"):
		shell_character.frame = 3
	if (type == "can"):
		shell_character.frame = 1
	if (type == "fancy"):
		shell_character.frame = 2
	
	if (!ani_block):
		if (is_idle_ani):
			$CrabSprite/AnimationPlayer.play("Idle")
		if (is_walking_ani):
			$CrabSprite/AnimationPlayer.play("Walk")

func move_animation(left:bool):
	if (left):
		$CrabSprite.scale.x = -1
		$CrabSprite/Base.position.x = 0
	else:
		$CrabSprite.scale.x = 1
		$CrabSprite/Base.position.x = -130
	
	is_idle_ani = false
	if (is_walking_ani == false):
		is_walking_ani = true
		if (!ani_block):
			if (shell_type != "none"):
				$CrabSprite/AnimationPlayer.play("Walk")
			else:
				$CrabSprite/AnimationPlayer.play("WalkNoShell")

func idle_animation():
	is_walking_ani = false
	if (is_idle_ani == false):
		is_idle_ani = true
		if (!ani_block):
			if (shell_type != "none"):
				$CrabSprite/AnimationPlayer.play("Idle")
			else:
				$CrabSprite/AnimationPlayer.play("IdleNoShell")

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

func _on_PickupArea_body_entered(body):
	if (body.is_in_group("shells")):
		if (shell_to_pickup != null):
			print("Already shell ready to be picked up")
		else:
			shell_to_pickup = body

func _on_PickupArea_body_exited(body):
	if (body.is_in_group("shells")):
		if (shell_to_pickup != null):
			shell_to_pickup = null

func _on_HitBox_body_entered(body):
	if (body.has_method("is_enemy")):
		body.trigger(randi() * 10000)
		if (shell_type != "none" and !is_dead):
			$ShellLauncher.throw_shell(shell_type, Vector2.UP, $ShellLauncher.get_global_transform().get_origin(), 600)
			set_shell("none")
			ani_block = true
			$CrabSprite/AnimationPlayer.play("Hit")
		else:
			is_dead = true
			ani_block = true
			$CrabSprite/AnimationPlayer.play("Death")
			get_tree().get_nodes_in_group("lose")[0].visible = true

func _animation_finished(name:String):
	if (ani_block and name != "Death"):
		ani_block = false
		set_shell(shell_type)

func win():
	is_win = true
	$CrabSprite/AnimationPlayer.stop()
