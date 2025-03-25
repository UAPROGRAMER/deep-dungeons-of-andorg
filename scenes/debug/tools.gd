extends Node2D

class_name Tools

enum TOOLS_ENUM {
	NONE,
	GROUND,
	STRUCTURES,
	EXITS,
	SAVE
}

signal new_tool_signal(tool: TOOLS_ENUM)

@onready var ground: TileMapLayer = $"../world/ground"
@onready var structures: TileMapLayer = $"../world/structures"
@onready var camera: Camera = $"../world/camera"
@onready var root := get_tree().root

var tool: TOOLS_ENUM = TOOLS_ENUM.NONE
var toolsOff: bool = false

var north: Vector2i = Vector2i(-1, -1)
var south: Vector2i = Vector2i(-1, -1)
var west: Vector2i = Vector2i(-1, -1)
var east: Vector2i = Vector2i(-1, -1)

var point1: Vector2i = Vector2i(-1, -1)
var point2: Vector2i = Vector2i(-1, -1)

var save_rect: Rect2i = Rect2i(-1, -1, 0, 0)

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_line(Vector2i(camera.position.x - 16, 0),
	Vector2i(camera.position.x + root.size.x + 16, 0), Color.RED, 1)
	draw_line(Vector2i(0, camera.position.y - 16),
	Vector2i(0, camera.position.y + root.size.y + 16), Color.GREEN, 1)
	
	if north != Vector2i(-1, -1):
		draw_char(SystemFont.new(), (north+Vector2i.DOWN)*Global.TILE_SIZE, "N", 12, Color.BLUE)
	if south != Vector2i(-1, -1):
		draw_char(SystemFont.new(), (south+Vector2i.DOWN)*Global.TILE_SIZE, "S", 12, Color.RED)
	if west != Vector2i(-1, -1):
		draw_char(SystemFont.new(), (west+Vector2i.DOWN)*Global.TILE_SIZE, "W", 12, Color.YELLOW)
	if east != Vector2i(-1, -1):
		draw_char(SystemFont.new(), (east+Vector2i.DOWN)*Global.TILE_SIZE, "E", 12, Color.GREEN)
	
	if save_rect != Rect2i(-1, -1, 0, 0):
		draw_rect(Rect2i(save_rect.position*Global.TILE_SIZE, save_rect.size*Global.TILE_SIZE),
		Color.AQUA, false)
		print(save_rect.size)

func change_tool(new_tool: TOOLS_ENUM):
	tool = new_tool
	new_tool_signal.emit(new_tool)

func tool_ground(event: InputEvent) -> void:
	var tile_coords := Global.get_tile_coords(get_global_mouse_position())
	if event.is_action_pressed("LMB"):
		ground.set_cell(tile_coords, 0, Vector2i.ZERO)
	elif event.is_action_pressed("RMB"):
		ground.erase_cell(tile_coords)

func tool_structures(event: InputEvent) -> void:
	var tile_coords := Global.get_tile_coords(get_global_mouse_position())
	if event.is_action_pressed("LMB"):
		structures.set_cell(tile_coords, 0, Vector2i.ZERO)
	elif event.is_action_pressed("RMB"):
		structures.erase_cell(tile_coords)

func tool_exits(event: InputEvent) -> void:
	var tile_coords := Global.get_tile_coords(get_global_mouse_position())
	if event.is_action_pressed("One"):
		north = tile_coords
	elif event.is_action_pressed("Two"):
		south = tile_coords
	elif event.is_action_pressed("Three"):
		west = tile_coords
	elif event.is_action_pressed("Four"):
		east = tile_coords

func update_save_rect() -> void:
	save_rect.position = point1
	save_rect.size = point2 - point1 + Vector2i(1, 1)

func save_room() -> void:
	if save_rect.size == Vector2i.ZERO or save_rect.position == Vector2i(-1, -1):
		return
	
	var room := Room.new()
	room.size = save_rect.size
	
	var groundDict: Dictionary[Vector2i, Vector2i] = {}
	for y in range(save_rect.size.y):
		for x in range(save_rect.size.x):
			var tileAtlasCoords := ground.get_cell_atlas_coords(Vector2i(
				x+save_rect.position.x, y+save_rect.position.y))
			if tileAtlasCoords != Vector2i(-1, -1):
				groundDict[Vector2i(x, y)] = tileAtlasCoords
	room.ground = groundDict
	
	var structuresDict: Dictionary[Vector2i, Vector2i] = {}
	for y in range(save_rect.size.y):
		for x in range(save_rect.size.x):
			var tileAtlasCoords := structures.get_cell_atlas_coords(Vector2i(
				x+save_rect.position.x, y+save_rect.position.y))
			if tileAtlasCoords != Vector2i(-1, -1):
				structuresDict[Vector2i(x, y)] = tileAtlasCoords
	room.structures = structuresDict
	
	if save_rect.has_point(north):
		room.north = north - save_rect.position
	if save_rect.has_point(south):
		room.south = south - save_rect.position
	if save_rect.has_point(west):
		room.west = west - save_rect.position
	if save_rect.has_point(east):
		room.east = east - save_rect.position
	
	ResourceSaver.save(room, "res://data/rooms/room1.tres")

func load_room(coords: Vector2i) -> void:
	var room: Room = ResourceLoader.load("res://data/rooms/room1.tres")
	
	for y in range(room.size.y):
		for x in range(room.size.x):
			ground.set_cell(coords + Vector2i(x, y), 0, room.ground[Vector2i(x, y)]
			if room.ground.has(Vector2i(x, y)) else Vector2i(-1, -1))
	
	for y in range(room.size.y):
		for x in range(room.size.x):
			structures.set_cell(coords + Vector2i(x, y), 0, room.structures[Vector2i(x, y)]
			if room.structures.has(Vector2i(x, y)) else Vector2i(-1, -1))

func tool_save(event: InputEvent) -> void:
	var tile_coords := Global.get_tile_coords(get_global_mouse_position())
	if event.is_action_pressed("LMB"):
		point1 = tile_coords
		update_save_rect()
	elif event.is_action_pressed("RMB"):
		point2 = tile_coords
		update_save_rect()
	elif event.is_action_pressed("One"):
		save_room()
	elif event.is_action_pressed("Two"):
		load_room(save_rect.position)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Esc"):
		change_tool(TOOLS_ENUM.NONE)
	
	print(toolsOff)
	if toolsOff:
		return
	
	match tool:
		TOOLS_ENUM.NONE:
			return
		TOOLS_ENUM.GROUND:
			return tool_ground(event)
		TOOLS_ENUM.STRUCTURES:
			return tool_structures(event)
		TOOLS_ENUM.EXITS:
			return tool_exits(event)
		TOOLS_ENUM.SAVE:
			return tool_save(event)
		_:
			return
