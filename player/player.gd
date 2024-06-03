class_name Player
extends Node2D

signal did_action

var can_move := true
var _is_moving := false
var input_lock := true

func _ready() -> void:
	# Prevent keys held over from the previous level from doing anything
	input_lock = true
	var timer = get_tree().create_timer(Global.move_time)
	await timer.timeout
	input_lock = false

# Use process to repeatedly move while the key is held
func _process(_delta: float) -> void:
	if _is_moving: return
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
		input_lock = true
		Global.move.emit()
		var timer = get_tree().create_timer(Global.move_time)
		await timer.timeout

		did_action.emit()
		input_lock = false

func _can_move(direction: Vector2i) -> bool:
	# Check check if target tile is walkable

	var current_tile: Vector2i = Global.tilemap.local_to_map(global_position)
	var target_tile := current_tile + direction
	var tile_data := Global.tilemap.get_cell_tile_data(0, target_tile)

	if not tile_data.get_custom_data("walkable"):
		return false

	# Check if there is an object in the way
	var body := _get_object_in_dir(direction)

	if body:
		var cube: Cube = body.owner
		# Check if this is a pushable cube
		return cube.pushable and cube.can_move(direction)

	return true

func initiate_move(direction: Vector2i):
	if _is_moving: return
	if not _can_move(direction): return

	var current_tile := Global.tilemap.local_to_map(global_position)
	var target_tile := current_tile + direction

	Global.tile_targetted.emit(target_tile, self)
	perform_move(direction)

func perform_move(direction: Vector2i) -> void:
	# Calculate where we are moving to
	var current_tile := Global.tilemap.local_to_map(global_position)
	var target_tile := current_tile + direction

	var body := _get_object_in_dir(direction)
	if body:
		var cube: Cube = body.owner
		# Check if this is a pushable cube
		if cube.pushable and cube.can_move(direction):
			cube.push(direction)

	# Setup for movement
	_is_moving = true
	Global.move.emit()

	# Tween movement
	var target_position: Vector2 = Global.tilemap.to_global(Global.tilemap.map_to_local(target_tile))
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, Global.move_time).set_trans(Tween.TRANS_SINE)
	await tween.finished

	# Movement teardown
	_is_moving = false

	did_action.emit()

func _get_object_in_dir(direction: Vector2i) -> Object:
	$RayCast2D.target_position = direction * Global.tile_size
	$RayCast2D.force_raycast_update()

	if $RayCast2D.is_colliding():
		return $RayCast2D.get_collider()
	else:
		return null
