extends SceneTree

const Harness = preload("res://tools/level_engine_harness.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")
const LevelDatabase = preload("res://data/level_database.gd")
const RingPiece = preload("res://gameplay/ring_piece_2d.gd")
const Connector = preload("res://gameplay/connector_runtime.gd")

func _init() -> void:
	print("\n=== CONNECTOR IDENTITY ===")
	var ok := true
	ok = _test_level4_bottom() and ok
	ok = _test_all_levels_mismatch() and ok
	if ok:
		print("SUCCESS: a gap clears only the connector it is aimed at")
		quit(0)
	else:
		print("FAILED: connector identity")
		quit(1)

func _test_level4_bottom() -> bool:
	print("\n(1) level 4 bottom cyan ring, red tab vs green tab")
	var built := Harness.build_level(4)
	var piece = Rules.get_piece_by_id(&"ring_4", built.pieces)
	var red = _link_between(built.links, &"ring_2", &"ring_4")
	var green = _link_between(built.links, &"ring_3", &"ring_4")
	if piece == null or red == null or green == null:
		print("  FAIL missing bottom ring or its two parent connectors")
		_free(built)
		return false
	if not _mismatch_pair(4, piece, red, green, built):
		_free(built)
		return false
	if not _mismatch_pair(4, piece, green, red, built):
		_free(built)
		return false
	var align_red: float = Rules.alignment_rotation_deg(piece, red, built.pieces, piece.gaps[0])
	for off in [8.0, -8.0]:
		var cap: Array = Rules.evaluate_clearance_hypothetical(piece, align_red + off, built.pieces, built.links)
		if not cap.is_empty():
			print("  FAIL cap pose ", off, " detached a connector")
			_free(built)
			return false
	var tube: Array = Rules.evaluate_clearance_hypothetical(piece, piece.rotation_degrees, built.pieces, built.links)
	if not tube.is_empty():
		print("  FAIL starting tube pose detached a connector")
		_free(built)
		return false
	_free(built)
	if not _sequential_release(4, &"ring_4", &"ring_2", &"ring_3"):
		return false
	print("  PASS level 4")
	return true

func _test_all_levels_mismatch() -> bool:
	print("\n(2) levels 1-12 multi-connector children")
	var total := LevelDatabase.get_total_levels()
	var pairs := 0
	for level_id in range(1, total + 1):
		var built := Harness.build_level(level_id)
		var grouped := {}
		for link in built.links:
			if link.state != Connector.State.ENGAGED:
				continue
			if not grouped.has(link.def.to_piece_id):
				grouped[link.def.to_piece_id] = []
			grouped[link.def.to_piece_id].append(link)
		for child_id in grouped.keys():
			var holders: Array = grouped[child_id]
			if holders.size() < 2:
				continue
			var piece = Rules.get_piece_by_id(child_id, built.pieces)
			if piece == null or piece.gaps == null or piece.gaps.is_empty():
				continue
			for i in range(holders.size()):
				for j in range(holders.size()):
					if i == j:
						continue
					pairs += 1
					if not _mismatch_pair(level_id, piece, holders[i], holders[j], built):
						_free(built)
						return false
		_free(built)
	if pairs == 0:
		print("  FAIL no multi-connector children found")
		return false
	print("  PASS ", pairs, " aimed-at-the-other-tab checks")
	return true

