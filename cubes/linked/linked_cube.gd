class_name LinkedCube
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

func get_linked() -> Array[Node]:
	var cubes := get_all_linked()
	cubes.erase(self)
	return cubes

# Direction preview sprite

func _on_sensor_area_entered(_area: Area2D, direction: Vector2i) -> void:
	player_entered_side.emit(direction)
func _on_sensor_area_exited(_area: Area2D) -> void:
	player_exited_side.emit()

## Set the position/visibility and then play pulse animation
func preview_direction(direction: Vector2i) -> void:
	print(direction)
	%DirPreview.position = direction * Global.tile_size
	%DirPreview.rotation = Vector2(direction).angle() - PI / 2

	update_preview_sprite(direction)

	%DirPreviewPlayer.play("pulse")

func update_preview_sprite(direction: Vector2i) -> void:
	%DirPreview.frame = 0 if can_move(direction) else 1

func clear_preview() -> void:
	%DirPreviewPlayer.play("RESET")
