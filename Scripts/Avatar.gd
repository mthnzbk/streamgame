extends KinematicBody2D

const gravity = 99
const speed = 45
var velocity = Vector2(0, 0)
var direction = 0
var walking = 0

enum State {IDLE, STAND, WALK, JUMP, SIT, SLEEP, HUG, DANCE, ATTACK, FART}
var state

var timer:Timer = Timer.new()
onready var anim := $AnimationPlayer

func _ready():
	randomize()
	add_child(timer)
	timer.connect("timeout", self, "ai_state")
	timer.wait_time = 4
	timer.start()
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _physics_process(delta):
	velocity = Vector2.ZERO
	velocity.y += gravity
	velocity.x += [1, -1][direction] * walking * speed
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if !is_on_floor() and !is_on_wall():
		print("jump")
		on_jump()
	
	if is_on_floor() and velocity.x == 0:
		on_stand()
		print("stand")
		
	if is_on_floor() and velocity.x != 0:
		on_walk()
		if velocity.x > 0:
			$Sprite.flip_h = false
		else:
			$Sprite.flip_h = true
		
	on_state()

func avatar_dead():
	queue_free()

func on_idle():
	state = State.IDLE

func on_stand():
	state = State.STAND

func on_walk():
	state = State.WALK

func on_jump():
	state = State.JUMP

func on_sit():
	state = State.SIT

func on_sleep():
	state = State.SLEEP

func on_hug():
	state = State.HUG

func on_dance():
	state = State.DANCE

func on_attack():
	state = State.ATTACK

func on_fart():
	state = State.FART

func on_state():
	match state:
		State.IDLE:
			anim.play("idle")
		
		State.STAND:
			anim.play("idle")
			
		State.ATTACK:
			pass
			
		State.DANCE:
			pass
			
		State.FART:
			pass
			
		State.HUG:
			pass
			
		State.JUMP:
			anim.play("jump")
			
		State.SIT:
			pass
			
		State.SLEEP:
			pass
			
		State.WALK:
			anim.play("walk")

func set_title(title):
	$Label.set_text(title)

func ai_state():
	walking = randi()%2
	if walking:
		direction = randi()%2




