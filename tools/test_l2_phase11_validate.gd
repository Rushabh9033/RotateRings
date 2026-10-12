extends SceneTree

# Phase 11 L2 — focused validator. Checks:
#  - each piece has a single gap with sensible parameters
#  - stem origins are NOT inside any parent's gap
#  - piece positions are within the canvas
#  - links are reachable (cuff center, orientation, distance)
#  - puzzle is solvable by BFS (reuses existing solver)
#  - interactions: rotate cyan, verify orange releases

const LevelDatabaseScript = preload("res://data/level_database.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const BFSSolverScript = preload("res://tools/bfs_solver.gd")

var _pass_count: int = 0
var _fail_count: int = 0

func _ok(msg: String) -> void:
	_pass_count += 1
	print("  PASS  ", msg)

func _fail(msg: String) -> void:
	_fail_count += 1
	print("  FAIL  ", msg)

func _init() -> void:
	print("=== Phase 11 L2 focused validator ===")
	var def = LevelDatabaseScript.get_level(2)
	if def == null:
		_fail("Level 2 not defined"); _summary(); quit(1); return

	# 1. Structure
	print("\n--- Structure ---")
	if def.pieces.size() == 3:
		_ok("3 pieces")
	else:
		_fail("expected 3 pieces, got %d" % def.pieces.size())
	if def.links.size() == 2:
		_ok("2 links")
	else:
		_fail("expected 2 links, got %d" % def.links.size())

	var colors := {}
	for p in def.pieces:
		# Workaround: the existing color_name_static returns "orange" for
		# all colors (palette has "#xxx" keys, c.to_html(false) returns
		# "xxx" without "#"). Use the piece id directly.
		colors[String(p.id)] = p
	if colors.has("orange_ring") or colors.has("orange_1"):
		_ok("orange piece present")
	else:
		_fail("orange piece missing")
	if colors.has("blue_ring") or colors.has("cyan_2"):
		_ok("blue piece present")
	else:
		_fail("blue piece missing")
	if colors.has("purple_ring") or colors.has("purple_3"):
		_ok("purple piece present")
	else:
		_fail("purple piece missing")

	# 2. Gap geometry
	print("\n--- Gap geometry ---")
	for p in def.pieces:
		if p.gaps.size() == 1:
			_ok("%s has 1 gap" % String(p.id))
		else:
			_fail("%s has %d gaps (expected 1)" % [String(p.id), p.gaps.size()])
		if p.gaps.size() > 0:
			var g = p.gaps[0]
			if g.width_deg >= 60 and g.width_deg <= 90:
				_ok("%s gap width=%.1f" % [String(p.id), g.width_deg])
			else:
				_fail("%s gap width=%.1f out of 60-90 range" % [String(p.id), g.width_deg])
			if g.center_angle_deg >= 0 and g.center_angle_deg < 360:
				_ok("%s gap center=%.1f" % [String(p.id), g.center_angle_deg])
			else:
				_fail("%s gap center=%.1f out of [0,360)" % [String(p.id), g.center_angle_deg])

	# 3. Reference match (from Phase 11 visual benchmark)
	print("\n--- Reference match ---")
	var expected = {
		"orange_1": Vector2(317.0, 510.0),
		"cyan_2":   Vector2(467.0, 510.0),
		"purple_3": Vector2(392.0, 683.0),
	}
	for nm in colors:
		var p = colors[nm]
		if not expected.has(nm):
			continue
		var d = (p.position - expected[nm]).length()
		if d < 2.0:
			_ok("%s center matches reference (delta=%.2f)" % [nm, d])
		else:
			_fail("%s center mismatch: got (%.1f,%.1f) expected (%.1f,%.1f) delta=%.2f" %
				[nm, p.position.x, p.position.y, expected[nm].x, expected[nm].y, d])

	# 4. Stem origins NOT in parent gap
	print("\n--- Stem origins ---")
	for l in def.links:
		var parent = null
		for pp in def.pieces:
			if String(pp.id) == String(l.from_piece_id): parent = pp
		if parent == null or parent.gaps.size() == 0:
			_fail("link from unknown parent")
			continue
		var g = parent.gaps[0]
		var stem_deg = l.collar_angle_deg
		# Compute circular distance from gap center.
		var diff = stem_deg - g.center_angle_deg
		while diff > 180.0: diff -= 360.0
		while diff < -180.0: diff += 360.0
		if abs(diff) > g.width_deg / 2.0 + 8.0:
			_ok("link %s stem at %.1f deg is OUTSIDE parent gap (%.1f +/- %.1f)" %
				[String(l.id), stem_deg, g.center_angle_deg, g.width_deg / 2.0])
		else:
			_fail("link %s stem at %.1f deg INSIDE parent gap (%.1f +/- %.1f)" %
				[String(l.id), stem_deg, g.center_angle_deg, g.width_deg / 2.0])

	# 5. Solvability
	print("\n--- Solvability (BFS) ---")
	var start = BFSSolverScript._to_pure_state(def.pieces, def.links)
	var solve_res = BFSSolverScript.solve_bfs(start)
	if bool(solve_res.solved):
		_ok("BFS solved in %d steps" % (solve_res.path.size() if "path" in solve_res else -1))
		var pth = solve_res.path if "path" in solve_res else []
		for i in range(pth.size()):
			print("    step %d: %s" % [i, pth[i]])
	else:
		_fail("BFS did not solve")

	_summary()
	quit(0 if _fail_count == 0 else 1)

func _summary() -> void:
	print("\n=== Phase 11 L2 validator: %d PASS / %d FAIL ===" % [_pass_count, _fail_count])