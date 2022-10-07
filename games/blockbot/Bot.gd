extends KinematicBody

var Chunk = load("res://Chunk.gd")

onready var anim = get_node("AnimationPlayer")
onready var player = get_node("../Player")

const SPEED = 5
var velocity = Vector3.ZERO
const gravity = 9.8
var jump_vel = 5

var paused = false
var goal_block = Vector3(0,0,0)
var state = "init"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_state(new_state):
	if new_state != state:
		print(new_state)
		state = new_state


func _physics_process(delta):
	if paused:
		return
	var new_state = "..."
	
	# Where is the goal relative to the bot?
	var dp = goal_block - self.translation
	
	if is_on_floor():
		velocity.y = 0
		
		# If the goal is higher than the bot, it needs to jump.
		if dp.y > 1:
			new_state = "jump"
			anim.play("Jump")
			velocity.y = jump_vel
	else:
		# If bot is airborne, apply gravity.
		velocity.y -= gravity * delta

	# Adjust xz velocity based on distance from goal.
	var dist = dp.length()
	
	self.rotation.y = lerp_angle( self.rotation.y, atan2( dp.x, dp.z ), 1 ) 

	if dist > 0.8:
		new_state = "fast"
		var direction = dp.normalized() * SPEED
		velocity.x = direction.x
		velocity.z = direction.z
		anim.play("Run-loop")
	elif dist < 0.5:
		new_state = "stop"
		velocity.x = 0
		velocity.z = 0
		anim.play("Idle-loop")
	else:
		new_state = "slow"

	
	if velocity.y < -1:
		anim.play("Fall-loop")
		new_state = "fall"
	
	set_state(new_state)
	velocity = move_and_slide(velocity, Vector3.UP)


func _process(_delta):
	pass
