class_name LinkedCube
extends Cube

@export var linked_cubes = []


func _push(direction : Vector2, lerp_time = .2):
	if !can_all_move(direction):
		return
	if is_moving:
		return
	var current_tile: Vector2i = tile_map.local_to_map(global_position)
	var target_tile: Vector2i = Vector2i(current_tile.x + direction.x, current_tile.y + direction.y)
	var tile_data: TileData = tile_map.get_cell_tile_data(0, target_tile)

	if tile_data.get_custom_data("walkable") == false:
		return
	var victory := false
	if tile_data.get_custom_data("goal") and is_goal_cube:
		sweet_victory.emit()
	target_space.emit(target_tile, self)
	for s in linked_cubes:
		var other_cube = get_node(s)
		if !other_cube.can_move(direction):
			return
	linked_push(direction)

	is_moving = true

	var target_position: Vector2 = tile_map.map_to_local(target_tile)
	var tween = create_tween()
	tween.tween_property(self, "global_position",target_position , 0.2).set_trans(Tween.TRANS_SINE)
	await tween.finished

	is_moving = false


func linked_push(direction : Vector2):
	for s in linked_cubes:

		var other_cube = get_node(s)

		var current_tile : Vector2i = other_cube.tile_map.local_to_map(other_cube.global_position)
		var target_tile : Vector2i = Vector2i(current_tile.x + direction.x, current_tile.y + direction.y)
		var tile_data  : TileData = other_cube.tile_map.get_cell_tile_data(0, target_tile)
		var victory := false

		if tile_data.get_custom_data("walkable") == false:
			return
		other_cube.get_node("RayCast2D").target_position = direction * 16
		other_cube.get_node("RayCast2D").force_raycast_update()
		if other_cube.get_node("RayCast2D").is_colliding():
			return

		if tile_data.get_custom_data("goal") and other_cube.is_goal_cube:
			other_cube.sweet_victory.emit()
		target_space.emit(target_tile, self)
		other_cube.is_moving = true

		var target_position: Vector2 = other_cube.tile_map.map_to_local(target_tile)
		var tween = other_cube.create_tween()
		tween.tween_property(other_cube, "global_position",target_position , 0.2).set_trans(Tween.TRANS_SINE)
		#await tween.finished
		other_cube.is_moving = false

func can_all_move(direction : Vector2) -> bool:
	var flag = false
	for s in linked_cubes:
		var other_cube = get_node(s)
		if !other_cube.can_move(direction):
			return flag
		else:
			flag = true
	return flag
