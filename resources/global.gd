extends Node

signal sweet_victory
signal tile_targetted

@export var move_time := 0.2

var tilemap: TileMap:
	set(value):
		tilemap = value

		tile_size = tilemap.tile_set.tile_size.x

var tile_size := 0.0
