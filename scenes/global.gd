extends Node

const TILE_SIZE := 16

func get_tile_coords(coords: Vector2i) -> Vector2i:
	var tile_coords := coords / TILE_SIZE
	tile_coords -= Vector2i(int(coords.x < 0), int(coords.y < 0))
	return tile_coords
