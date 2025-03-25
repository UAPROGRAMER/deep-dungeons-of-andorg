extends Control

@onready var label: Label = $label

func _on_tools_new_tool_signal(tool: Tools.TOOLS_ENUM) -> void:
	label.text = "Tool: "
	match tool:
		Tools.TOOLS_ENUM.NONE:
			label.text += "NONE"
		Tools.TOOLS_ENUM.GROUND:
			label.text += "GROUND"
		Tools.TOOLS_ENUM.STRUCTURES:
			label.text += "STRUCTURES"
		Tools.TOOLS_ENUM.EXITS:
			label.text += "EXITS"
		Tools.TOOLS_ENUM.SAVE:
			label.text += "SAVE"
		_:
			label.text += "???"
