extends Control

signal transition_ended


@onready var shader: ShaderMaterial = $ColorRect.material

# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect.color = RenderingServer.get_default_clear_color() # this will dynamically change the color of the transtion overlay to fit the background color

	shader.set_shader_parameter("screen_width", size.x)
	shader.set_shader_parameter("screen_height", size.y)


## Translate global_position of a node to a Vector2 representing
##  how far across the screen the point is from 0 to 1
func _global_coord_to_screen(pos: Vector2) -> Vector2:
	var cam_size := get_viewport_rect().size as Vector2

	return pos / cam_size

# Feed in Vector2.ZERO to have it play at center of screen
func _set_center_at(pos: Vector2) -> void:
	if pos == Vector2.ZERO:
		pos = Vector2(0.5,0.5)
	else:
		pos = _global_coord_to_screen(pos)

	shader.set_shader_parameter("pos", pos)

func play_in(target_pos: Vector2):
	_set_center_at(target_pos)
	$AnimationPlayer.play("fade_in")

func play_out(target_pos: Vector2):
	_set_center_at(target_pos)
	$AnimationPlayer.play("fade_out")

func _on_animation_player_animation_finished(_anim_name: StringName):
	transition_ended.emit()


func cover_player() -> void:
	var player: Node2D = get_tree().get_first_node_in_group("player")
	play_out(player.global_position)

func reveal_player() -> void:
	await get_tree().process_frame

	var player: Node2D = get_tree().get_first_node_in_group("player")
	play_in(player.global_position)
