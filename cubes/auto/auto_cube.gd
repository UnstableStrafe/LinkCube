class_name AutoCube
extends Cube

enum Direction {UP, DOWN, LEFT, RIGHT}
@export var direction := Direction.DOWN

var mov_dir: Vector2
## Keeps track of the tiles that all the cubes are trying to move to
## This prevents the auto cube from going onto a space that is going to be occupied
## By a pushed cube
var targetted_tiles: Array[Vector2i] = []

func _ready():
	Global.move.connect(_on_player_move)
	Global.tile_targetted.connect(_on_tile_targetted)

	match direction:
		Direction.DOWN:
			mov_dir = Vector2.DOWN
		Direction.UP:
			mov_dir = Vector2.UP
		Direction.LEFT:
			mov_dir = Vector2.LEFT
		Direction.RIGHT:
			mov_dir = Vector2.RIGHT

	$Sprite2D.rotation = mov_dir.angle() - PI / 2

	$RayCast2D.target_position = mov_dir * Global.tile_size
	$RayCast2D.force_raycast_update()

func _on_player_move():
	if is_space_targetted(mov_dir):
		_push(mov_dir)

	targetted_tiles.clear()

## Ensure nothing else is moving into that space
func is_space_targetted(_direction: Vector2i) -> bool:
	var current_tile := Global.tilemap.local_to_map(global_position)
	var target_tile := current_tile + _direction

	return target_tile not in targetted_tiles

func _on_tile_targetted(tile: Vector2i, node: Node2D):
	if node != self:
		targetted_tiles.append(tile)
