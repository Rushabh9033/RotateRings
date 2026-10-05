extends RefCounted
class_name PuzzleState

## Pure puzzle snapshot. Visual nodes may back the arrays, but legality never lives here.
var pieces: Array = []
var links: Array = []

func _init(p_pieces: Array = [], p_links: Array = []) -> void:
	pieces = p_pieces
	links = p_links
