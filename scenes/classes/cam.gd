extends Camera2D

class_name Camera

@export var speed: int = 300

func _process(delta: float) -> void:
	var direction := Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down")) \
	.normalized()
	position += direction*delta*speed

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ZoomOut"):
		zoom /= 2
	elif event.is_action_pressed("ZoomIn"):
		zoom *= 2
