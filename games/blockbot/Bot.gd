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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass



func _physics_process(delta):	
	var cx = floor(self.translation.x / Chunk.DIMENSION.x)
	var cz = floor(self.translation.z / Chunk.DIMENSION.z)
	var px = self.translation.x - cx * Chunk.DIMENSION.x
	var py = self.translation.y
	var pz = self.translation.z - cz * Chunk.DIMENSION.z
	var snap = Vector3(px, py, pz)
	var chunk_center = Vector3(floor(self.translation.x), self.translation.y, floor(self.translation.z))
	if not paused:
		if is_on_floor():  # TODO(matt): why doesn't the bot fall?
			# TODO(matt): this works ok, but it would be better to check the grid explicitly
			# Currently the bot can fly in the air if the goal_block is below the bot's feet.
			# We'd rather have the bot move gracefully to the center of the closest block.
			# without jumping up or down a level.
			velocity.y = 0
			var dp = goal_block - self.translation
			dp.y = 0
			if dp.length() > 0.5:
				# TODO(matt): rotate the bot in the cardinal direction that best aligns with dp.
				move_and_collide(dp * delta)
				anim.play("Run-loop")
			else:
				anim.play("Idle-loop")
		else:
			velocity.y -= gravity * delta
			velocity = move_and_slide(velocity, Vector3.UP)
			anim.play("Fall-loop")


func _process(delta):
	pass
