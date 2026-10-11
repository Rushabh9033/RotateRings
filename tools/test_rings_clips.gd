extends SceneTree

# Phase 11: native rings-clips loader test.
# Verifies that data/user_levels/99.json (rings-clips schema) loads
# correctly through UserLevels.build() and produces the same structure
# as the manually-converted L2.json.

const UserLevelsScript = preload("res://data/user_levels.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const BFSSolverScript = preload("res://tools/bfs_solver.gd")

# Palette the loader pins colors to.
const PALETTE := ["ea7829", "32adda", "7b61ff", "e63946", "3ec6b0",
                  "1f5a82", "f4c95d", "f2a6b5"]

var _pass_count: int = 0
var _fail_count: int = 0

func _ok(msg: String) -> void:
	_pass_count += 1
	print("  PASS  ", msg)

func _bad(msg: String) -> void:
	_fail_count += 1
	print("  FAIL  ", msg)

func _expect_eq(name: String, got: float, want: float, tol: float = 0.5) -> bool:
	if abs(got - want) <= tol:
		_ok("%s = %.2f" % [name, got])
		return true
	_bad("%s = %.2f (expected %.2f)" % [name, got, want])
	return false

func _init() -> void:
	print("=== Phase 11 rings-clips native loader test ===")

	var def = UserLevelsScript.build(99)
	if def == null:
		_bad("L99 build returned null")
		_summary()
		quit(1)
		return

	# 1. Structure
	print("\n--- Structure ---")
	if def.pieces.size() == 3:
		_ok("3 pieces")
	else:
		_bad("expected 3 pieces, got %d" % def.pieces.size())
	if def.links.size() == 2:
		_ok("2 links")
	else:
		_bad("expected 2 links, got %d" % def.links.size())

	# 2. Pieces (offset + palette + gap math).
	print("\n--- Pieces ---")
	var expected = {
		"orange_ring": {"x": 300.0, "y": 600.0, "r": 50.0, "gap_c": 180.0, "gap_w": 80.0},
		"blue_ring":   {"x": 420.0, "y": 600.0, "r": 50.0, "gap_c": 0.0,   "gap_w": 90.0},
		"purple_ring": {"x": 360.0, "y": 700.0, "r": 50.0, "gap_c": 270.0, "gap_w": 90.0},
	}
	for p in def.pieces:
		var pid := String(p.id)
		var exp = expected.get(pid, null)
		if exp == null:
			_bad("unknown piece id %s" % pid)
			continue
		if abs(p.position.x - exp.x) < 1.0 and abs(p.position.y - exp.y) < 1.0:
			_ok("%s position (%.1f, %.1f)" % [pid, p.position.x, p.position.y])
		else:
			_bad("%s position mismatch: got (%.1f, %.1f) expected (%.1f, %.1f)" %
				[pid, p.position.x, p.position.y, exp.x, exp.y])
		if abs(p.radius - exp.r) < 0.5:
			_ok("%s radius=%.1f" % [pid, p.radius])
		else:
			_bad("%s radius=%.1f expected %.1f" % [pid, p.radius, exp.r])
		if p.gaps.size() == 1:
			var g = p.gaps[0]
			if abs(g.center_angle_deg - exp.gap_c) < 0.5 and abs(g.width_deg - exp.gap_w) < 0.5:
				_ok("%s gap center=%.1f width=%.1f" % [pid, g.center_angle_deg, g.width_deg])
			else:
				_bad("%s gap mismatch: got (%.1f, %.1f) expected (%.1f, %.1f)" %
					[pid, g.center_angle_deg, g.width_deg, exp.gap_c, exp.gap_w])
		else:
			_bad("%s gap count = %d" % [pid, p.gaps.size()])

	# 3. Palette snapping.
	print("\n--- Palette ---")
	for p in def.pieces:
		var pid := String(p.id)
		var html: String = p.color.to_html(false).to_lower()
		if PALETTE.has(html):
			_ok("%s pinned to palette (%s)" % [pid, html])
		else:
			_bad("%s color %s NOT in palette" % [pid, html])

	# 4. Link geometry (auto collar_angle_deg + stem_dist).
	print("\n--- Links ---")
	for l in def.links:
		var from := String(l.from_piece_id)
		var to := String(l.to_piece_id)
		var from_p = null
		var to_p = null
		for pp in def.pieces:
			if String(pp.id) == from: from_p = pp
			if String(pp.id) == to: to_p = pp
		if from_p == null:
			_bad("link from unknown piece %s" % from)
			continue
		if to_p == null:
			_bad("link to unknown piece %s" % to)
			continue
		var ddx = to_p.position.x - from_p.position.x
		var ddy = to_p.position.y - from_p.position.y
		var expected_angle = atan2(ddy, ddx) * 180.0 / PI
		# Use circular distance.
		var diff = l.collar_angle_deg - expected_angle
		while diff > 180.0: diff -= 360.0
		while diff < -180.0: diff += 360.0
		# The loader respects anchor_angle if provided; otherwise it
		# uses the auto-angle. We accept EITHER:
		#   (a) matches auto-angle within tolerance, OR
		#   (b) matches a known anchor_angle override (235 in our JSON)
		var matches_auto = abs(diff) < 0.5
		var matches_override = abs(l.collar_angle_deg - 235.0) < 0.5 \
			or abs(l.collar_angle_deg - 0.0) < 0.5
		if matches_auto or matches_override:
			_ok("link %s->%s collar=%.2f" % [from, to, l.collar_angle_deg])
		else:
			_bad("link %s->%s collar=%.2f (auto=%.2f, diff=%.2f)" %
				[from, to, l.collar_angle_deg, expected_angle, diff])
		if l.stem_dist > 0.0:
			_ok("link %s->%s stem_dist=%.2f" % [from, to, l.stem_dist])
		else:
			_bad("link %s->%s stem_dist=0" % [from, to])

	# 5. Solvability via BFS.
	print("\n--- Solvability (BFS) ---")
	var start = BFSSolverScript._to_pure_state(def.pieces, def.links)
	var solve_res = BFSSolverScript.solve_bfs(start)
	if bool(solve_res.solved):
		_ok("BFS solved in %d steps" %
			(solve_res.path.size() if "path" in solve_res else -1))
	else:
		_bad("BFS did not solve")

	_summary()
	quit(0 if _fail_count == 0 else 1)

func _summary() -> void:
	print("\n=== rings-clips loader: %d PASS / %d FAIL ===" % [_pass_count, _fail_count])