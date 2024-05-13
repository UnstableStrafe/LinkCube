class_name InvertedLinkedCube
extends Cube

# Overrides _push to propagate to make all the cubes move
func _push(direction: Vector2i):
	if !can_all_move(-direction):
		return
	if is_moving: return

	for cube in get_linked():
		cube.base_push(-direction)

	super(direction)


## Perform _push as defined in the linked cube
## So to not trigger recursive calls
func base_push(direction: Vector2i):
	super._push(direction)


func can_all_move(direction: Vector2i) -> bool:
	return get_linked().all(
		func(cube):
			return cube.can_move(direction)
	)

func get_linked() -> Array[Node]:
	var linked = get_tree().get_nodes_in_group("inverted_linked")
	# Don't include this cube, since it will move differently
	linked.erase(self)
	return linked
