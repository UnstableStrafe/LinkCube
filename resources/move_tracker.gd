## Exists to track movements of Movers and ensure there's no overlaps
class_name MoveTracker
extends Resource

var movers: Array[Mover] = []
# node: tile_coord
var moves := {}
# Whether moves have been cancelled
#  twitter dot com
var cancelled := false


func init() -> void:
	cancelled = false
	grab_current_coords()

func grab_current_coords() -> void:
	moves = {}

	for mover in movers:
		var tile_coord := Tiles.global_to_tile(mover.target.global_position)
		moves[mover] = tile_coord

func register_move(mover: Mover, coord: Vector2i) -> void:
	if cancelled: return

	moves[mover] = coord

func are_all_unique() -> bool:
	var unique := []

	for coord in moves.values():
		if coord in unique:
			return false

		unique.append(coord)

	return true

func commit_moves() -> void:
	if cancelled: return

	for mover in moves.keys():
		var tile: Vector2i = moves[mover]

		mover.tween_to(tile)

	moves = {}

## Cancel registered moves
func cancel() -> void:
	moves = {}
	cancelled = true

## Reset the state of the tracker including movers and moves
func reset() -> void:
	movers = []
	moves = {}
	cancelled = false

