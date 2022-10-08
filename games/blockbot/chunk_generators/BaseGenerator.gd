extends Node
class_name ChunkGenerator

const Chunk = preload("res://Chunk.gd")

static func generate_surface(height, x, y, z):
	if y == 0:
		return "Grass"
	elif x == 0 and z == 0 and y < 2:
		return "Grass"
	else:
		return "Air"

static func generate_details(c, rng, ground_height):
	return
