extends SceneTree

const Rules = preload("res://gameplay/puzzle_rules.gd")
const PieceGeometry = preload("res://gameplay/piece_geometry.gd")
const RingPiece = preload("res://gameplay/ring_piece_2d.gd")
const PieceDef = preload("res://data/piece_definition.gd")
const GapDef = preload("res://data/gap_definition.gd")
const LinkDef = preload("res://data/link_definition.gd")
const Connector = preload("res://gameplay/connector_runtime.gd")
const Harness = preload("res://tools/level_engine_harness.gd")
const LevelDatabase = preload("res://data/level_database.gd")
const BFSSolver = preload("res://tools/bfs_solver.gd")

func _init() -> void:
	print("\n=== CONSTRAINT LAWS ===")
	var ok := true
	ok = _test_multi_parent() and ok
	ok = _test_chain() and ok
	ok = _test_fast_swipe() and ok
	ok = _test_snap() and ok
	ok = _test_all_levels_invalid_pose() and ok
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
	# 8° still overlaps the end cap. The old geometric gap accepted it; the real opening must not.
	child.rotation_degrees = align + 8.0
	var cap_overlap := Rules.snap_assist_delta(child, pieces, links)
	if absf(cap_overlap) > 0.001 or Rules.connector_fits(child, child.rotation_degrees, link, pieces):
		print("  FAIL cap-overlap pose was treated as legal. delta=", cap_overlap)
		return false
	child.rotation_degrees = align + 2.0
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

func _test_all_levels_invalid_pose() -> bool:
	print("\n(e) every level: a cuff on the cap does not clear")
	var total := LevelDatabase.get_total_levels()
	for level_id in range(1, total + 1):
		if not _test_level_invalid_pose(level_id):
			return false
	print("  PASS")
	return true

func _test_level_invalid_pose(level_id: int) -> bool:
	var probe := Harness.build_level(level_id)
	var children: Array = []
	for piece in probe.pieces:
		if _is_movable_child(piece, probe.pieces, probe.links):
			children.append(piece.piece_id)
	if children.is_empty():
		print("  level ", level_id, ": no movable child, skipped")
		_free_built(probe)
		return true
	var any_legal := false
	for piece_id in children:
		var piece = Rules.get_piece_by_id(piece_id, probe.pieces)
		var holders := _incoming_holders(piece, probe.links)
		var centers := _fit_centers(piece, holders, probe.pieces)
		var illegals := _illegal_angles(piece, holders, probe.pieces, probe.links, centers)
		if illegals.is_empty():
			print("  FAIL level ", level_id, " ", piece_id, " produced no incorrect angles")
			_free_built(probe)
			return false
		for rot in illegals:
			var trial := _settle_fresh(level_id, piece_id, float(rot))
			if not _pose_stayed_locked(trial):
				print("  FAIL level ", level_id, " ", piece_id, " cleared on an incorrect angle ", rot)
				_free_built(trial)
				_free_built(probe)
				return false
			_free_built(trial)
		if not centers.is_empty():
			any_legal = true
			if not _confirm_legal_step(level_id, piece_id, piece, holders, probe, centers):
				_free_built(probe)
				return false
		else:
			print("  level ", level_id, " ", piece_id, ": no opening accepts the cuff")
	if not any_legal:
		print("  FAIL level ", level_id, " has movable children but no legal opening")
		_free_built(probe)
		return false
	print("  level ", level_id, ": ", children.size(), " movable child ring(s)")
	_free_built(probe)
	return true

func _is_movable_child(piece, pieces: Array, links: Array) -> bool:
	if piece == null or piece.gaps == null or piece.gaps.is_empty():
		return false
	if not Rules.is_piece_rotatable(piece, pieces, links):
		return false
	return not _incoming_holders(piece, links).is_empty()

func _incoming_holders(piece, links: Array) -> Array:
	var holders: Array = []
	for link in links:
		if link.def.to_piece_id == piece.piece_id and link.state == Connector.State.ENGAGED:
			holders.append(link)
	return holders

