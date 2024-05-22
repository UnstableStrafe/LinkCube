class_name InvertedLinkedCube
extends Cube

signal player_entered_side(direction)
signal player_exited_side

func _ready() -> void:
	super()

	# When the player touches a side sensor, make the other cubes preview that direction
	for linked_cube in get_linked():
		player_entered_side.connect(linked_cube.preview_direction)
		player_exited_side.connect(linked_cube.clear_preview)

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

func _on_sensor_area_entered(_area: Area2D, direction: Vector2i) -> void:
	player_entered_side.emit(direction)

func _on_sensor_area_exited(_area: Area2D) -> void:
	player_exited_side.emit()

func preview_direction(direction: Vector2i) -> void:
	%DirPreview.position = direction * Global.tile_size
	%DirPreview.show()

func clear_preview() -> void:
	%DirPreview.hide()
