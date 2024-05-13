extends Node2D

@onready var player = $player

var action_list: Array[Dictionary] = []

func _ready():
	player.did_action.connect(on_player_action)
	save_states()

func save_states() -> void:
	var positions := {}
	for node in get_tree().get_nodes_in_group("track_state"):
		positions[node] = node.global_position
	action_list.append(positions)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("undo"):
		if player.input_lock:
			return
		if action_list.size() == 0:
			print("no actions")
			return

		undo_action()

func on_player_action():
	save_states()

func undo_action() -> void:
	action_list.pop_back()  # Lose the most recent action
	var positions: Dictionary = action_list.pop_back()  # The state to restore

	for node in positions.keys():
		node.global_position = positions[node]

