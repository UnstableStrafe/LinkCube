@icon("res://resources/nodes/mover.svg")
class_name Mover
extends Node

## Emitted when a movement is complete
signal moved

## The node to move. Defaults to the owner
@export var target: Node2D
@export var trans := Tween.TRANS_SINE
@export var ease_type := Tween.EASE_IN_OUT
@export var move_tracker: MoveTracker

var is_moving := false

func _ready() -> void:
	if not is_instance_valid(target):
		target = owner

	move_tracker.movers.append(self)

func register_move(tile: Vector2i) -> void:
	move_tracker.register_move(self, tile)

## Tween the given node to the next tile in the given direction [br]
## Emits [signal moved] when done
func tween_move(direction: Vector2i) -> void:
	var current_tile := Tiles.global_to_tile(target.global_position)
	var target_tile := current_tile + direction

	await tween_to(target_tile)

func tween_to(tile: Vector2i) -> void:
	var target_position := Tiles.tile_to_global(tile)

	is_moving = true

	# Tween movement
	var tween = create_tween()
	tween.tween_property(target, "global_position", target_position, Global.move_time)
	tween.set_trans(trans)
	tween.set_ease(ease_type)

	await tween.finished

	is_moving = false
	moved.emit()
