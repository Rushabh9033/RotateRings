extends SceneTree

const Board = preload("res://data/campaign_board.gd")
const RuleEngine = preload("res://gameplay/puzzle_rules.gd")
const BFSSolverScript = preload("res://tools/bfs_solver.gd")
const PieceGeometry = preload("res://gameplay/piece_geometry.gd")
const PuzzleStateClass = preload("res://gameplay/puzzle_state.gd")
const PuzzleActionClass = preload("res://gameplay/puzzle_action.gd")

func _init():
	Board._defer_solve = true
	print("==================================================================================")
	print("RUNNING AUTHORITATIVE ENGINE REGRESSION TEST SUITE (TESTS A - H)")
	print("==================================================================================")
	
	var passed := 0
	var total := 8
	
	if test_a_sequential_multi_parent(): passed += 1
	if test_b_detached_connector_non_blocking(): passed += 1
	if test_c_narrow_gap_false_positive(): passed += 1
	if test_d_tunneling_and_path_equivalence(): passed += 1
	if test_e_solver_runtime_parity(): passed += 1
	if test_f_solver_start_state_non_mutation(): passed += 1
	if test_g_replay_proof_engine(): passed += 1
	if test_h_clone_isolation_and_hash_equality(): passed += 1

	print("==================================================================================")
	print("REGRESSION SUITE RESULTS: Passed %d / %d Tests" % [passed, total])
	if passed == total:
		print("STATUS: 100% PERFECT PASS! ALL MANDATORY REGRESSION LAWS VERIFIED!")
	else:
		print("STATUS: FAILED — REGRESSION LAWS VIOLATED!")
	print("==================================================================================")
	quit()

# ------------------------------------------------------------------------------
# TEST A: Sequential Multi-Parent Clearance (A -> X <- B)
# ------------------------------------------------------------------------------
func test_a_sequential_multi_parent() -> bool:
	print("Test A (Sequential Multi-Parent A -> X <- B):")
	var state = PuzzleStateClass.new()
	state.pieces["A"] = { "id": &"A", "piece_id": &"A", "radius": 68.0, "thickness": 24.0, "rotation_deg": 0.0, "shape_type": 0, "role": 1, "gaps": [], "state": 0 }
	state.pieces["B"] = { "id": &"B", "piece_id": &"B", "radius": 68.0, "thickness": 24.0, "rotation_deg": 0.0, "shape_type": 0, "role": 1, "gaps": [], "state": 0 }
	state.pieces["X"] = { "id": &"X", "piece_id": &"X", "radius": 56.0, "thickness": 24.0, "rotation_deg": 0.0, "shape_type": 0, "role": 0, "gaps": [{ "center_angle_deg": 0.0, "width_deg": 120.0 }], "state": 0, "position": Vector2(100, 0) }
	
	# Connectors from A to X and B to X
	state.connectors["link_A"] = { "id": &"link_A", "from_piece_id": &"A", "to_piece_id": &"X", "collar_angle_deg": 0.0, "stem_dist": 100.0, "state": 0 }
	state.connectors["link_B"] = { "id": &"link_B", "from_piece_id": &"B", "to_piece_id": &"X", "collar_angle_deg": 180.0, "stem_dist": 100.0, "state": 0 }
	
	# 1. Clear A-X link
	state.connectors["link_A"]["state"] = 2 # DETACHED
	var releasable_after_A := RuleEngine.is_pure_piece_releasable(state, &"X")
	
	# 2. Clear B-X link
	state.connectors["link_B"]["state"] = 2 # DETACHED
	var releasable_after_B := RuleEngine.is_pure_piece_releasable(state, &"X")
	
	var ok: bool = (not releasable_after_A) and releasable_after_B
	print("  -> Link A detached, X releasable=", releasable_after_A, " | Link B detached, X releasable=", releasable_after_B, " => ", "PASSED" if ok else "FAILED")
	return ok

