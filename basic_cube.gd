class_name BasicCube
extends PushableCube

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_goal_cube:
		crown.visible = true
	pushable = true
