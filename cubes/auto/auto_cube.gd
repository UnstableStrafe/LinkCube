@icon("res://cubes/auto/auto_cube.png")
extends Cube

enum AutoType {NORMAL, BOUNCE, ROTATE}
enum Direction {UP, DOWN, LEFT, RIGHT}
## The direction to automatically travel in
@export var direction := Direction.DOWN
## The type of movement the cube has
##
## NORMAL stops when unable to move
## BOUNCE rotates 180 degrees when unable to move
## ROTATE will rotate 90 degrees clockwise when unable to move.
@export var auto_type := AutoType.NORMAL

var mov_dir: Vector2i:
	set(dir):
		mov_dir = dir
		# This will make the sprite shading rotate properly. Change this and I am liable to bite you alice.
		match mov_dir:
			Vector2i.DOWN:
				$Sprite2D/ArrowSprite.flip_h = false
				$Sprite2D/ArrowSprite.flip_v = false
				$Sprite2D/ArrowSprite.rotation = 0
			Vector2i.UP:
				$Sprite2D/ArrowSprite.flip_h = false
				$Sprite2D/ArrowSprite.flip_v = true
				$Sprite2D/ArrowSprite.rotation = 0
			Vector2i.LEFT:
				$Sprite2D/ArrowSprite.rotation_degrees = 90
				$Sprite2D/ArrowSprite.flip_h = false
				$Sprite2D/ArrowSprite.flip_v = false
			Vector2i.RIGHT:
				$Sprite2D/ArrowSprite.rotation_degrees = -90
				$Sprite2D/ArrowSprite.flip_h = true
				$Sprite2D/ArrowSprite.flip_v = false

		$RayCast2D.target_position = mov_dir * Tiles.tile_size
		$RayCast2D.force_raycast_update()

## Keeps track of the tiles that all the cubes are trying to move to
## This prevents the auto cube from going onto a space that is going to be occupied
## by a pushed cube
var targeted_tiles: Array[Vector2i] = []

func _ready():
	super()

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

func move() -> void:
	# If unable to move in the given direction (something is there)
	if not can_move(mov_dir):
		# Change move direction according to rules
		if auto_type == AutoType.BOUNCE:
			# Invert mov dir
			mov_dir *= -1
		elif auto_type == AutoType.ROTATE:
			# Rotate mov dir clockwise 90 degrees
			mov_dir = Vector2(mov_dir).rotated(deg_to_rad(90))

	#if can_move(mov_dir):
		push(mov_dir)


func can_move(mov_dir: Vector2i) -> bool:
	# Work out where we are going
	var target_tile := Tiles.global_to_tile(global_position) + mov_dir
	var tile_data := Tiles.tilemap.get_cell_tile_data(0, target_tile)

	# Work out if tile is walkable
	if not tile_data.get_custom_data("walkable"):
		return false

	# Will a cube be at that spot


	return true
