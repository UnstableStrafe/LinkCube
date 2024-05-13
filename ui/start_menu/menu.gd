extends Button

@export var levels: Level_Index

func _pressed():
	get_tree().change_scene_to_packed(levels.levels[0])
