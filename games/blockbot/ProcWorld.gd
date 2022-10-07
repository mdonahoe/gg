extends Spatial
var height_noise = OpenSimplexNoise.new()

onready var Chunk = load("res://Chunk.gd")

# Thread variables No reason to declare these on startup just do it up here
var thread = Thread.new()
var bKill_thread = false

#Use this when adding/removing from the chunk array/dict
var chunk_mutex = Mutex.new()

var _new_chunk_pos = Vector2()
var _chunk_pos = null
var _loaded_chunks = {}
var _last_chunk = Vector2()

var _kill_thread = false

const load_radius = 5
var current_load_radius = 0

func _ready():	
	thread.start(self, "_thread_gen")
	height_noise.period = 100


func _thread_gen(userdata):
	var loop_counter = 0
	# Center map generation on the player
	var start_loop_time = Time.get_ticks_usec()
	while(!bKill_thread):
		var now = Time.get_ticks_usec()
		var dt = now - start_loop_time
		if dt > 1000000:
			var loops_per_sec = loop_counter * 1000000.0 / dt
			print("fps = %f" % loops_per_sec)
			loop_counter = 0
			start_loop_time = now
		# Check if player in new chunk
		var player_pos_updated = false
		player_pos_updated = _new_chunk_pos != _chunk_pos
		
		# Make sure we aren't making a shallow copy
		_chunk_pos = Vector2(_new_chunk_pos.x, _new_chunk_pos.y)
		var current_chunk_pos = Vector2(_new_chunk_pos.x, _new_chunk_pos.y)
		loop_counter += 1
		if player_pos_updated:
			# If new chunk unload unneeded chunks (changed to be entirely done off main thread if I understand correctly, fixling some stuttering I was feeling
			enforce_render_distance(current_chunk_pos)
			# Make sure player chunk is loaded
			_last_chunk = _load_chunk(current_chunk_pos.x, current_chunk_pos.y)
			current_load_radius = 1
		else:
			# Load next chunk based on the position of the last one
			var delta_pos = _last_chunk - current_chunk_pos
			# Only have player chunk
			if delta_pos == Vector2():
				# Move down one
				_last_chunk = _load_chunk(_last_chunk.x, _last_chunk.y + 1)
			elif delta_pos.x < delta_pos.y:
				# Either go right or up
				# Prioritize going right
				if delta_pos.y == current_load_radius and -delta_pos.x != current_load_radius:
					# Go right
					_last_chunk = _load_chunk(_last_chunk.x - 1, _last_chunk.y)
				# Either moving in constant x or we just reached bottom right
				elif -delta_pos.x == current_load_radius or -delta_pos.x == delta_pos.y:
					# Go up
					_last_chunk = _load_chunk(_last_chunk.x, _last_chunk.y - 1)
				else:
					# We increment here idk why
					if current_load_radius < load_radius:
						current_load_radius += 1
			else:
				# Either go left or down
				# Prioritize going left
				if -delta_pos.y == current_load_radius and delta_pos.x != current_load_radius:
					# Go left
					_last_chunk = _load_chunk(_last_chunk.x + 1, _last_chunk.y)
				elif delta_pos.x == current_load_radius or delta_pos.x == -delta_pos.y:
					# Go down
					# Stop the last one where we'd go over the limit
					if delta_pos.y < load_radius:
						_last_chunk = _load_chunk(_last_chunk.x, _last_chunk.y + 1)

func update_player_pos(new_pos):
	_new_chunk_pos = new_pos

func change_block(cx, cz, bx, by, bz, t):
	var c = _loaded_chunks[Vector2(cx, cz)]
	if c._block_data[bx][by][bz].type != t:
		print("Changed block at %d %d %d in chunk %d, %d" % [bx, by, bz, cx, cz])
		c._block_data[bx][by][bz].create(t)
		_update_chunk(cx, cz)

func _load_chunk(cx, cz):
	cx = clamp(cx, -1, 1)
	cz = clamp(cz, -1, 1)
	var c_pos = Vector2(cx, cz)
	if not _loaded_chunks.has(c_pos):
		print("creating new chunk %d %d" % [cx, cz])
		var c = Chunk.new()
		c.generate(self, cx, cz)
		c.update()
		add_child(c)
		chunk_mutex.lock()
		_loaded_chunks[c_pos] = c
		chunk_mutex.unlock()
	return c_pos

func _update_chunk(cx, cz):
	var c_pos = Vector2(cx, cz)
	if _loaded_chunks.has(c_pos):
		var c = _loaded_chunks[c_pos]
		c.update()
	return c_pos
	
# Detects and removes chunks all in one go without consulting the main thread.
func enforce_render_distance(current_chunk_pos):
		#Checks and deletes the offending chunks all in one go 
	for v in _loaded_chunks.keys():
		# Anywhere you directly interface with chunks outside of unloading
		if abs(v.x - current_chunk_pos.x) > load_radius or abs(v.y - current_chunk_pos.y) > load_radius:
			chunk_mutex.lock()
			print("erasing chunk %d %d" % [v.x, v.y])
			_loaded_chunks[v].free()
			_loaded_chunks.erase(v)
			chunk_mutex.unlock()


func _unload_chunk(cx, cz):
	# TODO(matt): Is this ever called?
	print("unloading chunk %d %d" % [cx, cz])
	var c_pos = Vector2(cx, cz)
	if _loaded_chunks.has(c_pos):
		chunk_mutex.lock()
		_loaded_chunks[c_pos].free()
		_loaded_chunks.erase(c_pos)
		chunk_mutex.unlock()
		# Leaving this here because it is funny as hell
		# Force it to just fucking chill after holy shit
		# OS.delay_msec(50)

func kill_thread():
	bKill_thread = true
