extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const SPEED = 5
var velocity = Vector3.ZERO
var omega = 0.0
var angle = 0.0
const gravity = 9.8
var jump_vel = 5
var goal_angle = 0.0

# Called when the ndode enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func reset():
	rotate_x(-angle)
	angle = 0.0
	omega = 0.0
	velocity = Vector3.ZERO

func topple(x):
	omega = x
#
func _physics_process(delta):
	if is_on_floor():
		velocity.y = 0
	else:
		# If bot is airborne, apply gravity.
		velocity.y -= gravity * delta

	velocity = move_and_slide(velocity, Vector3.UP)
	var delta_angle = 0.0
	if abs(angle) < PI / 2:
		omega += angle * delta
		delta_angle = omega * delta
	else:
		omega = 0.0
		if angle > PI / 2:
			delta_angle = PI / 2 - angle
		elif angle < -PI/2:
			delta_angle = -PI / 2 - angle

	angle += delta_angle
	rotate_x(delta_angle)

	if self.translation.y < -50:
		print("enemy respawning...")
		self.translation = Vector3(0, 100, 0)
		reset()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
##func _process(delta):
##	pass
