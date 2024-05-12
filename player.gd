extends Node2D

@onready var tile_map = $"../../TileMap"
@onready var sprite_2d = $Sprite2D
@onready var ray_cast_2d = $RayCast2D

var can_move := true
var is_moving := false
var input_lock := false


signal did_action
signal move_auto
signal target_space

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if is_moving:
		return
	if input_lock:
		return
	if Input.is_action_pressed("move_up"):
		move(Vector2.UP)
	elif Input.is_action_pressed("move_down"):
		move(Vector2.DOWN)
	elif Input.is_action_pressed("move_left"):
		move(Vector2.LEFT)
	elif Input.is_action_pressed("move_right"):
		move(Vector2.RIGHT)
	elif Input.is_action_just_pressed("wait"):
		input_lock = true
		move_auto.emit()
		var timer = get_tree().create_timer(.2)
		await timer.timeout
		did_action.emit()
		input_lock = false
	
func move(direction : Vector2):
	var current_tile : Vector2i = tile_map.local_to_map(global_position)
	var target_tile : Vector2i = Vector2i(current_tile.x + direction.x, current_tile.y + direction.y)
	var tile_data  : TileData = tile_map.get_cell_tile_data(0, target_tile)
	
	if tile_data.get_custom_data("walkable") == false:
		return
	
	ray_cast_2d.target_position = direction * 16
	ray_cast_2d.force_raycast_update()
	
	if ray_cast_2d.is_colliding():
		if ray_cast_2d.get_collider().get_parent() is PushableCube:
			var cube = ray_cast_2d.get_collider().get_parent()
			if cube.pushable and cube.can_move(direction):
				cube._push(direction)
			if !cube.is_moving:
				return
	target_space.emit(target_tile, self)
	is_moving = true
	move_auto.emit()
	var target_position: Vector2 = tile_map.map_to_local(target_tile)
	var tween = create_tween()
	tween.tween_property(self, "global_position",target_position , 0.2).set_trans(Tween.TRANS_SINE)
	await tween.finished

	is_moving = false
	
	did_action.emit()
	
	#can_move = false
	
	# get_tree().create_timer(.2).timeout.connect(timer_end)

