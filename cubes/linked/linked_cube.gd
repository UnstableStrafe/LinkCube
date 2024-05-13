class_name LinkedCube
extends Cube

# Overrides _push to propagate to make all the cubes move
func _push(direction: Vector2i):
	if !can_all_move(direction):
		return
	if is_moving: return

	# get_all_linked() includes this tile as well
	for cube in get_all_linked():
		cube.base_push(direction)

## Perform _push as defined in the linked cube
## So to not trigger recursive calls
func base_push(direction: Vector2i):
	super._push(direction)


func can_all_move(direction: Vector2i) -> bool:
	return get_all_linked().all(
		func(cube):
			return cube.can_move(direction)
	)

func get_all_linked() -> Array[Node]:
	return get_tree().get_nodes_in_group("linked")
