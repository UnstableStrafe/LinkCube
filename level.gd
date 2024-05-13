class_name Level
extends Node2D

@export var level_id : int
@export var level_name : String

@onready var entities = $entities
@onready var player = %player
@onready var level_index = preload("res://Resources/level_index.tres")
@onready var prompt = $NextLevelPrompt
@onready var other_cubes = $entities/other_cubes
@onready var linked_cube_list = $entities/linked_cubes
@onready var inverted_cube_list = $entities/inverted_cubes


var can_progress := false

# Called when the node enters the scene tree for the first time.
func _ready():
	for cube in other_cubes.get_children():
		cube.sweet_victory.connect(win)

	for cube in linked_cube_list.get_children():
		cube.sweet_victory.connect(win)

		for i2 in linked_cube_list.get_children():
			if i2 != cube:
				cube.linked_cubes.append(i2.get_path())

	for cube in inverted_cube_list.get_children():
		cube.sweet_victory.connect(win)

		for other_cube in inverted_cube_list.get_children():
			# Don't link a cube to itself
			if other_cube != cube:
				cube.linked_cubes.append(other_cube.get_path())

func win():
	can_progress = true
	player.input_lock = true
	prompt.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float):
	if can_progress and Input.is_action_just_pressed("wait"):
		if level_id + 1 == level_index.levels.size():
			print_rich("[font_size=30][wave amp=50.0 freq=-5.0 connected=1]YOU WIN!! YIPPEEEEE!![/wave][/font_size]")
			get_tree().change_scene_to_file("res://Levels/victory_screen.tscn")
			return
		get_tree().change_scene_to_file(level_index.levels[level_id+1])
