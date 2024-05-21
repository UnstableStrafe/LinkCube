extends Button

@export var level_select: PackedScene

func _pressed():
	get_tree().change_scene_to_packed(level_select)
