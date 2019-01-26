extends KinematicBody2D

onready var shell_character : = $EnemyCrabSprite/Base/Hip/Shell1

var shell_type = "plain"

var is_walking_ani : = false
var is_idle_ani : = false

var direction : int = -1

var velocity : = Vector2.ZERO

func _ready():
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
	velocity.x = 0
	
	if (is_on_floor()):
		if (direction < 0):
			velocity.x -= 450
		if (direction > 0):
			velocity.x += 450
	
	if (!is_on_floor()):
		velocity.y += 1200 * delta
	else:
		velocity.y = 0

	move_and_slide(velocity, Vector2.UP)
	
	if (is_on_wall()):
		previously_triggered_by = 0
		direction *= -1
	
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
