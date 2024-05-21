extends Node

signal move
signal sweet_victory
signal tile_targetted

@export var move_time := 0.2

var level_index := 1
var levels: Array[Level] = load("res://resources/level_index.tres").levels

const SAVE_FILE := "user://level_scores.json"

var tilemap: TileMap:
	set(value):
		tilemap = value

		tile_size = tilemap.tile_set.tile_size.x

var tile_size := 0.0

## Loads the next level
func next_level() -> void:
	var level := levels[level_index]

	level_index += 1
	get_tree().change_scene_to_packed(level.scene)

func load_scores() -> Dictionary:
	var best_scores := {}
	if FileAccess.file_exists(SAVE_FILE):
		var text := FileAccess.get_file_as_string(Global.SAVE_FILE)
		# Parse text contents as json
		best_scores = JSON.parse_string(text)

		if best_scores == null:
			push_warning("Unable to read save file")
			best_scores = {}

	return best_scores

## Marks the given level with the score in the user's save file
## Performs no validation on the score provided
func set_score(level_path: String, score: int) -> void:
	var scores := load_scores()
	scores[level_path] = score

	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(scores))
