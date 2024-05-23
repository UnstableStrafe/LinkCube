class_name InvertedLinkedCube
extends Cube

signal player_entered_side(direction)
signal player_exited_side

func _ready() -> void:
	super()
	finished_moving.connect(update_preview)
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
	print(direction)

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

func update_preview() -> void:
	var dir = $DirPreview.get_position() / 16
	if can_move(dir):
		$DirPreview.frame = 0
	else:
		$DirPreview.frame = 1
	

func preview_direction(direction: Vector2i) -> void:
	%DirPreview.position = direction * Global.tile_size
	match direction:
			Vector2i(0, 1):
				%DirPreview.rotation_degrees = 0
			Vector2i(-1, 0):
				%DirPreview.rotation_degrees = 90
			Vector2i(0, -1):
				%DirPreview.rotation_degrees = 180
			Vector2i(1, 0):
				%DirPreview.rotation_degrees = 270
	if can_move(direction):
		$DirPreview.frame = 0
	else:
		$DirPreview.frame = 1
	%DirPreview.show()
	

func clear_preview() -> void:
	%DirPreview.hide()
