extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	#$ColorRect.color = RenderingServer.get_default_clear_color() # this will dynamically change the color of the transtion overlay to fit the background color
	($ColorRect.material as ShaderMaterial).set_shader_parameter("screen_width", size.x)
	($ColorRect.material as ShaderMaterial).set_shader_parameter("screen_height", size.y)

func play(target_pos:= Vector2.ZERO, out := true):
	if target_pos != Vector2.ZERO:
		($ColorRect.material as ShaderMaterial).set_shader_parameter("pos", target_pos)
	else:
		($ColorRect.material as ShaderMaterial).set_shader_parameter("pos", Vector2(0.5,0.5))
	if out:
		$AnimationPlayer.play("fade_out")
	elif not out:
		$AnimationPlayer.play_backwards("fade_in")
	await  $AnimationPlayer.animation_finished
	$ColorRect.visible = false
