class_name AutoCube
extends Cube

enum AutoType {NORMAL, BOUNCE, ROTATE}
enum Direction {UP, DOWN, LEFT, RIGHT}
## The direction to automatically travel in
@export var direction := Direction.DOWN
## The type of movement the cube has. NORMAL stops when unable to move. BOUNCE rotates 180 degrees when unable to move. ROTATE will rotate 90 degrees clockwise when unable to move.
@export var auto_type := AutoType.NORMAL



var mov_dir: Vector2:
	set(dir):
		mov_dir = dir
		# This will make the sprite shading rotate properly. Change this and I am liable to bite you alice.
		match mov_dir:
			Vector2.DOWN:
				$Sprite2D/ArrowSprite.flip_h = false
				$Sprite2D/ArrowSprite.flip_v = false
				$Sprite2D/ArrowSprite.rotation = 0
			Vector2.UP:
				$Sprite2D/ArrowSprite.flip_h = false
				$Sprite2D/ArrowSprite.flip_v = true
				$Sprite2D/ArrowSprite.rotation = 0
			Vector2.LEFT:
				$Sprite2D/ArrowSprite.rotation = mov_dir.angle() - PI / 2
				$Sprite2D/ArrowSprite.flip_h = false
				$Sprite2D/ArrowSprite.flip_v = false
			Vector2.RIGHT:
				$Sprite2D/ArrowSprite.rotation = mov_dir.angle() - PI / 2
				$Sprite2D/ArrowSprite.flip_h = true
				$Sprite2D/ArrowSprite.flip_v = false
		

		$RayCast2D.target_position = mov_dir * Global.tile_size
		$RayCast2D.force_raycast_update()

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
	match auto_type:
		AutoType.NORMAL:
			$Sprite2D/ArrowSprite.frame = 0
		AutoType.BOUNCE:
			$Sprite2D/ArrowSprite.frame = 1
		AutoType.ROTATE:
			$Sprite2D/ArrowSprite.frame = 2

func _on_player_move():
	if not is_space_targetted(mov_dir):
		if can_move(mov_dir):
			_push(mov_dir)
		elif auto_type == AutoType.BOUNCE:
			# Invert mov dir
			mov_dir *= -1
			# Just to make sure it won't try to move when it can't move in the new direction
			if not is_space_targetted(mov_dir):
				if can_move(mov_dir):
					_push(mov_dir)
		elif auto_type == AutoType.ROTATE:
			# Rotate mov dir clockwise 90 degrees
			match mov_dir:
				Vector2.DOWN:
					mov_dir = Vector2.LEFT
				Vector2.UP:
					mov_dir = Vector2.RIGHT
				Vector2.LEFT:
					mov_dir = Vector2.UP
				Vector2.RIGHT:
					mov_dir = Vector2.DOWN
			if not is_space_targetted(mov_dir):
				if can_move(mov_dir):
					_push(mov_dir)

	targetted_tiles.clear()

## Ensure nothing else is moving into that space
func is_space_targetted(_direction: Vector2i) -> bool:
	var current_tile := Global.tilemap.local_to_map(global_position)
	var target_tile := current_tile + _direction

	return target_tile in targetted_tiles

func _on_tile_targetted(tile: Vector2i, node: Node2D):
	if node != self:
		targetted_tiles.append(tile)
