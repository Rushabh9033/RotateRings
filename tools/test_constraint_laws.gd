extends SceneTree

const Rules = preload("res://gameplay/puzzle_rules.gd")
const PieceGeometry = preload("res://gameplay/piece_geometry.gd")
const RingPiece = preload("res://gameplay/ring_piece_2d.gd")
const PieceDef = preload("res://data/piece_definition.gd")
const GapDef = preload("res://data/gap_definition.gd")
const LinkDef = preload("res://data/link_definition.gd")
const Connector = preload("res://gameplay/connector_runtime.gd")

func _init() -> void:
	print("\n=== CONSTRAINT LAWS ===")
	var ok := true
	ok = _test_multi_parent() and ok
	ok = _test_chain() and ok
	ok = _test_fast_swipe() and ok
	ok = _test_snap() and ok
	if ok:
		print("SUCCESS: constraint laws passed")
		quit(0)
	else:
		print("FAILED: constraint laws")
		quit(1)

func _ring(id: StringName, pos: Vector2, rot: float, gaps: Array) -> Node2D:
	var piece = RingPiece.new()
	var def = PieceDef.new(id, pos, 76.0, 24.0, Color.WHITE, rot, gaps)
	piece.setup(def)
	piece.position = pos
	return piece

func _link(id: StringName, from_piece: Node2D, to_piece: Node2D) -> RefCounted:
	var link_def = LinkDef.new(id, from_piece.piece_id, to_piece.piece_id, Color.WHITE)
	Rules.bind_connector(link_def, from_piece.position, from_piece.rotation_degrees, to_piece.position)
	var runtime = Connector.new(link_def)
	runtime.current_stem_dist = link_def.stem_dist
	return runtime

func _alive(piece: Node2D) -> bool:
	return piece.state != RingPiece.State.RELEASED and piece.state != RingPiece.State.RELEASING

func _test_multi_parent() -> bool:
	print("\n(a) multi-parent sequential clear")
	var gap := [GapDef.new(0.0, 56.0, 6.0)]
	var cuff := _ring(&"c", Vector2(400, 400), 0.0, gap)
	var parent_a := _ring(&"a", Vector2(400, 220), 0.0, [])
	var parent_b := _ring(&"b", Vector2(580, 400), 0.0, [])
	var pieces: Array = [parent_a, parent_b, cuff]
	var link_a = _link(&"link_a", parent_a, cuff)
	var link_b = _link(&"link_b", parent_b, cuff)
	var links: Array = [link_a, link_b]
	var align_a: float = Rules.alignment_rotation_deg(cuff, link_a, pieces, cuff.gaps[0])
	cuff.rotation_degrees = align_a + 80.0
	if not Rules.connector_fits(cuff, align_a, link_a, pieces):
		print("  FAIL opening does not accept cuff at alignment")
		return false
	var first: Dictionary = Rules.apply_settled_rotation(cuff, align_a, pieces, links)
	if not first.applied or link_a.state != Connector.State.DETACHED:
		print("  FAIL A did not detach. state=", link_a.state, " applied=", first.applied)
		return false
	if link_b.state != Connector.State.ENGAGED:
		print("  FAIL B changed while A cleared. state=", link_b.state)
		return false
	if not _alive(cuff):
		print("  FAIL C released after only A cleared")
		return false
	var align_b: float = Rules.alignment_rotation_deg(cuff, link_b, pieces, cuff.gaps[0])
	var second: Dictionary = Rules.apply_settled_rotation(cuff, align_b, pieces, links)
	if not second.applied or link_b.state != Connector.State.DETACHED or _alive(cuff):
		print("  FAIL C did not release after B cleared. alive=", _alive(cuff), " B=", link_b.state)
		return false
	var reason = int(cuff.get_meta("release_reason"))
	if reason != Rules.ReleaseReason.PLAYER_CLEAR:
		print("  FAIL C reason ", reason)
		return false
	print("  PASS")
	return true

