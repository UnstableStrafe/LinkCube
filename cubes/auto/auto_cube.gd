class_name AutoCube
extends PushableCube

@onready var player = $"../../player"
@onready var entities = $"../.."
@onready var other_cubes = $".."
@onready var linked_cube_list = $"../../linked_cubes"
@onready var inverted_cube_list = $"../../inverted_cubes"
@onready var sprite = $Sprite2D

@export_enum("DOWN", "UP", "LEFT", "RIGHT") var direction : String = "DOWN"
var mov_dir : Vector2
var last_pos : Vector2
var unavaliable_tiles = []

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_goal_cube:
		crown.visible = true
	player.move_auto.connect(on_player_action)
	player.target_space.connect(targeted_tiles)
	for i in other_cubes.get_children():
		if i != self:
			i.target_space.connect(targeted_tiles)
	for i in linked_cube_list.get_children():
		if i != self:
			i.target_space.connect(targeted_tiles)
	for i in inverted_cube_list.get_children():
		if i != self:
			i.target_space.connect(targeted_tiles)
	pushable = false
	match direction:
		"DOWN":
			mov_dir = Vector2.DOWN
			sprite.set_rotation_degrees(0)
		"UP":
			mov_dir = Vector2.UP
			sprite.set_rotation_degrees(180)
		"LEFT":
			mov_dir = Vector2.LEFT
			sprite.set_rotation_degrees(90)
		"RIGHT":
			mov_dir = Vector2.RIGHT
			sprite.set_rotation_degrees(270)
	_ray_cast_2d.target_position = mov_dir * 16
	_ray_cast_2d.force_raycast_update()

func on_player_action():
	if can_move(mov_dir) and check_space_open(mov_dir):
		_push(mov_dir)
	unavaliable_tiles.clear()


func check_space_open(direction: Vector2) -> bool:
	var current_tile : Vector2i = tile_map.local_to_map(global_position)
	var target_tile : Vector2i = Vector2i(current_tile.x + direction.x, current_tile.y + direction.y)
	for v in unavaliable_tiles:
		if v == target_tile:
			return false
	return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func targeted_tiles(tile: Vector2i, node: Node2D):
	if node != self:
		unavaliable_tiles.append(tile)

