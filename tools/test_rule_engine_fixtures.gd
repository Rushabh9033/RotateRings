extends SceneTree

const PuzzleRules = preload("res://gameplay/puzzle_rules.gd")
const PieceGeometry = preload("res://gameplay/piece_geometry.gd")

func _init():
	var passed := 0
	var total := 0
	
	print("==========================================")
	print("RUNNING AUTHORITATIVE RULE ENGINE FIXTURES")
	print("==========================================")
	
	# Test A: Single open C-ring gap check
	total += 1
	var opening = PieceGeometry.usable_opening_length(PieceGeometry.ShapeType.CIRCLE, 60.0, 112.0, 24.0)
	if PieceGeometry.opening_accepts_cuff(opening, 14.0, 1.5):
		print("Test A (Single C-ring gap acceptance): PASSED")
		passed += 1
	else:
		print("Test A: FAILED")
		
	# Test B: Narrow gap rejection (Whole cuff width check)
	total += 1
	var narrow_opening = PieceGeometry.usable_opening_length(PieceGeometry.ShapeType.CIRCLE, 60.0, 10.0, 24.0)
	if not PieceGeometry.opening_accepts_cuff(narrow_opening, 14.0, 1.5):
		print("Test B (Narrow gap cuff rejection): PASSED")
		passed += 1
	else:
		print("Test B: FAILED")

	# Test C: State cloning determinism
	total += 1
	var s1 = PuzzleState.new()
	s1.pieces["ring_0"] = {"rotation_deg": 45.0, "released": false}
	var s2 = s1.clone()
	s2.pieces["ring_0"]["rotation_deg"] = 90.0
	if float(s1.pieces["ring_0"]["rotation_deg"]) == 45.0 and s1.get_hash() != s2.get_hash():
		print("Test C (State clone & hash isolation): PASSED")
		passed += 1
	else:
		print("Test C: FAILED")

	# Test D: Hash consistency
	total += 1
	var s3 = s1.clone()
	if s1.get_hash() == s3.get_hash():
		print("Test D (Deterministic hash equality): PASSED")
		passed += 1
	else:
		print("Test D: FAILED")
		
	print("------------------------------------------")
	print("Fixtures Passed: ", passed, " / ", total)
	print("==========================================")
	quit()