func _test_chain() -> bool:
	print("\n(b) chain A→B→C")
	var gap := [GapDef.new(0.0, 56.0, 6.0)]
	var anchor := _ring(&"a", Vector2(100, 400), 0.0, [])
	var mid := _ring(&"b", Vector2(280, 400), 40.0, gap)
	var leaf := _ring(&"c", Vector2(460, 400), 40.0, gap)
	var pieces: Array = [anchor, mid, leaf]
	var link_ab = _link(&"ab", anchor, mid)
	var link_bc = _link(&"bc", mid, leaf)
	var links: Array = [link_ab, link_bc]
	if Rules.is_piece_rotatable(anchor, pieces, links) or Rules.is_piece_rotatable(mid, pieces, links):
		print("  FAIL parent rotatable while it still holds a child")
		return false
	if not Rules.is_piece_rotatable(leaf, pieces, links):
		print("  FAIL leaf blocked by an incoming connector")
		return false
	var align_c: float = Rules.alignment_rotation_deg(leaf, link_bc, pieces, leaf.gaps[0])
	var step_c: Dictionary = Rules.apply_settled_rotation(leaf, align_c, pieces, links)
	if _alive(leaf) or int(leaf.get_meta("release_reason")) != Rules.ReleaseReason.PLAYER_CLEAR:
		print("  FAIL leaf did not player-clear")
		return false
	if not Rules.is_piece_rotatable(mid, pieces, links):
		print("  FAIL mid still locked after leaf escaped")
		return false
	if Rules.is_piece_rotatable(anchor, pieces, links):
		print("  FAIL anchor rotatable while mid is still held")
		return false
	var align_b: float = Rules.alignment_rotation_deg(mid, link_ab, pieces, mid.gaps[0])
	var step_b: Dictionary = Rules.apply_settled_rotation(mid, align_b, pieces, links)
	if _alive(mid) or int(mid.get_meta("release_reason")) != Rules.ReleaseReason.PLAYER_CLEAR:
		print("  FAIL mid did not player-clear. applied=", step_b.applied)
		return false
	if _alive(anchor) or int(anchor.get_meta("release_reason")) != Rules.ReleaseReason.ROOT_COMPLETE:
		print("  FAIL anchor did not root-complete. alive=", _alive(anchor))
		return false
	if not bool(step_c.won) and not Rules.is_puzzle_won(pieces, links):
		print("  FAIL chain not won")
		return false
	print("  PASS")
	return true

func _test_fast_swipe() -> bool:
	print("\n(c) settled orientation only")
	var built := _one_hold()
	var child: Node2D = built.child
	var link = built.link
	var pieces: Array = built.pieces
	var links: Array = built.links
	var align: float = Rules.alignment_rotation_deg(child, link, pieces, child.gaps[0])
	child.rotation_degrees = align + 30.0
	var one: Dictionary = Rules.apply_settled_rotation(child, align + 130.0, pieces, links)
	if one.cleared.size() != 0 or link.state != Connector.State.ENGAGED:
		print("  FAIL 100° swipe detached off the opening")
		return false
	child.rotation_degrees = align + 30.0
	child.state = RingPiece.State.IDLE
	for step in range(10):
		var settled: float = align + 30.0 + float(step + 1) * 10.0
		var part: Dictionary = Rules.apply_settled_rotation(child, settled, pieces, links)
		if part.cleared.size() != 0:
			print("  FAIL 10° step detached at ", settled)
			return false
	if absf(wrapf(child.rotation_degrees - (align + 130.0), -180.0, 180.0)) > 0.5:
		print("  FAIL ten steps did not match the 100° settle")
		return false
	if link.state != Connector.State.ENGAGED:
		print("  FAIL link detached without a legal settle")
		return false
	child.rotation_degrees = align - 40.0
	var across: Dictionary = Rules.apply_settled_rotation(child, align + 40.0, pieces, links)
	if across.cleared.size() != 0 or link.state != Connector.State.ENGAGED:
		print("  FAIL swipe that crossed the gap detached at an illegal end")
		return false
	var hit: Dictionary = Rules.apply_settled_rotation(child, align, pieces, links)
	if hit.cleared.size() == 0 or link.state != Connector.State.DETACHED:
		print("  FAIL legal settle did not clear")
		return false
	print("  PASS")
	return true

func _test_snap() -> bool:
	print("\n(d) snap does not legalize")
	var built := _one_hold()
	var child: Node2D = built.child
	var link = built.link
	var pieces: Array = built.pieces
	var links: Array = built.links
	var align: float = Rules.alignment_rotation_deg(child, link, pieces, child.gaps[0])
	child.rotation_degrees = align + 40.0
	var illegal := Rules.snap_assist_delta(child, pieces, links)
	if absf(illegal) > 0.001:
		print("  FAIL snap moved an illegal orientation by ", illegal)
		return false
	if Rules.evaluate_clearance_hypothetical(child, child.rotation_degrees + illegal, pieces, links).size() != 0:
		print("  FAIL snap would detach an illegal orientation")
		return false
	child.rotation_degrees = align + 6.0
	var legal := Rules.snap_assist_delta(child, pieces, links)
	if absf(legal) < 0.5 or absf(wrapf(child.rotation_degrees + legal - align, -180.0, 180.0)) > 0.5:
		print("  FAIL legal snap did not center. delta=", legal)
		return false
	if not Rules.connector_fits(child, child.rotation_degrees, link, pieces):
		print("  FAIL pre-snap pose was not already legal")
		return false
	if link.state != Connector.State.ENGAGED:
		print("  FAIL snap detached by itself")
		return false
	print("  PASS opening ", PieceGeometry.opening_length(0, child.radius, 56.0))
	return true

func _one_hold() -> Dictionary:
	var gap := [GapDef.new(0.0, 56.0, 6.0)]
	var child := _ring(&"c", Vector2(400, 400), 0.0, gap)
	var parent := _ring(&"a", Vector2(400, 220), 0.0, [])
	var pieces: Array = [parent, child]
	var link = _link(&"hold", parent, child)
	return { "child": child, "link": link, "pieces": pieces, "links": [link] }
