class_name Cube
extends Node2D

@export var is_goal_cube := false
@export var pushable := true
#Used for if a cube can be pushed by another cube
@export var cube_pushable := false 

var is_moving := false

func _ready():
	%Crown.visible = is_goal_cube

func _push(direction: Vector2i):
	# Debounce/prevent moving while already moving
	if is_moving: return
	if not can_move(direction): return

	var current_tile := Global.tilemap.local_to_map(global_position)
	var target_tile := current_tile + direction
	var tile_data := Global.tilemap.get_cell_tile_data(0, target_tile)

	if is_goal_cube and tile_data.get_custom_data("goal"):
		Global.sweet_victory.emit()

	is_moving = true
	# For auto cube
	Global.tile_targetted.emit(target_tile, self)

	# Tween to position
	var target_position: Vector2 = Global.tilemap.map_to_local(target_tile)
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, Global.move_time).set_trans(Tween.TRANS_SINE)

	await tween.finished

	is_moving = false


## Whether the cube can move in the given direction
## i.e. if the target tile is walkable or if there is no cube in that space
func can_move(direction: Vector2i) -> bool:
	$RayCast2D.target_position = direction * Global.tile_size
	$RayCast2D.force_raycast_update()

	var current_tile: Vector2i = Global.tilemap.local_to_map(global_position)
	var target_tile := current_tile + direction
	var tile_data: TileData = Global.tilemap.get_cell_tile_data(0, target_tile)
	if $RayCast2D.is_colliding():
		var body = $RayCast2D.get_collider()
		if not get_tree().get_nodes_in_group("player").has(body):
			return other_is_cube_pushable(body, direction)
		else:
			return false 
			# if the raycast is colliding, get the body that it is colliding with.
			# if that body isn't a player, then call the function to check if that cube can be pushed by other cubes
			# that function will attempt to push the cube, returning true if it can or false if it can't
			# if the body is a player, return false instead
	if not tile_data.get_custom_data("walkable"):
		return false
	else:
		return true


func other_is_cube_pushable(otherBody: Cube, direction: Vector2i) -> bool:
	if not otherBody.cube_pushable or not otherBody.can_move(direction): return false
	else:
		otherBody._push(direction)
		return true
