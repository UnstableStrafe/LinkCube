@icon("res://resources/nodes/state_tracker.svg")
class_name StateTracker
extends Node

@export var tracked_properties: Array[NodePath] = []

const GROUP = "state_trackers"

func _ready() -> void:
	add_to_group(GROUP)

func save_states() -> Dictionary:
	var state := {}

	for property_path in tracked_properties:
		state[property_path] = _resolve_nodepath(property_path)

	return state

## Returns the value a given nodepath points to
func _resolve_nodepath(nodepath: NodePath) -> Variant:
	var node_component := NodePath(nodepath.get_concatenated_names())
	var node := get_node(node_component)

	if not is_instance_valid(node): return null

	var subname_component := NodePath(nodepath.get_concatenated_subnames())
	return node.get_indexed(subname_component)

func restore_state(state: Dictionary) -> void:
	for property_path in state:
		_set_nodepath(property_path, state[property_path])

## Sets the property of a nodepath
func _set_nodepath(nodepath: NodePath, what: Variant) -> void:
	var node_component := NodePath(nodepath.get_concatenated_names())
	var node := get_node(node_component)

	if not is_instance_valid(node): return

	var subname_component := NodePath(nodepath.get_concatenated_subnames())
	node.set_indexed(subname_component, what)
