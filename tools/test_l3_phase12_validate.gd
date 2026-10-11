extends SceneTree

# Phase 12: L3 focused validator.
# For each authored piece, check structure + gap + stems.

const LevelDatabaseScript = preload("res://data/level_database.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const BFSSolverScript = preload("res://tools/bfs_solver.gd")

var _pass: int = 0
var _fail: int = 0

func _ok(msg: String) -> void:
	_pass += 1
	print("  PASS  ", msg)

func _bad(msg: String) -> void:
	_fail += 1
	print("  FAIL  ", msg)

func _init() -> void:
	var level_id := 3
	print("=== Phase 12 L3 focused validator ===")
	var def = LevelDatabaseScript.get_level(level_id)
	if def == null:
		_bad("L3 build returned null")
		_summary()
		quit(1)
		return

	# 1. Structure
	print("\n--- Structure ---")
	if def.pieces.size() == 4:
		_ok("4 pieces")
	else:
		_bad("expected 4 pieces, got %d" % def.pieces.size())
	if def.links.size() == 4:
		_ok("4 links")
	else:
		_bad("expected 4 links, got %d" % def.links.size())

	# 2. Pieces
	print("\n--- Pieces ---")
	for p in def.pieces:
		var pid: String = String(p.id)
		var exp_radius: float = 90.0
		if abs(p.radius - exp_radius) < 5.0:
			_ok("%s radius=%.1f" % [pid, p.radius])
		else:
			_bad("%s radius=%.1f expected ~%.1f" % [pid, p.radius, exp_radius])
		if p.gaps.size() == 1:
			var g = p.gaps[0]
			_ok("%s has 1 gap (center=%.1f width=%.1f)" % [pid, g.center_angle_deg, g.width_deg])
		else:
			_bad("%s gap count = %d" % [pid, p.gaps.size()])

	# 3. Solvability
	print("\n--- Solvability (BFS) ---")
	var start = BFSSolverScript._to_pure_state(def.pieces, def.links)
	var solve_res = BFSSolverScript.solve_bfs(start)
	if bool(solve_res.solved):
		var n_steps: int = solve_res.path.size() if "path" in solve_res else -1
		_ok("BFS solved in %d steps" % n_steps)
		for i in range(solve_res.path.size()):
			print("    step %d: %s" % [i, solve_res.path[i]])
	else:
		_bad("BFS did not solve")

	_summary()
	quit(0 if _fail == 0 else 1)

func _summary() -> void:
	print("\n=== L3 validator: %d PASS / %d FAIL ===" % [_pass, _fail])