extends Node2D

class_name Generator

@onready var ground: TileMapLayer = $"../ground"
@onready var structures: TileMapLayer = $"../structures"

var randomGenerator: RandomNumberGenerator

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
			ground.set_cell(Vector2i(x, y) + coords, 0, room.ground[x + y * room.size.x])
			structures.set_cell(Vector2i(x, y) + coords, 0, room.structures[x + y * room.size.x])

func make_minimap(length: int) -> Array[Array]:
	var minimap: Array[Array] = []
	for y in range(length * 2 + 1):
		minimap.append([])
		for x in range(length * 2 + 1):
			minimap[y].append(0)
	
	var current_point: Vector2i = Vector2i(length, length) / 2
	
	for i in range(length):
		minimap[current_point.y][current_point.x] = 1
		if randomGenerator.randi_range(0, 1) == 0:
			current_point.x += 1
		else:
			current_point.y += 1
	
	return minimap

func draw_minimap(minimap: Array[Array]) -> void:
	for y in range(minimap.size()):
		for x in range(minimap.size()):
			structures.set_cell(Vector2i(x, y), 0, Vector2i(-1, -1) if minimap[y][x] == 0 else Vector2i.ZERO)

func generate() -> void:
	randomGenerator = RandomNumberGenerator.new()
	var minimap := make_minimap(5)
	draw_minimap(minimap)
	print(minimap)

func _ready() -> void:
	generate()
