extends Control

@export var level: Level
@export var unlocked := false
@export var best_score: int

var level_number := 0

func _ready() -> void:
	level_number = Global.levels.find(level) + 1

	if not unlocked:
		$Button.disabled = true
		$Button.focus_mode = FOCUS_NONE
		$Button.mouse_default_cursor_shape = CURSOR_ARROW

	var text := "%s. %s" % [level_number, level.name]
	if best_score != 0:
		text += "\nBest: " + str(best_score)

	$Button.text = text

func _on_pressed() -> void:
	Global.level_number = level_number

	var mouse_pos := get_global_mouse_position()
	SceneTransition.play_out(mouse_pos)

	await SceneTransition.transition_ended
	get_tree().change_scene_to_packed(level.scene)

	SceneTransition.reveal_player()