func _mismatch_pair(level_id: int, piece, link_a, link_b, built: Dictionary) -> bool:
	var align_b := _claimed_alignment(piece, link_b, built)
	if align_b < 0.0:
		print("  FAIL level ", level_id, " ", piece.piece_id, " no opening claims ", link_b.def.from_piece_id)
		return false
	var aimed: Array = Rules.evaluate_clearance_hypothetical(piece, align_b, built.pieces, built.links)
	if _contains_link(aimed, link_a):
		print("  FAIL level ", level_id, " ", piece.piece_id, " gap on ", link_b.def.from_piece_id, " also cleared ", link_a.def.from_piece_id)
		return false
	if aimed.size() != 1 or not _contains_link(aimed, link_b):
		print("  FAIL level ", level_id, " ", piece.piece_id, " alignment of ", link_b.def.from_piece_id, " cleared ", aimed.size(), " connectors")
		return false
	var saved_rot: float = piece.rotation_degrees
	piece.rotation_degrees = align_b
	var clearing: Array = Rules.evaluate_clearance(piece, built.pieces, built.links)
	for link in clearing:
		Rules.complete_clearance(link)
	var child_released: bool = Rules.is_piece_releasable(piece, built.pieces, built.links) or not _alive(piece)
	var other_cleared: bool = link_a.state != Connector.State.ENGAGED
	for link in clearing:
		link.state = Connector.State.ENGAGED
		link.current_stem_dist = link.def.stem_dist
	piece.rotation_degrees = saved_rot
	if other_cleared or child_released:
		print("  FAIL level ", level_id, " ", piece.piece_id, " released or cleared ", link_a.def.from_piece_id, " while aimed at ", link_b.def.from_piece_id)
		return false
	return true

func _claimed_alignment(piece, link, built: Dictionary) -> float:
	for gap in piece.gaps:
		var align: float = Rules.alignment_rotation_deg(piece, link, built.pieces, gap)
		if Rules.opening_claims_link(piece, align, link, built.pieces, built.links):
			return align
	return -1.0

func _sequential_release(level_id: int, child_id: StringName, first_parent: StringName, second_parent: StringName) -> bool:
	var built := Harness.build_level(level_id)
	var piece = Rules.get_piece_by_id(child_id, built.pieces)
	var first = _link_between(built.links, first_parent, child_id)
	var second = _link_between(built.links, second_parent, child_id)
	var align_first := _claimed_alignment(piece, first, built)
	var locked_try: Dictionary = Rules.apply_settled_rotation(piece, align_first, built.pieces, built.links)
	if not Rules.is_piece_rotatable(piece, built.pieces, built.links):
		if bool(locked_try.applied):
			print("  FAIL level ", level_id, " ", child_id, " turned while a child still held it")
			_free(built)
			return false
		for link in built.links:
			if link.def.from_piece_id != piece.piece_id:
				continue
			var held = Rules.get_piece_by_id(link.def.to_piece_id, built.pieces)
			if held != null and held.state != RingPiece.State.RELEASED:
				held.state = RingPiece.State.RELEASED
				Rules.on_piece_released(held, built.links)
		if not Rules.is_piece_rotatable(piece, built.pieces, built.links):
			print("  FAIL level ", level_id, " ", child_id, " stayed locked after its child left")
			_free(built)
			return false
	var step_one: Dictionary = Rules.apply_settled_rotation(piece, align_first, built.pieces, built.links)
	if not step_one.applied or first.state != Connector.State.DETACHED or second.state != Connector.State.ENGAGED:
		print("  FAIL level ", level_id, " first parent ", first_parent, " did not clear alone. applied=", step_one.applied, " first=", first.state, " second=", second.state)
		_free(built)
		return false
	if not _alive(piece):
		print("  FAIL level ", level_id, " ", child_id, " released after only ", first_parent, " cleared")
		_free(built)
		return false
	var align_second := _claimed_alignment(piece, second, built)
	var step_two: Dictionary = Rules.apply_settled_rotation(piece, align_second, built.pieces, built.links)
	if not step_two.applied or second.state != Connector.State.DETACHED or _alive(piece):
		print("  FAIL level ", level_id, " ", child_id, " did not release after both connectors. applied=", step_two.applied, " second=", second.state, " alive=", _alive(piece))
		_free(built)
		return false
	_free(built)
	return true

func _link_between(links: Array, from_id: StringName, to_id: StringName):
	for link in links:
		if link.def.from_piece_id == from_id and link.def.to_piece_id == to_id:
			return link
	return null

func _contains_link(list: Array, link) -> bool:
	for item in list:
		if item == link:
			return true
	return false

func _alive(piece) -> bool:
	return piece.state != RingPiece.State.RELEASED and piece.state != RingPiece.State.RELEASING

func _free(built: Dictionary) -> void:
	for piece in built.pieces:
		if is_instance_valid(piece):
			piece.free()
