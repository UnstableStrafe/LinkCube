class_name RotatedLinkedCube
extends Cube

# Overrides _push to propagate to make all the cubes move
func _push(direction: Vector2i):
	var rotated_direction
	match Vector2(direction):
		Vector2.DOWN:
			rotated_direction = Vector2.LEFT
		Vector2.UP:
			rotated_direction = Vector2.RIGHT
		Vector2.LEFT:
			rotated_direction = Vector2.UP
		Vector2.RIGHT:
			rotated_direction = Vector2.DOWN
	if !can_all_move(rotated_direction):
		return
	if is_moving: return
	
	for cube in get_linked():
		cube.base_push(rotated_direction)

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
	var linked = get_tree().get_nodes_in_group("rotated_linked")
	# Don't include this cube, since it will move differently
	linked.erase(self)
	return linked
