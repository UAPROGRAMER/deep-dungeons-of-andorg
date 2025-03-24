extends Control

@onready var tools: Tools = $"../../tools"

func _on_ground_pressed() -> void:
	tools.change_tool(Tools.TOOLS_ENUM.GROUND)

func _on_structures_pressed() -> void:
	tools.change_tool(Tools.TOOLS_ENUM.STRUCTURES)