## Degrees of ring rotation, around a centered opening, that still keep the whole cuff off the end caps.
func _fit_window_deg(piece, gap) -> float:
	var shape := Rules.piece_shape(piece)
	var contour := PieceGeometry.contour_length(shape, piece.radius)
	if contour <= 0.001:
		return -1.0
	var thick := Rules.piece_thickness(piece)
	var opening := PieceGeometry.usable_opening_length(shape, piece.radius, float(gap.width_deg), thick)
	if not PieceGeometry.opening_accepts_cuff(opening, Connector.TANGENTIAL_WIDTH, Connector.SAFETY_MARGIN):
		return -1.0
	var cap_s := (thick * 0.5) / contour
	var usable_half := maxf(float(gap.width_deg) / 360.0 * 0.5 - cap_s, 0.0)
	var cuff_half := (Connector.TANGENTIAL_WIDTH * 0.5 + Connector.SAFETY_MARGIN) / contour
	var window_s := usable_half - cuff_half
	if window_s <= 0.0:
		return -1.0
	return window_s * 360.0

func _fit_centers(piece, holders: Array, pieces: Array) -> Array:
	var centers: Array = []
	for link in holders:
		for gap in piece.gaps:
			var window := _fit_window_deg(piece, gap)
			if window < 0.0:
				continue
			centers.append({
				"angle": Rules.alignment_rotation_deg(piece, link, pieces, gap),
				"window": window,
				"link": link,
			})
	return centers

func _outside_fit(rotation: float, centers: Array) -> bool:
	for c in centers:
		if absf(wrapf(rotation - float(c.angle), -180.0, 180.0)) <= float(c.window) + 0.35:
			return false
	return true

func _push_angle(angles: Array, seen: Dictionary, rotation: float) -> void:
	var key := snappedf(fposmod(rotation, 360.0), 0.05)
	if seen.has(key):
		return
	seen[key] = true
	angles.append(fposmod(rotation, 360.0))

func _illegal_angles(piece, holders: Array, pieces: Array, links: Array, centers: Array) -> Array:
	var angles: Array = []
	var seen := {}
	if _outside_fit(piece.rotation_degrees, centers):
		_push_angle(angles, seen, piece.rotation_degrees)
	for c in centers:
		var align := float(c.angle)
		var window := float(c.window)
		# 8–12° sits on the end cap for the authored rings. Larger rings keep that same cap law, so an 8° pose still inside the real opening is not an incorrect angle.
		for off in [8.0, 10.0, 12.0, -8.0, -10.0, -12.0]:
			if absf(off) > window + 1.0:
				_push_angle(angles, seen, align + off)
		var cap_off := 10.0 if window < 8.0 else window + 4.0
		_push_angle(angles, seen, align + cap_off)
		_push_angle(angles, seen, align - cap_off)
		for off in [90.0, -90.0, 180.0]:
			if _outside_fit(align + off, centers):
				_push_angle(angles, seen, align + off)
	if centers.is_empty():
		for link in holders:
			for gap in piece.gaps:
				var align := Rules.alignment_rotation_deg(piece, link, pieces, gap)
				for off in [0.0, 8.0, 10.0, 12.0, -10.0, 90.0]:
					_push_angle(angles, seen, align + off)
	if holders.size() >= 2:
		for gap in piece.gaps:
			for a in range(holders.size()):
				var align_a := Rules.alignment_rotation_deg(piece, holders[a], pieces, gap)
				for b in range(holders.size()):
					if a == b:
						continue
					var align_b := Rules.alignment_rotation_deg(piece, holders[b], pieces, gap)
					# Gap center pointed at the other holder. If that is not a real opening, it must not clear.
					if _outside_fit(align_b, centers):
						_push_angle(angles, seen, align_b)
					var delta := wrapf(align_b - align_a, -180.0, 180.0)
					if absf(delta) < 1.0:
						continue
					var window := _fit_window_deg(piece, gap)
					var step := 10.0 if window < 8.0 else window + 4.0
					var toward := align_a + signf(delta) * step
					if _outside_fit(toward, centers):
						_push_angle(angles, seen, toward)
			var align_0 := Rules.alignment_rotation_deg(piece, holders[0], pieces, gap)
			var align_1 := Rules.alignment_rotation_deg(piece, holders[1], pieces, gap)
			var mid := align_0 + wrapf(align_1 - align_0, -180.0, 180.0) * 0.5
			if _outside_fit(mid, centers):
				_push_angle(angles, seen, mid)
	else:
		for link in links:
			if link.def.to_piece_id == piece.piece_id or link.state != Connector.State.ENGAGED:
				continue
			for gap in piece.gaps:
				var aimed := Rules.alignment_rotation_deg(piece, link, pieces, gap)
				if _outside_fit(aimed, centers):
					_push_angle(angles, seen, aimed)
	return angles

