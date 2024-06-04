@icon("res://cubes/basic/basic_cube.png")
class_name Cube
extends Node2D

signal moved(direction)

## Is this the cube needed to touch the goal
@export var is_goal_cube := false
## Can this cube be pushed by the player
@export var pushable := true
## Can this cube be pushed by another cube
@export var cube_pushable := false

const PLAYER_COLLISION_LAYER = 2

var _is_moving := false

func _ready():
	%Crown.visible = is_goal_cube

func push(direction: Vector2i):
	# Debounce/prevent moving while already moving
	if _is_moving: return
	if not can_move(direction): return

	# Push adjacent cube if pushable
	var body := _get_object_in_dir(direction)
	if body and body.owner is Cube and body.owner.cube_pushable:
		body.owner.push(direction)

	# Work out where we are going
	var current_tile := Global.tilemap.local_to_map(global_position)
	var target_tile := current_tile + direction
	var tile_data := Global.tilemap.get_cell_tile_data(0, target_tile)

	_is_moving = true
	# For auto cube
	Global.tile_targetted.emit(target_tile, self)

	# Tween to position
	var target_position: Vector2 = Global.tilemap.map_to_local(target_tile)
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, Global.move_time).set_trans(Tween.TRANS_SINE)

	await tween.finished

	_is_moving = false

	moved.emit(direction)

	if is_goal_cube and tile_data.get_custom_data("goal"):
		Global.sweet_victory.emit()

		%AnimationPlayer.play("win")


## Whether the cube can move in the given direction
## i.e. if the target tile is walkable or if there is no cube in that space
func can_move(direction: Vector2i) -> bool:
	# Check check if target tile is walkable

	var current_tile: Vector2i = Global.tilemap.local_to_map(global_position)
	var target_tile := current_tile + direction
	var tile_data := Global.tilemap.get_cell_tile_data(0, target_tile)

	if not tile_data.get_custom_data("walkable"):
		return false

	# Check if there is an object in the way
	var body := _get_object_in_dir(direction)

	if body:
		if body.get_collision_layer_value(PLAYER_COLLISION_LAYER):
			# Player is not pushable
			return false
		# Otherwise its a cube
		else:
			var cube: Cube = body.owner
			# Check if this is a pushable cube
			return cube.cube_pushable and cube.can_move(direction)

	return true

func _get_object_in_dir(direction: Vector2i) -> Object:
	$RayCast2D.target_position = direction * Global.tile_size
	$RayCast2D.force_raycast_update()

	if $RayCast2D.is_colliding():
		return $RayCast2D.get_collider()
	else:
		return null
