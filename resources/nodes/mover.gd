@icon("res://resources/nodes/mover.svg")
class_name Mover
extends Node

## Emitted when a movement is complete
signal moved

@export var trans := Tween.TRANS_SINE
@export var ease := Tween.EASE_IN_OUT

## Tween the given node to the next tile in the given direction [br]
## Emits [signal moved] when done
func tween_move(node: Node2D, direction: Vector2i) -> void:
	var target_position := node.global_position + direction * Tiles.tile_size

	# Tween movement
	var tween = create_tween()
	tween.tween_property(node, "global_position", target_position, Global.move_time)
	tween.set_trans(trans)
	tween.set_ease(ease)

	await tween.finished
	moved.emit()
