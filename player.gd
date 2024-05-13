extends Node2D

signal did_action
signal move_auto
signal target_space

@export var move_duration := 0.2
@onready var tile_map: TileMap = $"../../TileMap"
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

var can_move := true
var is_moving := false
var input_lock := false


func _unhandled_input(event: InputEvent) -> void:
	if is_moving: return
	if input_lock: return

	if event.is_action_pressed("move_up"):
		move(Vector2.UP)
	elif event.is_action_pressed("move_down"):
		move(Vector2.DOWN)
	elif event.is_action_pressed("move_left"):
		move(Vector2.LEFT)
	elif event.is_action_pressed("move_right"):
		move(Vector2.RIGHT)

	elif event.is_action_pressed("wait"):
		input_lock = true
		move_auto.emit()
		var timer = get_tree().create_timer(move_duration)
		await timer.timeout
		did_action.emit()
		input_lock = false


func move(direction: Vector2):
	var current_tile := tile_map.local_to_map(global_position)
	var target_tile := Vector2i(
		round(current_tile.x + direction.x),
		round(current_tile.y + direction.y)
	)
	var tile_data := tile_map.get_cell_tile_data(0, target_tile)

	if not tile_data.get_custom_data("walkable"):
		return

	ray_cast_2d.target_position = direction * tile_map.tile_set.tile_size.x
	ray_cast_2d.force_raycast_update()

	if ray_cast_2d.is_colliding():
		var collision: Node = ray_cast_2d.get_collider().get_parent()
		if collision is Cube:
			var cube: Cube = collision
			if cube.pushable and cube.can_move(direction):
				cube._push(direction)
			if not cube.is_moving:
				return

	target_space.emit(target_tile, self)
	is_moving = true
	move_auto.emit()

	var target_position: Vector2 = tile_map.to_global(tile_map.map_to_local(target_tile))
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, move_duration).set_trans(Tween.TRANS_SINE)
	await tween.finished

	is_moving = false

	did_action.emit()
