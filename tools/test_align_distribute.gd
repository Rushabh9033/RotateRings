extends SceneTree

# Smoke test for M7: align / distribute / match-axis on LevelDocument.

const LevelDocumentScript = preload("res://data/level_document.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")

var _failures: Array = []

func _init() -> void:
	_test_align_left()
	_test_align_right()
	_test_align_center()
	_test_match_axis()
	_test_distribute()
	_test_undo_align()
	_test_locked_ignored()
	if _failures.is_empty():
		print("TEST PASS: M7 (align + distribute + match axis) works")
		quit(0)
	else:
		_report()
		quit(1)

func _make_doc() -> Resource:
	var doc := LevelDocumentScript.new()
	doc.level_id = 1
	for i in range(4):
		var p := PieceDefinitionScript.new()
		p.id = "p%d" % (i + 1)
		p.position = Vector2(100.0 + float(i) * 50.0, 200.0 + float(i) * 30.0)
		p.radius = 40.0
		p.thickness = 18.0
		p.color = Color("#EA7829")
		p.shape_type = PieceDefinitionScript.ShapeType.CIRCLE
		p.gaps = [GapDefinitionScript.new(270.0, 80.0, 16.0)]
		doc.pieces.append(p.to_dict())
	return doc

func _test_align_left() -> void:
	var doc := _make_doc()
	# Reference = p1, align all to its left edge.
	doc.align_pieces(["p1", "p2", "p3", "p4"], "x", "left")
	var p2: Dictionary = doc.find_piece("p2")
	# p1.x = 100, p1.r = 40 → left edge = 60. p2 should also have x - r = 60,
	# so x = 100.
	if absf(float(p2["x"]) - 100.0) > 0.001: _fail("align left: p2.x = %f" % float(p2["x"]))

func _test_align_right() -> void:
	var doc := _make_doc()
	doc.align_pieces(["p1", "p2", "p3", "p4"], "x", "right")
	var p2: Dictionary = doc.find_piece("p2")
	# p1.x=100, r=40 → right edge = 140. p2 should also have x = 100.
	if absf(float(p2["x"]) - 100.0) > 0.001: _fail("align right: p2.x = %f" % float(p2["x"]))

func _test_align_center() -> void:
	var doc := _make_doc()
	doc.align_pieces(["p1", "p2", "p3", "p4"], "x", "center")
	# All p[i].x should equal p1.x = 100.
	for i in range(2, 5):
		var pid: String = "p%d" % i
		var p: Dictionary = doc.find_piece(pid)
		if absf(float(p["x"]) - 100.0) > 0.001:
			_fail("align center: %s.x = %f" % [pid, float(p["x"])])

func _test_match_axis() -> void:
	var doc := _make_doc()
	# match x: copy p1.x (100) to all.
	doc.match_axis(["p1", "p2", "p3", "p4"], "x")
	for i in range(2, 5):
		var pid: String = "p%d" % i
		var p: Dictionary = doc.find_piece(pid)
		if absf(float(p["x"]) - 100.0) > 0.001:
			_fail("match x: %s.x = %f" % [pid, float(p["x"])])

func _test_distribute() -> void:
	var doc := _make_doc()
	# Force p2/p3/p4 to varied x so the distribute has range to work with.
	doc.apply_edit(func():
		doc.pieces[1]["x"] = 200.0
		doc.pieces[2]["x"] = 500.0
		doc.pieces[3]["x"] = 800.0
	)
	doc.distribute_pieces(["p1", "p2", "p3", "p4"], "x")
	# After distribute, spacing should be even between p1.x (100) and p4.x (800).
	# step = 700/3 ≈ 233.33
	var p2: Dictionary = doc.find_piece("p2")
	var p3: Dictionary = doc.find_piece("p3")
	var expected2: float = 100.0 + 700.0 / 3.0
	var expected3: float = 100.0 + 2.0 * 700.0 / 3.0
	if absf(float(p2["x"]) - expected2) > 0.5: _fail("distribute p2: got %f expected %f" % [float(p2["x"]), expected2])
	if absf(float(p3["x"]) - expected3) > 0.5: _fail("distribute p3: got %f expected %f" % [float(p3["x"]), expected3])

func _test_undo_align() -> void:
	var doc := _make_doc()
	doc.align_pieces(["p1", "p2", "p3", "p4"], "x", "center")
	# p2.x should now be 100.
	doc.undo()
	var p2: Dictionary = doc.find_piece("p2")
	# Original p2.x = 150.
	if absf(float(p2["x"]) - 150.0) > 0.001: _fail("undo didn't revert: p2.x = %f" % float(p2["x"]))

func _test_locked_ignored() -> void:
	var doc := _make_doc()
	doc.set_property_lock("p2", "position", true)
	doc.align_pieces(["p1", "p2", "p3", "p4"], "x", "center")
	var p2: Dictionary = doc.find_piece("p2")
	# p2 is locked, so its x shouldn't change.
	if absf(float(p2["x"]) - 150.0) > 0.001: _fail("locked p2 moved anyway: %f" % float(p2["x"]))

func _fail(msg: String) -> void:
	_failures.append(msg)
	print("FAIL: ", msg)

func _report() -> void:
	print("=== %d failure(s) ===" % _failures.size())
	for f in _failures:
		print("  - ", f)