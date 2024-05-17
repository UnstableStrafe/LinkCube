extends Node

@export var player: Player

var action_list: Array[Dictionary] = []

func _ready():
	player.did_action.connect(_on_player_did_action)
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
		if action_list.size() <= 1:
			print("no actions")
			return

		undo_action()

	elif event.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func _on_player_did_action():
	save_states()

func undo_action() -> void:
	action_list.pop_back()  # Remove the current state
	var positions: Dictionary = action_list[-1]  # Restore previous state

	for node in positions.keys():
		node.global_position = positions[node]

