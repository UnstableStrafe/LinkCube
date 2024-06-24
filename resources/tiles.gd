extends Node

## The distance from one tile to another
var tile_size := 0.0
## The tilemap from the current scene
var tilemap: TileMap:
	set(value):
		tilemap = value

		tile_size = tilemap.tile_set.tile_size.x


func tile_to_global(coord: Vector2i) -> Vector2:
	return tilemap.to_global(tilemap.map_to_local(coord))

func global_to_tile(position: Vector2) -> Vector2i:
	return tilemap.local_to_map(tilemap.to_local(position))
