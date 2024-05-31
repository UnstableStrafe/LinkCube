extends Control

@export var level_select_scene: PackedScene
@export var settings_scene: PackedScene

func _ready() -> void:
	get_tree().paused = true

func _on_tree_exiting() -> void:
	get_tree().paused = false


func _on_resume_pressed() -> void:
	queue_free()

func _on_level_select_pressed() -> void:
	get_tree().change_scene_to_packed(level_select_scene)

func _on_settings_pressed() -> void:
	var scene := settings_scene.instantiate()
	add_child(scene)

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.
