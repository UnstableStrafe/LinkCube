extends Button

var scene = preload("res://Levels/level_1.tscn")

func _pressed():
	get_tree().change_scene_to_packed(scene)
