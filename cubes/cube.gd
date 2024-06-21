@tool  # So the crown is visible in the editor
@icon("res://cubes/basic/basic_cube.png")
class_name Cube
extends Node2D

signal moved(direction)

## Is this the cube needed to touch the goal
@export var is_goal_cube := false:
	set(value):
		is_goal_cube = value
		%Crown.visible = is_goal_cube
## Can this cube be pushed by the player
@export var pushable := true
## Can this cube be pushed by another cube
@export var cube_pushable := false

const PLAYER_COLLISION_LAYER = 2

var _is_moving := false

func _ready():
	is_goal_cube = is_goal_cube  # trigger setter

func push(direction: Vector2i):
	# Debounce/prevent moving while already moving
	if _is_moving: return
	# push shouldn't be called without checking if the cube can move
	#if not can_move(direction): return

	# Push adjacent cube if pushable
	var body := _get_object_in_dir(direction)
	if body and body.owner is Cube and body.owner.cube_pushable:
		body.owner.push(direction)

	# Work out where we are going
	var target_tile := Tiles.global_to_tile(global_position) + direction
	var tile_data := Tiles.tilemap.get_cell_tile_data(0, target_tile)

	_is_moving = true
	# For auto cube
	Global.tile_targetted.emit(target_tile, self)

	# Tween to position
	$Mover.tween_move(self, direction)
	await $Mover.moved

	_is_moving = false

	moved.emit(direction)

	if is_goal_cube and tile_data.get_custom_data("goal"):
		Global.sweet_victory.emit()

		%AnimationPlayer.play("win")


## Whether the cube can move in the given direction
## i.e. if the target tile is walkable or if there is no cube in that space
func can_move(direction: Vector2i) -> bool:
	# Check check if target tile is walkable

	var target_tile := Tiles.global_to_tile(global_position) + direction
	var tile_data := Tiles.tilemap.get_cell_tile_data(0, target_tile)

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
	$RayCast2D.target_position = direction * Tiles.tile_size
	$RayCast2D.force_raycast_update()

	if $RayCast2D.is_colliding():
		return $RayCast2D.get_collider()
	else:
		return null