# ------------------------------------------------------------------------------
# TEST B: Detached Connector Non-Blocking
# ------------------------------------------------------------------------------
func test_b_detached_connector_non_blocking() -> bool:
	print("Test B (Detached Connector Non-Blocking):")
	var state = PuzzleStateClass.new()
	state.pieces["parent"] = { "id": &"parent", "piece_id": &"parent", "radius": 68.0, "thickness": 24.0, "rotation_deg": 0.0, "shape_type": 0, "role": 0, "gaps": [{ "center_angle_deg": 0.0, "width_deg": 60.0 }], "state": 0 }
	state.pieces["child"] = { "id": &"child", "piece_id": &"child", "radius": 56.0, "thickness": 24.0, "rotation_deg": 0.0, "shape_type": 0, "role": 0, "gaps": [], "state": 6 } # Child released!
	state.connectors["link_1"] = { "id": &"link_1", "from_piece_id": &"parent", "to_piece_id": &"child", "collar_angle_deg": 0.0, "stem_dist": 100.0, "state": 2 } # DETACHED!
	
	var rotatable := RuleEngine.is_pure_piece_rotatable(state, &"parent")
	print("  -> Parent rotatable after child release=", rotatable, " => ", "PASSED" if rotatable else "FAILED")
	return rotatable

# ------------------------------------------------------------------------------
# TEST C: Narrow-Gap False Positive Rejection
# ------------------------------------------------------------------------------
func test_c_narrow_gap_false_positive() -> bool:
	print("Test C (Narrow-Gap False Positive Rejection):")
	# Cuff width is 22px, safety margin 2px -> required opening is 26px
	# Create a gap of width 5 degrees on radius 68px -> opening length = 68 * 2PI * (5/360) = 5.93px
	# Center is perfectly aligned at 0 degrees
	var opening_len := PieceGeometry.usable_opening_length(0, 68.0, 5.0, 24.0)
	var accepts := PieceGeometry.opening_accepts_cuff(opening_len, 22.0, 2.0)
	
	var ok: bool = (not accepts)
	print("  -> Narrow gap (5 deg opening = %.2fpx vs 26px required) accepted=" % opening_len, accepts, " => ", "PASSED" if ok else "FAILED")
	return ok

# ------------------------------------------------------------------------------
# TEST D: Rotational Tunneling & Path Equivalence
# ------------------------------------------------------------------------------
func test_d_tunneling_and_path_equivalence() -> bool:
	print("Test D (Rotational Tunneling & Path Equivalence):")
	var def = Board.build(1)
	var built1 = Board._spawn(def)
	var built2 = Board._spawn(def)
	
	var p1 = RuleEngine.get_piece_by_id(&"ring_1", built1.pieces)
	var p2 = RuleEngine.get_piece_by_id(&"ring_1", built2.pieces)
	
	# One large step: 0 -> 90 degrees
	RuleEngine.apply_settled_rotation(p1, 90.0, built1.pieces, built1.links)
	
	# Small steps: 0 -> 30 -> 60 -> 90 degrees
	RuleEngine.apply_settled_rotation(p2, 30.0, built2.pieces, built2.links)
	RuleEngine.apply_settled_rotation(p2, 60.0, built2.pieces, built2.links)
	RuleEngine.apply_settled_rotation(p2, 90.0, built2.pieces, built2.links)
	
	var ok: bool = (absf(p1.rotation_degrees - p2.rotation_degrees) < 0.01) and (p1.state == p2.state)
	print("  -> Final rotations: Large=%.1f°, Stepwise=%.1f° | States match=" % [p1.rotation_degrees, p2.rotation_degrees], ok, " => ", "PASSED" if ok else "FAILED")
	
	Board._free_nodes(built1.pieces)
	Board._free_nodes(built2.pieces)
	return ok

