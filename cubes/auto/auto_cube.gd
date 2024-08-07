@tool
@icon("res://cubes/auto/auto_cube.png")
extends Cube

enum AutoType {NORMAL, BOUNCE, ROTATE}
enum Direction {UP, DOWN, LEFT, RIGHT}
## The direction to automatically travel in
@export var direction := Direction.DOWN
## The type of movement the cube has:
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


## Autocubes use this instead of `push`
# This contains a few extra checks to ensure that the auto cube can indeed
#  move to the given tile
#  because if an autocube can't move, other cubes still can
func move() -> void:
	var target_tile := Tiles.global_to_tile(global_position) + mov_dir
	# If unable to move in the given direction (something is there)
	if not can_move(mov_dir) or move_tracker.is_tile_registered(target_tile):
		# Change move direction according to rules
		if auto_type == AutoType.BOUNCE:
			# Invert mov dir
			mov_dir *= -1
		elif auto_type == AutoType.ROTATE:
			# Rotate mov dir clockwise 90 degrees
			mov_dir = Vector2(mov_dir).rotated(deg_to_rad(90))

		target_tile = Tiles.global_to_tile(global_position) + mov_dir

	# If we still can't move - don't until the next action
	if not can_move(mov_dir): return

	# Move :3

	# Push any cubes in the target square
	var body := _get_object_in_dir(mov_dir)

	if body and body.owner is Cube:
		var cube: Cube = body.owner
		if cube.cube_pushable:
			cube.push(mov_dir)
		else:
			# if it isn't pushable, don't move
			return

	# If something is registered for that spot still, don't move
	if move_tracker.is_tile_registered(target_tile): return

	move_tracker.register_move($Mover, target_tile)
