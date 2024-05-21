extends Control

@export var level_button: PackedScene


func _ready() -> void:
	# Load the save file so we know which levels are unlocked
	var best_scores := Global.load_scores()

	# This flag determines if the next locked level should be unlocked
	var unlock_next_locked := true

	# Add entries for all the levels
	for level in Global.levels:
		var button := level_button.instantiate()
		button.level = level

		# The path for the level scene
		var scene_path := level.scene.resource_path

		# If this path has an entry in the save file, it is completed+unlocked
		if best_scores.has(scene_path):
			button.unlocked = true

			var score: int = best_scores[scene_path]
			button.best_score = score
		# If would be unlocked, but the next level should be unlocked
		elif unlock_next_locked:
			button.unlocked = true
			unlock_next_locked = false
		else:
			button.unlocked = false

		%GridContainer.add_child(button)
