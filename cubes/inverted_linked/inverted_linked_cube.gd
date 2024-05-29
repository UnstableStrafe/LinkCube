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
	if not can_all_move(-direction): return
	if would_links_overlap(direction): return
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

## Prevent cubes from overlapping on the same tile space
func would_links_overlap(direction: Vector2i) -> bool:
	var pos_offset := Vector2(direction) * Global.tile_size
	var tiles := [global_position + pos_offset]

	# Gradually add each new position to the array
	# If the position already exists then there would be a overlap
	for cube in get_linked():
		# The - is important here +(-direction)
		var new_pos: Vector2 = cube.global_position - pos_offset
		if new_pos in tiles:
			return true
		tiles.append(new_pos)

	return false

func get_linked() -> Array[Node]:
	var linked = get_tree().get_nodes_in_group("inverted_linked")
	# Don't include this cube, since it will move differently
	linked.erase(self)
	return linked

# Direction preview sprite

func _on_sensor_area_entered(_area: Area2D, direction: Vector2i) -> void:
	player_entered_side.emit(direction)
func _on_sensor_area_exited(_area: Area2D) -> void:
	player_exited_side.emit()

## Set the position/visibility and then play pulse animation
func preview_direction(direction: Vector2i) -> void:
	$DirPreview.position = direction * Global.tile_size
	$DirPreview.rotation = Vector2(direction).angle() - PI / 2

	update_preview_sprite(direction)

	%DirPreviewPlayer.play("pulse")

func update_preview_sprite(direction: Vector2i) -> void:
	$DirPreview.frame = 0 if can_move(direction) and not would_links_overlap(direction) else 1

func clear_preview() -> void:
	%DirPreviewPlayer.play("RESET")
