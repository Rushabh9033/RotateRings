extends SceneTree

const Harness = preload("res://tools/level_engine_harness.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")
const LevelDatabase = preload("res://data/level_database.gd")

func _init() -> void:
	var def = LevelDatabase.get_level(4)
	var built: Dictionary = Harness.build_level(4)
	var locked := false
	for piece in built.pieces:
		if not Rules.is_piece_rotatable(piece, built.pieces, built.links):
			locked = true
	if Rules.resolve_releases(built.pieces, built.links).size() > 0:
		print("FAILED: level 4 is already open")
		quit(1)
		return
	var won := false
	for step in def.canonical_steps:
		var piece = Rules.get_piece_by_id(step.piece_id, built.pieces)
		var result: Dictionary = Rules.apply_settled_rotation(piece, step.target_angle_deg, built.pieces, built.links)
		won = bool(result.won)
	for piece in built.pieces:
		if is_instance_valid(piece):
			piece.free()
	if locked and won and def.pieces.size() >= 3:
		print("SUCCESS: level 4 starts locked and the solved path wins")
		quit(0)
	else:
		print("FAILED: level 4 order")
		quit(1)
