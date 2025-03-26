extends Node2D

class_name Generator

@onready var ground: TileMapLayer = $"../ground"
@onready var structures: TileMapLayer = $"../structures"

func draw_filled_rect(rect: Rect2i, tile_map: TileMapLayer, atlas_coords: Vector2i) -> void:
	for y in range(rect.size.y):
		for x in range(rect.size.x):
			tile_map.set_cell(Vector2i(x, y) + rect.position, 0, atlas_coords)

func draw_corridor(point1: Vector2i, point2: Vector2i, horizontal: bool) -> void:
	var mid := (point1 + point2) / 2
	if horizontal:
		for x in range(min(point1.x, mid.x), max(point1.x, mid.x) + 1):
			structures.erase_cell(Vector2i(x, point1.y))
		for y in range(min(point1.y, point2.y), max(point1.y, point2.y) + 1):
			structures.erase_cell(Vector2i(mid.x, y))
		for x in range(min(mid.x, point2.x), max(mid.x, point2.x) + 1):
			structures.erase_cell(Vector2i(x, point2.y))
	else:
		for y in range(min(point1.y, mid.y), max(point1.y, mid.y) + 1):
			structures.erase_cell(Vector2i(point1.x, y))
		for x in range(min(point1.x, point2.x), max(point1.x, point2.x) + 1):
			structures.erase_cell(Vector2i(x, mid.y))
		for y in range(min(mid.y, point2.y), max(mid.y, point2.y) + 1):
			structures.erase_cell(Vector2i(point2.x, y))

func draw_room(room: Room, coords: Vector2i) -> void:
	for y in range(room.size.y):
		for x in range(room.size.x):
			var pos := Vector2i(x, y)
			if room.ground.has(pos):
				ground.set_cell(pos + coords, 0, room.ground[pos])
			else:
				ground.erase_cell(pos + coords)
			if room.structures.has(pos):
				structures.set_cell(pos + coords, 0, room.structures[pos])
			else:
				structures.erase_cell(pos + coords)

func generate() -> void:
	draw_filled_rect(Rect2i(0, 0, 20, 15), ground, Vector2i.ZERO)
	draw_filled_rect(Rect2i(0, 0, 20, 15), structures, Vector2i.ZERO)
	var room: Room = ResourceLoader.load("res://data/rooms/room1.tres")
	var room1_pos := Vector2i(3, 3)
	var room2_pos := Vector2i(14, 7)
	draw_room(room, room1_pos)
	draw_room(room, room2_pos)
	draw_corridor(room.east + room1_pos, room.west + room2_pos, true)

func _ready() -> void:
	generate()
