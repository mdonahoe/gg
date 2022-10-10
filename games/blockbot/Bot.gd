extends KinematicBody

var Chunk = load("res://Chunk.gd")

onready var anim = get_node("AnimationPlayer")
onready var player = get_node("../Player")
onready var goal_outline = get_node("../GoalOutline")
onready var domino = get_node("../Domino")

signal toggle_light(pos)

const SPEED = 5
var velocity = Vector3.ZERO
const gravity = 9.8
var jump_vel = 5

var paused = false
var goal_block = Vector3(0,0,0)
var state = "init"
var turns = [Vector3.FORWARD, Vector3.RIGHT, Vector3.BACK, Vector3.LEFT]
var turn_index = 0

var actions = []
var action_index = -1
var action_complete = false
var kick_time = 0.0
var activate_time = 0.0

func set_goal_block(pos: Vector3):
	goal_block = pos
	goal_outline.translation = pos

func do_action():
	if not is_on_floor():
		# cant complete an action until on the ground
		return
		
	if action_complete:
		action_index += 1
		# pop an action from the queue
		if action_index >= len(actions):
			return
		var action: String = actions[action_index]
		print("next action", action, action_index)
		action_complete = false
		
		if action == "forward":
			goal_block += turns[turn_index]
		if action == "turn-right":
			turn_index = (turn_index + 1) % len(turns)
			action_complete = true
		if action == "turn-left":
			turn_index = (turn_index - 1) % len(turns)
			action_complete = true
		if action == "kick":
			kick_time = 1.0
		if action == "light":
			activate_time = 1.0
			
			# action is NOT complete.
	else:
		pass
		
		

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_state(new_state):
	if new_state != state:
		# print(new_state)
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

	if kick_time > 0:
		anim.play("Kick")
		kick_time -= delta
		if kick_time < 0.5 and abs(domino.omega) < 0.1:
			var dom_dist = domino.translation - self.translation
			dom_dist.y = 0  # this is a cheat
			if dom_dist.length() < 2.0:
				print("kicking domino")
				domino.topple(0.6)
			else:
				print("too far away")
		if kick_time < 0.0:
			print("kick_complete")
			action_complete = true
	
	elif activate_time > 0:
		anim.play("Attack1")
		activate_time -= delta
		if activate_time < 0.0:
			print("activate complete")
			emit_signal("toggle_light", self.translation)
			action_complete = true

	elif dist > 0.8:
		new_state = "fast"
		var direction = dp.normalized() * SPEED
		velocity.x = direction.x
		velocity.z = direction.z
		anim.play("Run-loop")
	elif dist < 0.5 or velocity.length() < 0.1:
		new_state = "stop"
		velocity.x = 0
		velocity.z = 0
		anim.play("Idle-loop")
		action_complete = true
		do_action()
	else:
		new_state = "slow"

	
	if velocity.y < -1:
		anim.play("Fall-loop")
		new_state = "fall"
	
	set_state(new_state)
	velocity = move_and_slide(velocity, Vector3.UP)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.collider.name == "Domino":
			var dist_to_domino = domino.translation - self.translation
			print("bumping domino", dist_to_domino)
			var domino_direction = dist_to_domino.normalized()
			domino.velocity += domino_direction * 1.0
		if collision.collider.name.find("Light") == 0:
			print(collision.collider)
	
	if self.translation.y < -50:
		print("bot respawning...")
		self.translation = Vector3(0, 100, 0)


func _process(_delta):
	pass
