extends RigidBody2D

onready var shell_character : = $EnemyCrabSprite/Base/Hip/Shell1

var shell_type

var is_walking_ani : = false
var is_idle_ani : = false

var direction : int = -1

var velocity : = Vector2.ZERO

func _ready():
	shell_type = "plain"
	set_shell(shell_type)

#
### Main Loop
#
func _process(delta):
	pass

#
### Physics
#
func _physics_process(delta:float):
	velocity.x = linear_velocity.x
	velocity.y = linear_velocity.y
	
	if (direction < 0):
		velocity.x -= 20
	if (direction > 0):
		velocity.x += 20
	
	set_linear_velocity(velocity)
	
	if (direction < 0):
		move_animation(true)
	elif (direction > 0):
		move_animation(false)
	else:
		idle_animation()

#
### Helpers
#
var previously_triggered_by = 0
func trigger(id:int):
	print(id)
	if (id != previously_triggered_by):
		direction *= -1
		previously_triggered_by = id

func set_shell(type:String):
	shell_type = type
	if (type == "none"):
		shell_character.frame = 0
		if (is_idle_ani):
			$EnemyCrabSprite/AnimationPlayer.play("IdleNoShell")
		if (is_walking_ani):
			$EnemyCrabSprite/AnimationPlayer.play("WalkNoShell")
		var new_color = Color("#cd2727")
		$EnemyCrabSprite/Base/Hip/Shell1.self_modulate.h = new_color.h
		$EnemyCrabSprite/Base/Hip/Shell1.self_modulate.s = new_color.s
		$EnemyCrabSprite/Base/Hip/Shell1.self_modulate.v = new_color.v
		return
		
	if (type == "plain"):
		shell_character.frame = 3
	if (type == "can"):
		shell_character.frame = 1
	if (type == "fancy"):
		shell_character.frame = 2
		
	if (is_idle_ani):
		$EnemyCrabSprite/AnimationPlayer.play("Idle")
	if (is_walking_ani):
		$EnemyCrabSprite/AnimationPlayer.play("Walk")

func move_animation(left:bool):
	if (left):
		$EnemyCrabSprite.scale.x = 1
		$EnemyCrabSprite.position.x = 0
	else:
		$EnemyCrabSprite.scale.x = -1
		$EnemyCrabSprite.position.x = -130
	
	is_idle_ani = false
	if (is_walking_ani == false):
		is_walking_ani = true
		if (shell_type != "none"):
			$EnemyCrabSprite/AnimationPlayer.play("Walk")
		else:
			$EnemyCrabSprite/AnimationPlayer.play("WalkNoShell")

func idle_animation():
	is_walking_ani = false
	if (is_idle_ani == false):
		is_idle_ani = true
		if (shell_type != "none"):
			$EnemyCrabSprite/AnimationPlayer.play("Idle")
		else:
			$EnemyCrabSprite/AnimationPlayer.play("IdleNoShell")


func _on_HitBox_body_entered(body):
	if (shell_type != "none" and body.has_method("get_shell_type")):
		if (abs(body.linear_velocity.x) > 10 or abs(body.linear_velocity.y) > 10):
			var degrees = (randi() * 90) - 45
			$ShellLauncher.throw_shell(shell_type, Vector2.UP.rotated(deg2rad(degrees)), $ShellLauncher.get_global_transform().get_origin())
			set_shell("none")
