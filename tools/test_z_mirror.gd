extends SceneTree

# Smoke test for M16 (mirror) and M17 (z-order) on LevelDocument.

const LevelDocumentScript = preload("res://data/level_document.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")

var _failures: Array = []

func _init() -> void:
	_test_z_set()
	_test_z_bring_forward()
	_test_z_send_backward()
	_test_z_to_front()
	_test_z_to_back()
	_test_mirror_vertical()
	_test_mirror_horizontal()
	_test_z_lock_guard()
	_test_mirror_lock_guard()
	if _failures.is_empty():
		print("TEST PASS: M16 + M17 (mirror + z-order controls) work")
		quit(0)
	else:
		_report()
		quit(1)

func _make_doc() -> Resource:
	var doc := LevelDocumentScript.new()
	doc.level_id = 1
	for i in range(3):
		var p := PieceDefinitionScript.new()
		p.id = "p%d" % (i + 1)
		p.position = Vector2(100.0 + float(i) * 50.0, 100.0)
		p.radius = 40.0
		p.thickness = 18.0
		p.color = Color("#EA7829")
		p.shape_type = PieceDefinitionScript.ShapeType.CIRCLE
		p.gaps = [GapDefinitionScript.new(270.0, 80.0, 16.0)]
		p.z_index = i + 1
		doc.pieces.append(p.to_dict())
	return doc

func _test_z_set() -> void:
	var doc := _make_doc()
	doc.set_z_index("p1", 99)
	if int(doc.find_piece("p1")["z_index"]) != 99: _fail("set_z_index didn't take")
	doc.undo()
	if int(doc.find_piece("p1")["z_index"]) != 1: _fail("undo didn't revert z_index")

func _test_z_bring_forward() -> void:
	var doc := _make_doc()
	doc.bring_forward("p1")
	if int(doc.find_piece("p1")["z_index"]) != 2: _fail("bring_forward: got %d" % int(doc.find_piece("p1")["z_index"]))

func _test_z_send_backward() -> void:
	var doc := _make_doc()
	doc.send_backward("p3")
	if int(doc.find_piece("p3")["z_index"]) != 2: _fail("send_backward: got %d" % int(doc.find_piece("p3")["z_index"]))

func _test_z_to_front() -> void:
	var doc := _make_doc()
	doc.bring_to_front("p1")
	# Max existing was 3 (p3). New is 4.
	if int(doc.find_piece("p1")["z_index"]) != 4: _fail("bring_to_front: got %d" % int(doc.find_piece("p1")["z_index"]))

func _test_z_to_back() -> void:
	var doc := _make_doc()
	doc.send_to_back("p3")
	# Min existing was 1 (p1). New is 0.
	if int(doc.find_piece("p3")["z_index"]) != 0: _fail("send_to_back: got %d" % int(doc.find_piece("p3")["z_index"]))

func _test_mirror_vertical() -> void:
	var doc := _make_doc()
	# 3 pieces at x=100, 150, 200. Selection bbox: x [60, 240], center 150.
	# Mirror around x=150: p1 (100) -> 200, p2 (150) -> 150, p3 (200) -> 100.
	doc.mirror_pieces(["p1", "p2", "p3"], "vertical")
	if absf(float(doc.find_piece("p1")["x"]) - 200.0) > 0.001: _fail("p1 mirror: got %f" % float(doc.find_piece("p1")["x"]))
	if absf(float(doc.find_piece("p3")["x"]) - 100.0) > 0.001: _fail("p3 mirror: got %f" % float(doc.find_piece("p3")["x"]))

func _test_mirror_horizontal() -> void:
	var doc := _make_doc()
	doc.pieces[0]["y"] = 50.0
	doc.pieces[1]["y"] = 100.0
	doc.pieces[2]["y"] = 200.0
	doc.mirror_pieces(["p1", "p2", "p3"], "horizontal")
	if absf(float(doc.find_piece("p1")["y"]) - 200.0) > 0.001: _fail("p1 horizontal: got %f" % float(doc.find_piece("p1")["y"]))
	if absf(float(doc.find_piece("p3")["y"]) - 50.0) > 0.001: _fail("p3 horizontal: got %f" % float(doc.find_piece("p3")["y"]))

func _test_z_lock_guard() -> void:
	# z-index doesn't have a position lock guard per se; the lock system
	# only covers position/size/rotation/gaps/motion/visual/connectors.
	# Verify bring_forward works even with position lock.
	var doc := _make_doc()
	doc.set_property_lock("p1", "position", true)
	doc.bring_forward("p1")
	if int(doc.find_piece("p1")["z_index"]) != 2: _fail("z forward should ignore position lock: got %d" % int(doc.find_piece("p1")["z_index"]))

func _test_mirror_lock_guard() -> void:
	var doc := _make_doc()
	doc.set_property_lock("p2", "position", true)
	doc.mirror_pieces(["p1", "p2", "p3"], "vertical")
	# p2 is locked, should not move.
	if absf(float(doc.find_piece("p2")["x"]) - 150.0) > 0.001: _fail("p2 moved despite lock")
	# p1 and p3 should still move.
	if absf(float(doc.find_piece("p1")["x"]) - 200.0) > 0.001: _fail("p1 didn't mirror")

func _fail(msg: String) -> void:
	_failures.append(msg)
	print("FAIL: ", msg)

func _report() -> void:
	print("=== %d failure(s) ===" % _failures.size())
	for f in _failures:
		print("  - ", f)