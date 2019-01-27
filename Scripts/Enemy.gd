extends RigidBody2D

onready var shell_character : = $EnemyCrabSprite/Base/Hip/Shell1

var shell_type

var is_walking_ani : = false
var is_idle_ani : = false

var direction : int = -1

var velocity : = Vector2.ZERO

var is_dead

var ani_block

func _ready():
	ani_block = false
	is_dead = false
	shell_type = "plain"
	
	if (position.x > 10000):
		shell_type = "fancy"
	
	set_shell(shell_type)
	$EnemyCrabSprite/AnimationPlayer.connect("animation_finished", self, "_animation_finished")

#
### Main Loop
#
func _process(delta):
	pass

#
### Physics
#
func _physics_process(delta:float):
	if (is_dead): return
	
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
	if (id != previously_triggered_by):
		direction *= -1
		previously_triggered_by = id

func set_shell(type:String):
	shell_type = type
	if (type == "none"):
		shell_character.frame = 0
		if (!ani_block):
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
	
	if (!ani_block):
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
		if (!ani_block):
			if (shell_type != "none"):
				$EnemyCrabSprite/AnimationPlayer.play("Walk")
			else:
				$EnemyCrabSprite/AnimationPlayer.play("WalkNoShell")

func idle_animation():
	is_walking_ani = false
	if (is_idle_ani == false):
		is_idle_ani = true
		if (!ani_block):
			if (shell_type != "none"):
				$EnemyCrabSprite/AnimationPlayer.play("Idle")
			else:
				$EnemyCrabSprite/AnimationPlayer.play("IdleNoShell")


func _on_HitBox_body_entered(body):
	print("hit")
	if (body.has_method("get_shell_type")):
		print("a")
		if (abs(body.linear_velocity.x) > 400 or abs(body.linear_velocity.y) > 400):
			print("b")
			if (shell_type != "none" and !is_dead):
				$ShellLauncher.throw_shell(shell_type, Vector2.UP, $ShellLauncher.get_global_transform().get_origin(), 1000)
				set_shell("none")
				ani_block = true
				$EnemyCrabSprite/AnimationPlayer.play("Hit_Ani")
			else:
				is_dead = true
				ani_block = true
				$EnemyCrabSprite/AnimationPlayer.play("Death_Ani")
				set_collision_layer_bit(1, false)
				set_collision_layer_bit(3, true)
				set_collision_mask_bit(0, false)
				set_collision_mask_bit(2, false)
				set_collision_mask_bit(3, true)

func _animation_finished(name:String):
	if (ani_block and name != "Death_Ani"):
		ani_block = false
		set_shell(shell_type)
		
func is_enemy() -> bool:
	return true