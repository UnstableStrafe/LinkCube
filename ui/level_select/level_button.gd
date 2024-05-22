extends Control

@export var level: Level
@export var unlocked := false
@export var best_score: int

var level_index := 0

func _ready() -> void:
	level_index = Global.levels.find(level) + 1

	if not unlocked:
		$Button.disabled = true
		$Button.focus_mode = FOCUS_NONE
		$Button.mouse_default_cursor_shape = CURSOR_ARROW

	var text := "%s. %s" % [level_index, level.name]
	if best_score != 0:
		text += "\nBest: " + str(best_score)

	$Button.text = text

func _on_pressed() -> void:
	Global.level_index = level_index
	get_tree().change_scene_to_packed(level.scene)
