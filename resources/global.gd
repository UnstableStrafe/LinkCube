extends Node

signal move
signal sweet_victory
signal tile_targetted

var move_time := 0.2
var level_index := 1
var levels: Array[Level] = load("res://resources/level_index.tres").levels

const SAVE_FILE := "user://level_scores.json"
const SETTINGS_FILE := "user://settings.cfg"
const DEFAULT_SETTINGS_PATH := "res://ui/settings/settings.cfg"

func _ready() -> void:
	# Apply saved settings or defaults
	var path := SETTINGS_FILE if FileAccess.file_exists(SETTINGS_FILE) else DEFAULT_SETTINGS_PATH

	var settings := Settings.from_file(path)
	settings.apply()

## Loads the next level
func next_level() -> void:
	# level_index technically isn't the index but the level number
	#  (level_index - 1) = The actual index
	#  (level_index - 1) + 1 = The next level
	var level := levels[level_index]

	level_index += 1
	get_tree().change_scene_to_packed(level.scene)

## Serialisation ##

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

