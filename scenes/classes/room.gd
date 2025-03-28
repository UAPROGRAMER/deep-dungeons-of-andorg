extends Resource

class_name Room

@export var size: Vector2i
@export var ground: Array[Vector2i] = []
@export var structures: Array[Vector2i] = []

@export var north: Vector2i = Vector2i(-1, -1)
@export var south: Vector2i = Vector2i(-1, -1)
@export var west: Vector2i = Vector2i(-1, -1)
@export var east: Vector2i = Vector2i(-1, -1)

func _to_string() -> String:
	return "ROOM(size: " + str(size) + "; ground: " + str(ground) + "; structures: " + str(structures) + \
	"; north: " + str(north) + "; south: " + str(south) + "; west: " + str(west) + "; east: " + str(east) + ")"