# ------------------------------------------------------------------------------
# TEST E: Solver / Runtime Parity
# ------------------------------------------------------------------------------
func test_e_solver_runtime_parity() -> bool:
	print("Test E (Solver / Runtime Parity):")
	var def = Board.build(2)
	var built = Board._spawn(def)
	
	# Build pure state from definition
	var pure_state = BFSSolverScript._to_pure_state(def.pieces, def.links)
	
	# Calculate target rotation for ring_2 that aligns its gap with link_1
	var p2_pure: Dictionary = pure_state.pieces[&"ring_2"]
	var p1_pure: Dictionary = pure_state.pieces[&"ring_1"]
	var link1: Dictionary = pure_state.connectors[&"link_1"]
	
	var world_rad: float = deg_to_rad(float(p1_pure.rotation_deg) + float(link1.collar_angle_deg))
	var dir_cuff := Vector2.from_angle(world_rad)
	var child_r: float = PieceGeometry.get_world_boundary_distance(int(p2_pure.shape_type), float(p2_pure.radius), deg_to_rad(float(p2_pure.rotation_deg)), dir_cuff.angle() + PI)
	var pos_cuff: Vector2 = Vector2(p1_pure.position) + dir_cuff * (float(link1.stem_dist) - child_r)
	var rel: Vector2 = pos_cuff - Vector2(p2_pure.position)
	var contact_world := fposmod(rad_to_deg(rel.angle()), 360.0)
	var target_rot := fposmod(contact_world - float(p2_pure.gaps[0].center_angle_deg), 360.0)
	
	# Apply action (rotate ring_2 to target)
	var act := PuzzleActionClass.new(&"ring_2", float(p2_pure.rotation_deg), target_rot, 1)
	var pure_res = RuleEngine.apply_action(pure_state, act)
	
	# Apply same action to runtime built nodes
	var p_target = RuleEngine.get_piece_by_id(&"ring_2", built.pieces)
	var runtime_res = RuleEngine.apply_settled_rotation(p_target, target_rot, built.pieces, built.links)
	
	var ok: bool = bool(pure_res.applied) and bool(runtime_res.applied) and (pure_res.released_pieces.size() == runtime_res.released.size())
	print("  -> Pure applied=", pure_res.applied, " Runtime applied=", runtime_res.applied, " Released count match=", (pure_res.released_pieces.size() == runtime_res.released.size()), " => ", "PASSED" if ok else "FAILED")
	
	Board._free_nodes(built.pieces)
	return ok

# ------------------------------------------------------------------------------
# TEST F: Solver Non-Mutation of Start State
# ------------------------------------------------------------------------------
func test_f_solver_start_state_non_mutation() -> bool:
	print("Test F (Solver Non-Mutation of Start State):")
	var def = Board.build(3)
	var pure_state = BFSSolverScript._to_pure_state(def.pieces, def.links)
	var hash_before: String = pure_state.get_hash()
	
	# Run solver on pure state
	var res = BFSSolverScript.solve_bfs(pure_state)
	var hash_after: String = pure_state.get_hash()
	
	var ok: bool = (hash_before == hash_after) and bool(res.solved)
	print("  -> Hash before == Hash after: ", (hash_before == hash_after), " | Solved=", res.solved, " => ", "PASSED" if ok else "FAILED")
	return ok

# ------------------------------------------------------------------------------
# TEST G: Replay Proof Engine
# ------------------------------------------------------------------------------
func test_g_replay_proof_engine() -> bool:
	print("Test G (Replay Proof Engine):")
	var def = Board.build(4)
	var start_state = BFSSolverScript._to_pure_state(def.pieces, def.links)
	
	var solve_res = BFSSolverScript.solve_bfs(start_state)
	if not bool(solve_res.solved):
		print("  -> Solver failed to solve Level 4!")
		return false
		
	# Replay optimal path on fresh state
	var fresh_state = BFSSolverScript._to_pure_state(def.pieces, def.links)
	var replay_ok := true
	
	for step in solve_res.path:
		var act = PuzzleActionClass.from_dict(step)
		var step_res = RuleEngine.apply_action(fresh_state, act)
		if not bool(step_res.applied):
			replay_ok = false
			break
		fresh_state = step_res.next_state
		
	var won := RuleEngine.is_pure_state_won(fresh_state)
	var ok: bool = replay_ok and won
	print("  -> Level 4 Replay Proof: won=", won, " replay_ok=", replay_ok, " => ", "PASSED" if ok else "FAILED")
	return ok

# ------------------------------------------------------------------------------
# TEST H: Clone Isolation & Deterministic Hash Equality
# ------------------------------------------------------------------------------
func test_h_clone_isolation_and_hash_equality() -> bool:
	print("Test H (Clone Isolation & Deterministic Hash Equality):")
	var def = Board.build(1)
	var state1 = BFSSolverScript._to_pure_state(def.pieces, def.links)
	var state2 = state1.clone()
	
	var hash1: String = state1.get_hash()
	var hash2: String = state2.get_hash()
	var equal_at_start: bool = (hash1 == hash2)
	
	# Mutate clone
	state2.pieces["ring_1"]["rotation_deg"] = 180.0
	var hash2_mutated: String = state2.get_hash()
	var hash1_after: String = state1.get_hash()
	
	var isolated: bool = (hash1 == hash1_after) and (hash1 != hash2_mutated)
	var ok: bool = equal_at_start and isolated
	print("  -> Initial Hash Equal=", equal_at_start, " | Clone Mutation Isolated=", isolated, " => ", "PASSED" if ok else "FAILED")
	return ok
