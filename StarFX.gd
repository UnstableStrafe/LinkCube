extends Node2D

enum Star_size {BIG, MEDIUM, SMALL, TINY}

var size := Star_size.BIG
# Called when the node enters the scene tree for the first time.
func _ready():
	if size == Star_size.BIG:
		$BigStar.visible = true
	elif size == Star_size.MEDIUM:
		$MediumStar.visible = true
	elif size == Star_size.SMALL:
		$SmallStar.visible = true
	elif size == Star_size.TINY:
		$TinyStar.visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func move_in_dir(angle: float):
	var direction := Vector2.RIGHT.rotated((-90 + angle) * (PI / 180)).normalized()
	direction *= 2
	print(direction)
	$Mover.tween_move(self, direction)
	await $Mover.moved
	self.queue_free()
