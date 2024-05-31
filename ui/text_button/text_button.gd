## Provides more control over text format than Button does
@icon("res://ui/text_button/icon.svg")
extends Control

signal pressed

@export var disabled: bool:
	set(value):
		%Button.disabled = value
	get:
		return %Button.disabled

func _on_button_pressed() -> void:
	pressed.emit()
