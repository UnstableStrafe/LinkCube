extends Node2D

@onready var player = $player
@onready var tile_map = $"../TileMap"
@onready var other_cubes = $"other_cubes"
@onready var linked_cubes = $"linked_cubes"
@onready var inverted_linked_cubes = $"inverted_cubes"

var action_list = {}
var action_count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	player.did_action.connect(on_player_action)
	
	var list = []
	for e in self.get_children():
		if e == player:
			var dic = {}
			var pos : Vector2 = e.global_position
			dic[e] = pos
			list.append(dic)
		else:
			for i in e.get_children():
				var dic = {}
				var pos : Vector2 = i.global_position
				dic[i] = pos
				list.append(dic)
	action_list[action_count] = list




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("undo"):
		if player.input_lock:
			return
		if action_count == 0:
			print("no actions")
			return
		var list = action_list[action_count - 1]
		for d in list:
			for e in d:
				e.set_global_position(d[e])
		action_count -= 1

func on_player_action():
	var list = []
	action_count += 1
	for e in self.get_children():
		if e == player:
			var dic = {}
			var pos : Vector2 = e.global_position
			dic[e] = pos
			list.append(dic)
		else:
			for i in e.get_children():
				var dic = {}
				var pos : Vector2 = i.global_position
				dic[i] = pos
				list.append(dic)
	action_list[action_count] = list
	
