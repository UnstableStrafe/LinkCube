extends Node2D

var can_progress := false
var move_count := 0

@onready var player = %Player
@onready var high_score := _get_high_score()

func _ready():
	Global.tilemap = $TileMap
	Global.sweet_victory.connect(_on_win, CONNECT_ONE_SHOT)

func _on_win():
	can_progress = true
	player.input_lock = true
	%NextLevelPrompt.visible = true

	# Save move count
	_save_score()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("next_level") and can_progress:
		Global.next_level()

func _on_undo_manager_move_count_changed(moves: Variant) -> void:
	move_count = moves

	%MoveCount.text = str(move_count)

func _get_high_score() -> int:
	var high_scores := Global.load_scores()
	if high_scores.has(scene_file_path):
		return high_scores[scene_file_path]
	else:
		return 0

## Save the current move count to the user save file
func _save_score() -> void:
	if high_score == 0 or move_count < high_score:
		Global.set_score(scene_file_path, move_count)
