extends Control

signal transition_end

# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect.visible = false
	$ColorRect.color = RenderingServer.get_default_clear_color() # this will dynamically change the color of the transtion overlay to fit the background color
	($ColorRect.material as ShaderMaterial).set_shader_parameter("screen_width", size.x)
	($ColorRect.material as ShaderMaterial).set_shader_parameter("screen_height", size.y)
##Feed in Vector2.ZERO to have it play at center of screen
func play_out(target_pos: Vector2):
	if target_pos != Vector2.ZERO:
		($ColorRect.material as ShaderMaterial).set_shader_parameter("pos", target_pos)
	else:
		($ColorRect.material as ShaderMaterial).set_shader_parameter("pos", Vector2(0.5,0.5))
	$AnimationPlayer.play("fade_out")
##Feed in Vector2.ZERO to have it play at center of screen
func play_in(target_pos:  Vector2):
	if target_pos != Vector2.ZERO:
		($ColorRect.material as ShaderMaterial).set_shader_parameter("pos", target_pos)
	else:
		($ColorRect.material as ShaderMaterial).set_shader_parameter("pos", Vector2(0.5,0.5))
	$AnimationPlayer.play("fade_in")




func _on_animation_player_animation_finished(anim_name):
	$ColorRect.visible = false
	transition_end.emit()
