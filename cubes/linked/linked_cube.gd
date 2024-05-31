@icon("res://cubes/linked/linked_cube.png")
class_name LinkedCube
extends Cube

signal player_entered_side(rot_offset)
signal player_exited_side

@export_range(0, 270, 90, "degrees") var rotate_angle := 90
@export var link_group := ""

func _ready() -> void:
	super()
	add_to_group(link_group)

	# We need to wait for all the others to be added to the scene
	# Should be largely bullet proof unless you put scenes in scenes
	# Dont do that
	await get_owner().ready
	# When the player touches a side sensor, make the other cubes preview that direction
	for linked_cube in get_linked():
		player_entered_side.connect(linked_cube.preview_push)
		player_exited_side.connect(linked_cube.clear_preview)

	# Hide direction preview on win
	Global.sweet_victory.connect(clear_preview)

# Overrides _push to propagate to make all the cubes move
func _push(direction: Vector2i):
	var rotated_direction := rotate_dir(direction)

	if !can_all_move(rotated_direction): return
	if would_links_overlap(direction): return
	if is_moving: return

	for cube in get_linked():
		cube.base_push(rotated_direction)

	super(direction)

func rotate_dir(direction: Vector2i) -> Vector2i:
	return Vector2i(
		Vector2(direction).rotated(deg_to_rad(rotate_angle))
	)

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
		var new_pos: Vector2 = cube.global_position + Vector2(rotate_dir(pos_offset))
		if new_pos in tiles:
			return true
		tiles.append(new_pos)

	return false

func get_linked() -> Array[Node]:
	var linked = get_tree().get_nodes_in_group(link_group)
	# Don't include this cube, since it will move differently
	linked.erase(self)
	return linked

# Direction preview sprite

# The logic here goes:
# When the player enters one of the Area2Ds, it emits a signal with a Vector2i
#  that can be used to work out which direction the player came from
#
# This signal is then propagated to all linked cubes' preview_push, which
#  calculates the direction the cube will move based on where the targeted cube
#  was pushed
# We then preview whatever direction this cube will have to move in

func _on_sensor_area_entered(_area: Area2D, direction: Vector2i) -> void:
	# propagates to preview_push
	player_entered_side.emit(direction)
func _on_sensor_area_exited(_area: Area2D) -> void:
	player_exited_side.emit()

func preview_push(from_dir: Vector2i) -> void:
	# 0deg refers to pushing in the opposite direction to the player
	var to_dir := -from_dir
	preview_direction(rotate_dir(to_dir))

## Set the position/visibility and then play pulse animation
func preview_direction(direction: Vector2i) -> void:
	%DirPreview.position = direction * Global.tile_size
	%DirPreview.rotation = Vector2(direction).angle() - PI / 2

	update_preview_sprite(direction)

	%DirPreviewPlayer.play("pulse")

# This is run either when the cube moves, to update the sprite based on if it
#  could move
func update_preview_sprite(direction: Vector2i) -> void:
	%DirPreview.frame = 0 if can_move(direction) and not would_links_overlap(direction) else 1

func clear_preview() -> void:
	%DirPreviewPlayer.play("RESET")
