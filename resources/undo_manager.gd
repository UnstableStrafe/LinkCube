extends Node

@export var player: Player

var states: Array[Dictionary] = []

func _ready():
	player.did_action.connect(_on_player_did_action)

# Can't do this in ready because the StateTrackers won't necessarily be in the group yet.
# If this is linked to a common ancestor's ready signal then it will fire when
# everything is ready and nodes have been added to groups
func _on_tree_ready() -> void:
	# Save all initial states
	save_states()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("undo"):
		if player.input_lock: return
		if states.size() <= 1: return

		undo_action()

	elif event.is_action_pressed("restart"):
		get_tree().reload_current_scene()

func _on_player_did_action():
	save_states()

func save_states() -> void:
	var snapshot := {}
	for state_tracker in get_tree().get_nodes_in_group(StateTracker.GROUP):
		snapshot[state_tracker] = state_tracker.save_states()

	states.append(snapshot)

func undo_action() -> void:
	states.pop_back()  # Remove the current state
	var snapshot := states[-1]  # Get previous state

	for state_tracker in snapshot.keys():
		state_tracker.restore_state(snapshot[state_tracker])
