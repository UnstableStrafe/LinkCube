class_name Player
extends Node2D

signal did_action

@export var move_tracker: MoveTracker
var input_lock := true

func _ready() -> void:
	# Prevent keys held over from the previous level from doing anything
	input_lock = true
	var timer = get_tree().create_timer(Global.move_time)
	await timer.timeout
	input_lock = false

# Use process to repeatedly move while the key is held
func _process(_delta: float) -> void:
	if $Mover.is_moving: return
	if input_lock: return

	if Input.is_action_pressed("move_up"):
		initiate_move(Vector2i.UP)
	elif Input.is_action_pressed("move_down"):
		initiate_move(Vector2i.DOWN)
	elif Input.is_action_pressed("move_left"):
		initiate_move(Vector2i.LEFT)
		$Sprite2D.flip_h = true;
	elif Input.is_action_pressed("move_right"):
		initiate_move(Vector2i.RIGHT)
		$Sprite2D.flip_h = false;

	elif Input.is_action_pressed("wait"):
		initiate_move(Vector2.ZERO)


func initiate_move(direction: Vector2i):
	if $Mover.is_moving: return

	var current_tile := Tiles.global_to_tile(global_position)
	var target_tile := current_tile + direction
	var tile_data := Tiles.tilemap.get_cell_tile_data(0, target_tile)

	if not tile_data.get_custom_data("walkable"):
		move_tracker.cancel()
		return

	# Initiate move tracker for this turn
	move_tracker.init()
	# Register player's intended movement
	move_tracker.register_move($Mover, target_tile)

	# Push cube located in that direction

	var body := _get_object_in_dir(direction)
	if body:
		var cube: Cube = body.owner
		# Check if this is a pushable cube
		if cube.pushable:
			cube.push(direction)
		else:
			move_tracker.cancel()

	# Tell auto cubes to move
	get_tree().call_group("auto", "move")

	# Otherwise shit will move anyway lol

	# Commit moves if all are valid
	if move_tracker.are_all_unique() and not move_tracker.cancelled:
		$MoveSound.play()
		move_tracker.commit_moves()
		await $Mover.moved
		did_action.emit()
	else:
		move_tracker.reset()


func _get_object_in_dir(direction: Vector2i) -> Object:
	$RayCast2D.target_position = direction * Tiles.tile_size
	$RayCast2D.force_raycast_update()

	if $RayCast2D.is_colliding():
		return $RayCast2D.get_collider()
	else:
		return null

# The move tracker resource needs to be reset before the Movers initialise
# This is good
func _on_tree_exiting() -> void:
	move_tracker.reset()
