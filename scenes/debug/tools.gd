extends Node2D

class_name Tools

enum TOOLS_ENUM {
	NONE,
	MOVE,
	GROUND,
	STRUCTURES,
	EXITS,
	SAVE,
	CORRIDORS
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

var save_point1: Vector2i = Vector2i(-1, -1)
var save_point2: Vector2i = Vector2i(-1, -1)

var save_rect: Rect2i = Rect2i(-1, -1, 0, 0)

var corridor_point1: Vector2i = Vector2i(-1, -1)
var corridor_point2: Vector2i = Vector2i(-1, -1)

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_line(Vector2i(camera.position.x - 16, 0),
	Vector2i(camera.position.x + root.size.x + 16, 0), Color.RED, 1)
	draw_line(Vector2i(0, camera.position.y - 16),
	Vector2i(0, camera.position.y + root.size.y + 16), Color.GREEN, 1)
	
	if corridor_point1 != Vector2i(-1, -1):
		draw_char(SystemFont.new(), (corridor_point1+Vector2i.DOWN)*Global.TILE_SIZE, "1", 12, Color.BLUE)
	if corridor_point2 != Vector2i(-1, -1):
		draw_char(SystemFont.new(), (corridor_point2+Vector2i.DOWN)*Global.TILE_SIZE, "2", 12, Color.BLUE)
	
	if north != Vector2i(-1, -1):
		draw_char(SystemFont.new(), (north+Vector2i.DOWN)*Global.TILE_SIZE, "N", 12, Color.CYAN)
	if south != Vector2i(-1, -1):
		draw_char(SystemFont.new(), (south+Vector2i.DOWN)*Global.TILE_SIZE, "S", 12, Color.CYAN)
	if west != Vector2i(-1, -1):
		draw_char(SystemFont.new(), (west+Vector2i.DOWN)*Global.TILE_SIZE, "W", 12, Color.CYAN)
	if east != Vector2i(-1, -1):
		draw_char(SystemFont.new(), (east+Vector2i.DOWN)*Global.TILE_SIZE, "E", 12, Color.CYAN )
	
	if save_rect != Rect2i(-1, -1, 0, 0):
		draw_rect(Rect2i(save_rect.position*Global.TILE_SIZE, save_rect.size*Global.TILE_SIZE),
		Color.AQUA, false)

func change_tool(new_tool: TOOLS_ENUM):
	tool = new_tool
	new_tool_signal.emit(new_tool)

func tool_move(event: InputEvent) -> void:
	pass

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
	save_rect.position = save_point1
	save_rect.size = save_point2 - save_point1 + Vector2i(1, 1)

func save_room() -> void:
	if save_rect.size == Vector2i.ZERO or save_rect.position == Vector2i(-1, -1):
		return
	
	var room := Room.new()
	room.size = save_rect.size
	
	for y in range(save_rect.size.y):
		for x in range(save_rect.size.x):
			room.ground.append(ground.get_cell_atlas_coords(Vector2i(x, y) + save_rect.position))
			room.structures.append(structures.get_cell_atlas_coords(Vector2i(x, y)  + save_rect.position))
	
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
			ground.set_cell(coords + Vector2i(x, y), 0, room.ground[x + y * room.size.x])
			structures.set_cell(coords + Vector2i(x, y), 0, room.structures[x + y * room.size.x])

func tool_save(event: InputEvent) -> void:
	var tile_coords := Global.get_tile_coords(get_global_mouse_position())
	if event.is_action_pressed("LMB"):
		save_point1 = tile_coords
		update_save_rect()
	elif event.is_action_pressed("RMB"):
		save_point2 = tile_coords
		update_save_rect()
	elif event.is_action_pressed("One"):
		save_room()
	elif event.is_action_pressed("Two"):
		load_room(save_rect.position)

func draw_corridor(horizontal: bool) -> void:
	var mid := (corridor_point1 + corridor_point2) / 2
	if horizontal:
		for x in range(min(corridor_point1.x, mid.x), max(corridor_point1.x, mid.x) + 1):
			ground.set_cell(Vector2i(x, corridor_point1.y), 0, Vector2i.ZERO)
		
		for y in range(min(corridor_point1.y, corridor_point2.y), max(corridor_point1.y, corridor_point2.y) + 1):
			ground.set_cell(Vector2i(mid.x, y), 0, Vector2i.ZERO)
		
		for x in range(min(mid.x, corridor_point2.x), max(mid.x, corridor_point2.x) + 1):
			ground.set_cell(Vector2i(x, corridor_point2.y), 0, Vector2i.ZERO)
	else:
		for y in range(min(corridor_point1.y, mid.y), max(corridor_point1.y, mid.y) + 1):
			ground.set_cell(Vector2i(corridor_point1.x, y), 0, Vector2i.ZERO)
		
		for x in range(min(corridor_point1.x, corridor_point2.x), max(corridor_point1.x, corridor_point2.x) + 1):
			ground.set_cell(Vector2i(x, mid.y), 0, Vector2i.ZERO)
		
		for y in range(min(mid.y, corridor_point2.y), max(mid.y, corridor_point2.y) + 1):
			ground.set_cell(Vector2i(corridor_point2.x, y), 0, Vector2i.ZERO)

func tool_corridors(event: InputEvent) -> void:
	var tile_coords := Global.get_tile_coords(get_global_mouse_position())
	if event.is_action_pressed("LMB"):
		corridor_point1 = tile_coords
	elif event.is_action_pressed("RMB"):
		corridor_point2 = tile_coords
	elif event.is_action_pressed("One"):
		draw_corridor(true)
	elif event.is_action_pressed("Two"):
		draw_corridor(false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Esc"):
		change_tool(TOOLS_ENUM.NONE)
	
	if toolsOff:
		return
	
	match tool:
		TOOLS_ENUM.NONE:
			return
		TOOLS_ENUM.MOVE:
			return
		TOOLS_ENUM.GROUND:
			return tool_ground(event)
		TOOLS_ENUM.STRUCTURES:
			return tool_structures(event)
		TOOLS_ENUM.EXITS:
			return tool_exits(event)
		TOOLS_ENUM.SAVE:
			return tool_save(event)
		TOOLS_ENUM.CORRIDORS:
			return tool_corridors(event)
		_:
			return
