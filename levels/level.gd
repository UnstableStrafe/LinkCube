class_name Level
extends Node2D

@export var level_id: int
@export var level_name: String

@onready var entities = $entities
@onready var player = %player
# TODO: Make level an inherited class
@onready var level_index = load("res://resources/level_index.tres")
@onready var prompt = $NextLevelPrompt
@onready var other_cubes = $entities/other_cubes
@onready var linked_cube_list = $entities/linked_cubes
@onready var inverted_cube_list = $entities/inverted_cubes


var can_progress := false

func _ready():
	Global.tilemap = $TileMap

	Global.sweet_victory.connect(win)

func win():
	can_progress = true
	player.input_lock = true
	prompt.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("wait") and can_progress:
		if level_id == level_index.levels.size():
			print_rich("[font_size=30][wave amp=50.0 freq=-5.0 connected=1]YOU WIN!! YIPPEEEEE!![/wave][/font_size]")
			# TODO: Fix this
			get_tree().change_scene_to_file("res://Levels/victory_screen.tscn")
			return

		get_tree().change_scene_to_packed(level_index.levels[level_id])
