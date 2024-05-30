extends Control

@export var default: Settings

@onready var current: Settings:
	set(settings):
		current = settings
		view_current()

func _ready() -> void:
	# Load current settings on ready
	current = Settings.Current()

## Render the specified settings view
func view_current() -> void:
	%FullscreenToggle.button_pressed = current.fullscreen

# This can be connected to toggles etc to set a setting
func _on_setting_changed(value: Variant, property: String) -> void:
	current.set(property, value)

# Buttons

func _on_back_button_pressed() -> void:
	queue_free()

func _on_default_pressed() -> void:
	current = default

func _on_apply_pressed() -> void:
	current.apply()
