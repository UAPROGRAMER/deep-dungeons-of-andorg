extends Control

@onready var tools: Tools = $"../../tools"

func _on_ground_pressed() -> void:
	tools.change_tool(Tools.TOOLS_ENUM.GROUND)

func _on_structures_pressed() -> void:
	tools.change_tool(Tools.TOOLS_ENUM.STRUCTURES)

func _on_exits_pressed() -> void:
	tools.change_tool(Tools.TOOLS_ENUM.EXITS)

func _on_save_pressed() -> void:
	tools.change_tool(Tools.TOOLS_ENUM.SAVE)

func _on_corridor_pressed() -> void:
	tools.change_tool(Tools.TOOLS_ENUM.CORRIDORS)

func _on_mouse_entered() -> void:
	tools.toolsOff = true

func _on_mouse_exited() -> void:
	tools.toolsOff = false
