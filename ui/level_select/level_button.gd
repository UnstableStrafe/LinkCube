extends Control

@export var level: Level
@export var unlocked := false
@export var best_score: int


func _ready() -> void:
	var index := Global.levels.find(level) + 1

	if not unlocked:
		$Button.disabled = true
		$Button.focus_mode = FOCUS_NONE
		$Button.mouse_default_cursor_shape = CURSOR_ARROW

	var text := "%s. %s" % [index, level.name]
	if best_score != 0:
		text += "\nBest: " + str(best_score)

	$Button.text = text

func _on_pressed() -> void:
	get_tree().change_scene_to_packed(level.scene)
