extends Node

var tile_size := 0.0
var tilemap: TileMap:
	set(value):
		tilemap = value

		tile_size = tilemap.tile_set.tile_size.x

func global_to_tile(global_position: Vector2) -> Vector2i:
	return tilemap.local_to_map(tilemap.to_local(global_position))

func tile_to_global(tile: Vector2i) -> Vector2:
	return tilemap.to_global(tilemap.map_to_local(tile))
