class_name Cube
extends Node2D

## Is this the cube needed to touch the goal
@export var is_goal_cube := false
## Can this cube be pushed by the player
@export var pushable := true
## Can this cube be pushed by another cube
@export var cube_pushable := false

const PLAYER_COLLISION_LAYER = 2

signal finished_moving

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
	
	finished_moving.emit()


## Whether the cube can move in the given direction
## i.e. if the target tile is walkable or if there is no cube in that space
func can_move(direction: Vector2i) -> bool:
	$RayCast2D.target_position = direction * Global.tile_size
	$RayCast2D.force_raycast_update()

	if $RayCast2D.is_colliding():
		var body: Object = $RayCast2D.get_collider()
		# If enabled, the collision is with the player
		if body.get_collision_layer_value(PLAYER_COLLISION_LAYER):
			# Player is not pushable
			return false
		# Otherwise its probably a cube
		else:
			# Check if this is a pushable cube
			var cube: Cube = body.owner
			return other_is_cube_pushable(cube, direction)

	# Check if target tile is walkable

	var current_tile: Vector2i = Global.tilemap.local_to_map(global_position)
	var target_tile := current_tile + direction
	var tile_data := Global.tilemap.get_cell_tile_data(0, target_tile)

	if not tile_data.get_custom_data("walkable"):
		return false
	else:
		return true


func other_is_cube_pushable(otherBody: Cube, direction: Vector2i) -> bool:
	if otherBody.cube_pushable and otherBody.can_move(direction):
		otherBody._push(direction)
		return true
	else:
		return false
