class_name InvertedLinkedCube
extends PushableCube

@export var linked_cubes = []


# Called when the node enters the scene tree for the first time.
func _ready():
	if is_goal_cube:
		crown.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

func _push(direction : Vector2, lerp_time = .2):
	if !can_all_move(-direction):
		return
	if is_moving:
		return
	var current_tile : Vector2i = tile_map.local_to_map(global_position)
	var target_tile : Vector2i = Vector2i(current_tile.x + direction.x, current_tile.y + direction.y)
	var tile_data  : TileData = tile_map.get_cell_tile_data(0, target_tile)
	
	if tile_data.get_custom_data("walkable") == false:
		return
	var victory := false
	if tile_data.get_custom_data("goal") and is_goal_cube:
		victory = true

	_ray_cast_2d.target_position = direction * 16
	_ray_cast_2d.force_raycast_update()
	if _ray_cast_2d.is_colliding():
		return
	for s in linked_cubes:
		var other_cube = get_node(s)
		other_cube._ray_cast_2d.target_position = -direction * 16
		other_cube._ray_cast_2d.force_raycast_update()
		if other_cube._ray_cast_2d.is_colliding():
			return
		if !other_cube.can_move(-direction):
			return
	target_space.emit(target_tile, self)
	linked_push(-direction)
	
	is_moving = true

	var target_position: Vector2 = tile_map.map_to_local(target_tile)
	var tween = create_tween()
	tween.tween_property(self, "global_position",target_position , 0.2).set_trans(Tween.TRANS_SINE)
	await tween.finished

	is_moving = false
	if victory:
			sweet_victory.emit()

func linked_push(direction : Vector2):
	for s in linked_cubes:
		
		var other_cube = get_node(s)
		
		var current_tile : Vector2i = other_cube.tile_map.local_to_map(other_cube.global_position)
		var target_tile : Vector2i = Vector2i(current_tile.x + direction.x, current_tile.y + direction.y)
		var tile_data  : TileData = other_cube.tile_map.get_cell_tile_data(0, target_tile)
		target_space.emit(target_tile, self)
		
		if tile_data.get_custom_data("walkable") == false:
			return
		
		var victory := false
		if tile_data.get_custom_data("goal") and other_cube.is_goal_cube:
			other_cube.sweet_victory.emit()
		
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