func _confirm_legal_step(level_id: int, piece_id: StringName, piece, holders: Array, probe: Dictionary, centers: Array) -> bool:
	for c in centers:
		if not Rules.connector_fits(piece, float(c.angle), c.link, probe.pieces):
			print("  FAIL level ", level_id, " ", piece_id, " true alignment does not fit at ", c.angle)
			return false
	var moves: Array = BFSSolver._get_moves(probe.pieces, probe.links)
	var mine: Array = []
	for m in moves:
		if m.piece_id == piece_id:
			mine.append(m)
	if mine.is_empty():
		print("  FAIL level ", level_id, " ", piece_id, " solver has no legal step")
		return false
	for m in mine:
		var target := float(m.target_rot)
		var fits_one := false
		for link in holders:
			if Rules.connector_fits(piece, target, link, probe.pieces):
				fits_one = true
		if not fits_one:
			print("  FAIL level ", level_id, " ", piece_id, " solver step does not fit at ", target)
			return false
		var settled := _settle_fresh(level_id, piece_id, target)
		if not _cleared_only_fitting(settled, target):
			print("  FAIL level ", level_id, " ", piece_id, " legal step cleared the wrong connector at ", target)
			_free_built(settled)
			return false
		_free_built(settled)
	return true

func _cleared_only_fitting(built: Dictionary, rotation_deg: float) -> bool:
	if not bool(built.result.applied):
		return false
	var piece: Node2D = built.piece
	var leftover := 0
	for link in built.links:
		if link.def.to_piece_id != piece.piece_id:
			continue
		if link.state == Connector.State.CLEARING:
			return false
		var fits: bool = Rules.connector_fits(piece, rotation_deg, link, built.pieces)
		if fits:
			if link.state != Connector.State.DETACHED:
				return false
		else:
			leftover += 1
			if link.state != Connector.State.ENGAGED:
				return false
	for link in built.links:
		if link.def.from_piece_id != piece.piece_id or link.state == Connector.State.DETACHED:
			continue
		var child = Rules.get_piece_by_id(link.def.to_piece_id, built.pieces)
		if _alive(child):
			leftover += 1
	if leftover == 0:
		return not _alive(piece)
	return _alive(piece)

func _settle_fresh(level_id: int, piece_id: StringName, rotation_deg: float) -> Dictionary:
	var built := Harness.build_level(level_id)
	var piece = Rules.get_piece_by_id(piece_id, built.pieces)
	var result: Dictionary = Rules.apply_settled_rotation(piece, rotation_deg, built.pieces, built.links)
	built["piece"] = piece
	built["result"] = result
	return built

func _pose_stayed_locked(built: Dictionary) -> bool:
	# A sweep that stops short never applies, so the illegal pose cannot clear.
	if not bool(built.result.applied):
		return true
	if built.result.cleared.size() != 0 or built.result.released.size() != 0:
		return false
	for piece in built.pieces:
		if not _alive(piece):
			return false
	for link in built.links:
		if link.state == Connector.State.DETACHED or link.state == Connector.State.CLEARING:
			return false
	return true

func _free_built(built: Dictionary) -> void:
	for piece in built.pieces:
		if is_instance_valid(piece):
			piece.free()
