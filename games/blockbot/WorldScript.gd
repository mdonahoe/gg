extends Spatial

# NOTE(matt): this line would allow the script to run in the editor.
# tool

var pw
onready var player = $Player
onready var block_outline = $BlockOutline
onready var bot = $Bot

onready var light1 = $LightBlock1
onready var light2 = $LightBlock2
onready var light3 = $LightBlock3
onready var light4 = $LightBlock4

onready var lights = [light1, light2, light3, light4]

var Chunk = load("res://Chunk.gd")
var ProcWorld = load("res://ProcWorld.gd")


var chunk_pos = Vector2()

func _ready():
	print("CREATING WORLD")
	pw = ProcWorld.new()
	add_child(pw)
	
	player.connect("place_block", self, "_on_Player_place_block")
	player.connect("destroy_block", self, "_on_Player_destroy_block")
	player.connect("highlight_block", self, "_on_Player_highlight_block")
	player.connect("unhighlight_block", self, "_on_Player_unhighlight_block")
	player.connect("dead", self, "_on_Player_dead")
	
	bot.connect("toggle_light", self, "_on_Bot_toggle_light")
	
	# TODO(matt): wtf is this?
	self.connect("tree_exiting", self, "_on_WorldScript_tree_exiting")
	light1.translation = Vector3(10.5, 0.6, 0.5)
	light2.translation = Vector3(10.5, 0.6, 20.5)
	light3.translation = Vector3(30.5, 0.6, -15.5)
	light4.translation = Vector3(5.5, 0.6, 0.5)

func _process(delta):
	# Check the players chunk position and see if it has changed
	if player != null and pw != null and pw.chunk_mutex != null:
		var player_pos = player.translation
		var chunk_x = floor(player.translation.x / Chunk.DIMENSION.x)
		var chunk_z = floor(player.translation.z / Chunk.DIMENSION.z)
		var new_chunk_pos = Vector2(chunk_x, chunk_z)
	
		# If its a new chunk update for the ProcWorld thread
		if new_chunk_pos != chunk_pos:
			chunk_pos = new_chunk_pos
			pw.call_deferred("update_player_pos", chunk_pos)

func _on_WorldScript_tree_exiting():
	print("Kill map loading thread")
	if pw != null:
		pw.call_deferred("kill_thread")
	print("Finished")


func _on_Bot_toggle_light(pos):
	print("bot toggled at ", pos)
	for light in lights:
		var dist = (light.translation - pos).length()
		if dist < 1.0:
			print("did toggle: ", light)
			light.translation.y += 1
	# and create a block at the bots position
	
	# Get chunk from pos
	var cx = int(floor(pos.x / Chunk.DIMENSION.x))
	var cz = int(floor(pos.z / Chunk.DIMENSION.z))

	# Get block from pos
	var bx = fposmod(floor(pos.x), Chunk.DIMENSION.x) + 0.5
	var by = fposmod(floor(pos.y), Chunk.DIMENSION.y) + 0.5
	var bz = fposmod(floor(pos.z), Chunk.DIMENSION.z) + 0.5
	var t = "Log"
	pw.call_deferred("change_block", cx, cz, bx, by, bz, t)



func _on_Player_dead(pos):
	print("Player died at", pos)
	# reset the chunk where the player died.
	var cx = int(floor(pos.x / Chunk.DIMENSION.x))
	var cz = int(floor(pos.z / Chunk.DIMENSION.z))
	pw._unload_chunk(cx, cz)
	pw._load_chunk(cx, cz)

func _on_Player_destroy_block(pos, norm):
	# Take a half step into the block
	pos -= norm * 0.5

	
	# Get chunk from pos
	var cx = int(floor(pos.x / Chunk.DIMENSION.x))
	var cz = int(floor(pos.z / Chunk.DIMENSION.z))
	
	# Get block from pos
	var bx = fposmod(floor(pos.x), Chunk.DIMENSION.x) + 0.5
	var by = fposmod(floor(pos.y), Chunk.DIMENSION.y) + 0.5
	var bz = fposmod(floor(pos.z), Chunk.DIMENSION.z) + 0.5
	pw.call_deferred("change_block", cx, cz, bx, by, bz, "Air")

func _on_Player_place_block(pos, norm, t):
	# Take a half step out of the block
	pos += norm * 0.5
	
#	# Get chunk from pos
#	var cx = int(floor(pos.x / Chunk.DIMENSION.x))
#	var cz = int(floor(pos.z / Chunk.DIMENSION.z))
#
#	# Get block from pos
#	var bx = fposmod(floor(pos.x), Chunk.DIMENSION.x) + 0.5
#	var by = fposmod(floor(pos.y), Chunk.DIMENSION.y) + 0.5
#	var bz = fposmod(floor(pos.z), Chunk.DIMENSION.z) + 0.5
#	# NOTE(matt): right-click to move the bot rather than create a block.
#	# pw.call_deferred("change_block", cx, cz, bx, by, bz, t)
	
	var bx = floor(pos.x) + 0.5
	var by = floor(pos.y) + 0.5
	var bz = floor(pos.z) + 0.5
	
	var block = Vector3(bx, by, bz)
	
	bot.set_goal_block(block)
	bot.action_index = -1


func _on_Player_highlight_block(pos, norm):
	block_outline.visible = true
	
	# Take a half step into the block
	pos -= norm * 0.5
	
	var bx = floor(pos.x) + 0.5
	var by = floor(pos.y) + 0.5
	var bz = floor(pos.z) + 0.5
	
	block_outline.translation = Vector3(bx, by, bz)

func _on_Player_unhighlight_block():
	block_outline.visible = false
