class_name Player
extends Node2D

signal did_action

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

var can_move := true
var is_moving := false
var input_lock := false

# Use process to repeatedly move while the key is held
func _process(_delta: float) -> void:
	if is_moving: return
	if input_lock: return

	if Input.is_action_pressed("move_up"):
		move(Vector2.UP)
	elif Input.is_action_pressed("move_down"):
		move(Vector2.DOWN)
	elif Input.is_action_pressed("move_left"):
		move(Vector2.LEFT)
		$Sprite2D.flip_h = true;
	elif Input.is_action_pressed("move_right"):
		move(Vector2.RIGHT)
		$Sprite2D.flip_h = false;

	elif Input.is_action_pressed("wait"):
		input_lock = true
		Global.move.emit()
		var timer = get_tree().create_timer(Global.move_time)
		await timer.timeout
		did_action.emit()
		input_lock = false


func move(direction: Vector2):
	var current_tile := Global.tilemap.local_to_map(global_position)
	var target_tile := Vector2i(
		round(current_tile.x + direction.x),
		round(current_tile.y + direction.y)
	)
	var tile_data := Global.tilemap.get_cell_tile_data(0, target_tile)

	if not tile_data.get_custom_data("walkable"):
		return

	ray_cast_2d.target_position = direction * Global.tile_size
	ray_cast_2d.force_raycast_update()

	if ray_cast_2d.is_colliding():
		var collision: Node = ray_cast_2d.get_collider().get_parent()
		if collision is Cube:
			var cube: Cube = collision
			if cube.pushable and cube.can_move(direction):
				cube._push(direction)
			if not cube.is_moving:
				return

	Global.tile_targetted.emit(target_tile, self)
	is_moving = true
	Global.move.emit()

	var target_position: Vector2 = Global.tilemap.to_global(Global.tilemap.map_to_local(target_tile))
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, Global.move_time).set_trans(Tween.TRANS_SINE)
	await tween.finished

	is_moving = false

	did_action.emit()
