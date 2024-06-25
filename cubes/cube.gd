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


func _ready():
	is_goal_cube = is_goal_cube  # trigger setter

## Check check if target tile is walkable
func can_move(direction: Vector2i) -> bool:
	var target_tile := Tiles.global_to_tile(global_position) + direction
	var tile_data := Tiles.tilemap.get_cell_tile_data(0, target_tile)

	return tile_data.get_custom_data("walkable")

func push(direction: Vector2i) -> void:
	if can_move(direction):
		var target_tile := Tiles.global_to_tile(global_position) + direction

		$Mover.register_move(target_tile)

		# Push any cubes in the target square
		var body := _get_object_in_dir(direction)

		if body and body.owner is Cube:
			var cube: Cube = body.owner
			if cube.cube_pushable:
				cube.push(direction)
			else:
				$Mover.move_tracker.cancel()

	else:
		$Mover.move_tracker.cancel()


func _get_object_in_dir(direction: Vector2i) -> Object:
	$RayCast2D.target_position = direction * Tiles.tile_size
	$RayCast2D.force_raycast_update()

	if $RayCast2D.is_colliding():
		return $RayCast2D.get_collider()
	else:
		return null


func _on_mover_moved() -> void:
	# When this cube moves, check whether we win
	if is_goal_cube:
		var target_tile := Tiles.global_to_tile(global_position)
		var tile_data := Tiles.tilemap.get_cell_tile_data(0, target_tile)

		if tile_data.get_custom_data("goal"):
			Global.sweet_victory.emit()
			%AnimationPlayer.play("win")
