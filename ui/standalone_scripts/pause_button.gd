extends TextureButton

@export var pause_menu: PackedScene

func _on_pause_button_pressed() -> void:
	var menu := pause_menu.instantiate()
	add_sibling(menu)
