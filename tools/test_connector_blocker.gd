extends SceneTree

const PuzzleRulesScript = preload("res://gameplay/puzzle_rules.gd")
const LevelDatabaseScript = preload("res://data/level_database.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	print("\n==============================================")
	print("    CONNECTOR BLOCKER & STOPPER UNIT TEST     ")
	print("==============================================")

	var def = LevelDatabaseScript.get_level(2)
	var pieces := []
	var links := []
	var piece_map := {}

	for p_def in def.pieces:
		var p = RingPiece2DScript.new()
		p.setup(p_def)
		p.position = p_def.position
		pieces.append(p)
		piece_map[p_def.id] = p

	for l_def in def.links:
		var link = l_def.duplicate()
		var from_p = piece_map.get(link.from_piece_id)
		var to_p = piece_map.get(link.to_piece_id)
		if from_p and to_p:
			from_p.set_meta("had_children_initially", true)
			to_p.set_meta("had_parents_initially", true)
			var diff_pos: Vector2 = to_p.position - from_p.position
			link.collar_angle_deg = fposmod(rad_to_deg(diff_pos.angle()) - from_p.rotation_degrees, 360.0)
			link.stem_dist = diff_pos.length()
			link.is_detached = false
		links.append(link)

	var orange = piece_map[&"ring_0"]
	var blue = piece_map[&"ring_1"]
	var purple = piece_map[&"ring_2"]

	# Simulate Blue being solved and released
	blue.state = RingPiece2DScript.State.RELEASED
	# link_0 (Orange -> Blue) is now detached from child, but Orange's stem remains on Orange!
	links[0].is_detached = true

	# Test A: Orange is at 180°.
	# Try to rotate clockwise (+45° towards Purple's cuff).
	# Purple holds Orange at angle ~61°. Orange's stem is at 180° + 180° = 360° = 0°.
	# Angular distance to Purple's cuff is ~61°.
	# Rotating clockwise brings Orange's stem towards Purple's cuff!
	var clamp_cw = PuzzleRulesScript.clamp_rotation_step(orange, 50.0, pieces, links)
	print("Test A - Clockwise rotation towards Purple cuff:")
	print("  Proposed delta: +50.0°")
	print("  Allowed delta: ", clamp_cw["allowed_delta"], "°")
	print("  Hit stopper: ", clamp_cw["hit_stopper"])

	if not clamp_cw["hit_stopper"]:
		print("❌ FAILED: Rotating clockwise towards cuff should have hit the stopper!")
		quit(1)
		return
	if clamp_cw["allowed_delta"] >= 50.0:
		print("❌ FAILED: Allowed delta was not clamped!")
		quit(1)
		return
	print("✅ PASSED: Clockwise rotation blocked by connector stopper!")

	# Test B: Rotate counter-clockwise (-119° towards solution gap).
	# This moves Orange away from Purple's cuff.
	var clamp_ccw = PuzzleRulesScript.clamp_rotation_step(orange, -119.0, pieces, links)
	print("\nTest B - Counter-clockwise rotation towards gap solution:")
	print("  Proposed delta: -119.0°")
	print("  Allowed delta: ", clamp_ccw["allowed_delta"], "°")
	print("  Hit stopper: ", clamp_ccw["hit_stopper"])

	if clamp_ccw["hit_stopper"]:
		print("❌ FAILED: Counter-clockwise should NOT hit stopper!")
		quit(1)
		return
	if clamp_ccw["allowed_delta"] != -119.0:
		print("❌ FAILED: Allowed delta should be full -119.0°!")
		quit(1)
		return
	print("✅ PASSED: Counter-clockwise rotation is free to reach gap solution!")

	print("\n==============================================")
	print("SUCCESS: All connector blocker checks passed!")
	print("==============================================\n")
	quit(0)
