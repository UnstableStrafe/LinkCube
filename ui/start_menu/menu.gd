extends Control

@export var level_select: PackedScene
@export var settings: PackedScene


func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(level_select)

func _on_settings_button_pressed() -> void:
	var settings_scene := settings.instantiate()
	add_child(settings_scene)
