class_name Level
extends Node2D

@export var level_id: int
@export var level_name: String
@export var level_index: Level_Index

@onready var player = %Player

var can_progress := false

func _ready():
	Global.tilemap = $TileMap
	Global.sweet_victory.connect(win)

func win():
	can_progress = true
	player.input_lock = true
	%NextLevelPrompt.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("next_level") and can_progress:
		# Load next level
		get_tree().change_scene_to_packed(level_index.levels[level_id])
