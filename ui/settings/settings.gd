extends Control

## The config to load when "Default" is hit
@export_file("cfg") var default_config_path: String

@onready var current: Settings:
	set(settings):
		current = settings
		view_current()

func _ready() -> void:
	# Display the current settings when the scene loads
	current = Settings.from_current()

## Render the settings
func view_current() -> void:
	%FullscreenToggle.button_pressed = current.get_val("fullscreen")

# This can be connected to toggles etc to set a setting
func _on_setting_changed(value: Variant, property: String) -> void:
	current.set_val(property, value)

# Buttons

func _on_back_button_pressed() -> void:
	queue_free()

func _on_default_pressed() -> void:
	current = Settings.from_file(default_config_path)

func _on_apply_pressed() -> void:
	current.apply()
