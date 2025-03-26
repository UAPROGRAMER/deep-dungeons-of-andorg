extends VBoxContainer

func _on_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")

func _on_debug_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/debug/debug.tscn")
