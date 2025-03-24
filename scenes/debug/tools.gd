extends Node2D

class_name Tools

enum TOOLS_ENUM {
	NONE,
	GROUND,
	STRUCTURES
}

signal new_tool_signal(tool: TOOLS_ENUM)

@onready var ground: TileMapLayer = $"../world/ground"
@onready var structures: TileMapLayer = $"../world/structures"

var tool: TOOLS_ENUM = TOOLS_ENUM.NONE

func change_tool(new_tool: TOOLS_ENUM):
	tool = new_tool
	new_tool_signal.emit(new_tool)

func tool_ground(event: InputEvent) -> void:
	if event.is_action_pressed("LMB"):
		var tile_coords := Global.get_tile_coords(get_global_mouse_position())
		print(tile_coords)
		ground.set_cell(tile_coords, 0, Vector2i.ZERO)
	elif event.is_action_pressed("RMB"):
		var tile_coords := Global.get_tile_coords(get_global_mouse_position())
		print(tile_coords)
		ground.erase_cell(tile_coords)

func tool_structures(event: InputEvent) -> void:
	if event.is_action_pressed("LMB"):
		var tile_coords := Vector2i(get_global_mouse_position()/Global.TILE_SIZE)
		structures.set_cell(tile_coords, 0, Vector2i.ZERO)
	elif event.is_action_pressed("RMB"):
		var tile_coords := Vector2i(get_global_mouse_position()/Global.TILE_SIZE)
		structures.erase_cell(tile_coords)

func _input(event: InputEvent) -> void:
	match tool:
		TOOLS_ENUM.NONE:
			return
		TOOLS_ENUM.GROUND:
			return tool_ground(event)
		TOOLS_ENUM.STRUCTURES:
			return tool_structures(event)
