class_name Player
extends Node2D

signal did_action

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
		$Mover.move_tracker.cancel()
		return

	# Initiate move tracker for this turn
	$Mover.move_tracker.grab_current_coords()
	# Register player's intended movement
	$Mover.register_move(target_tile)

	# Push cube located in that direction

	var body := _get_object_in_dir(direction)
	if body:
		var cube: Cube = body.owner
		# Check if this is a pushable cube
		if cube.pushable:
			cube.push(direction)
		else:
			$Mover.move_tracker.cancel()

	# Tell auto cubes to move
	get_tree().call_group("auto", "move")

	# TODO: Work out if the queue was cleared at some point
	# Otherwise shit will move anyway lol

	# Commit moves if all are valid
	if $Mover.move_tracker.are_all_unique() and not $Mover.move_tracker.cancelled:
		$Mover.move_tracker.commit_moves()
		await $Mover.moved
		did_action.emit()
	else:
		$Mover.move_tracker.reset()


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
	$Mover.move_tracker.reset()
