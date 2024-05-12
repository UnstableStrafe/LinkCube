@tool
class_name PushableCube
extends Node2D

@export var pushable := true
@onready var tile_map: TileMap = $"../../../TileMap"
@onready var _ray_cast_2d: RayCast2D = $"RayCast2D"
@onready var crown = $"Crown"



@export var is_goal_cube := false

var is_moving := false

signal target_space
signal sweet_victory


# Called when the node enters the scene tree for the first time.
func _ready():
	if _ray_cast_2d == null:
		print_rich("[color=CRIMSON][font_size=30][shake rate=20.0 level=5 connected=1]UH OH!!![/shake][/font_size][/color]")
		print_rich("Looks like you [color=RED][pulse freq=2.5]FUCKED UP[/pulse][/color] and your code errored!!! [color=CORNFLOWER_BLUE]:([/color]")
		print("Error is in: your cube raycast code")
		get_tree().paused = true

func _push(direction: Vector2):
	if is_moving:
		return
	var current_tile := tile_map.local_to_map(global_position)
	var target_tile := Vector2i(
		round(current_tile.x + direction.x),
		round(current_tile.y + direction.y)
	)
	var tile_data  := tile_map.get_cell_tile_data(0, target_tile)

	if tile_data.get_custom_data("walkable") == false:
		return
	if tile_data.get_custom_data("goal") and is_goal_cube:
		sweet_victory.emit()
	_ray_cast_2d.target_position = direction * 16
	_ray_cast_2d.force_raycast_update()

	if _ray_cast_2d.is_colliding():
		return
	target_space.emit(target_tile, self)
	is_moving = true

	var target_position: Vector2 = tile_map.map_to_local(target_tile)
	var tween = create_tween()
	tween.tween_property(self, "global_position",target_position , 0.2).set_trans(Tween.TRANS_SINE)
	await tween.finished
	is_moving = false


func can_move(direction: Vector2) -> bool:
	_ray_cast_2d.target_position = direction * 16.0
	_ray_cast_2d.force_raycast_update()
	var current_tile : Vector2i = tile_map.local_to_map(global_position)
	var target_tile : Vector2i = Vector2i(
		round(current_tile.x + direction.x),
		round(current_tile.y + direction.y)
	)
	var tile_data  : TileData = tile_map.get_cell_tile_data(0, target_tile)


	if tile_data.get_custom_data("walkable") == false or _ray_cast_2d.is_colliding():
		return false
	else:
		return true

