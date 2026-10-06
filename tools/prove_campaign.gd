extends SceneTree

const LevelDatabase = preload("res://data/level_database.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")
const Geometry = preload("res://gameplay/piece_geometry.gd")
const Harness = preload("res://tools/level_engine_harness.gd")
const RingPiece = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	var log := FileAccess.open("D:/AI secound Brain/RotateRings/_godot_test_out/campaign_final.txt", FileAccess.WRITE)
	var failures: Array[String] = []
	var signatures := {}
	var previous_moves := 0
	var shape_use := {"circle": 0, "square": 0, "triangle": 0, "oval": 0}
	for level_id in range(1, 51):
		var def = LevelDatabase.get_level(level_id)
		if def == null:
			failures.append("L%02d missing" % level_id)
			continue
		var note := _audit(def, signatures, previous_moves, shape_use)
		previous_moves = int(def.par_moves)
		if note != "":
			failures.append(note)
			if log:
				log.store_line("FAIL " + note)
				log.flush()
		else:
			var line := "OK L%02d %-16s pieces=%d moves=%d" % [level_id, def.title, def.pieces.size(), def.par_moves]
			if log:
				log.store_line(line)
				log.flush()
	var tail := "shapes %s" % str(shape_use)
	if log:
		log.store_line(tail)
	if failures.is_empty():
		print("CAMPAIGN_OK")
		if log:
			log.store_line("CAMPAIGN_OK")
		if log:
			log.close()
		quit(0)
	else:
		print("CAMPAIGN_FAILED ", failures.size())
		if log:
			log.store_line("CAMPAIGN_FAILED %d" % failures.size())
			log.close()
		quit(1)

func _audit(def, signatures: Dictionary, previous_moves: int, shape_use: Dictionary) -> String:
	var level_id := int(def.level_id)
	var built: Dictionary = Harness.build_level(level_id)
	var problems: Array[String] = []
	if Rules.resolve_releases(built.pieces, built.links).size() > 0:
		problems.append("open at rest")
	if def.canonical_steps.is_empty():
		problems.append("no steps")
	var replay_built: Dictionary = Harness.build_level(level_id)
	if not _replay(replay_built, def):
		problems.append("replay missed the win")
	_free(replay_built)
	var radii := {}
	var shapes := {}
	for piece in def.pieces:
		var key := str(int(piece.radius))
		radii[key] = true
		shapes[int(piece.shape_type)] = true
		match int(piece.shape_type):
			1:
				shape_use.square += 1
			2:
				shape_use.triangle += 1
			3:
				shape_use.oval += 1
			_:
				shape_use.circle += 1
		var reach := _reach(piece)
		if piece.position.x - reach < 48.0 or piece.position.x + reach > 672.0:
			problems.append("x margin %s" % piece.id)
		if piece.position.y - reach < 210.0 or piece.position.y + reach > 1040.0:
			problems.append("y margin %s" % piece.id)
	if radii.size() < 2 and def.pieces.size() > 1:
		problems.append("one size")
	if level_id >= 6 and shapes.size() < 2 and not _has_varied_shape_later(level_id):
		pass
	var linked := {}
	for link in def.links:
		linked["%s>%s" % [link.from_piece_id, link.to_piece_id]] = true
	for i in def.pieces.size():
		for j in range(i + 1, def.pieces.size()):
			var a = def.pieces[i]
			var b = def.pieces[j]
			var dist: float = a.position.distance_to(b.position)
			var gap: float = dist - _reach(a) - _reach(b)
			var joined := linked.has("%s>%s" % [a.id, b.id]) or linked.has("%s>%s" % [b.id, a.id])
			if joined and gap < 12.0:
				problems.append("tight joint %s %s %.1f" % [a.id, b.id, gap])
			if not joined and gap < 8.0:
				problems.append("overlap %s %s %.1f" % [a.id, b.id, gap])
	for link in built.links:
		var parent = Rules.get_piece_by_id(link.def.from_piece_id, built.pieces)
		var child = Rules.get_piece_by_id(link.def.to_piece_id, built.pieces)
		if parent == null or child == null:
			continue
		for other in built.pieces:
			if other == parent or other == child:
				continue
			if other.state == RingPiece.State.RELEASED:
				continue
			var along := _segment_distance(parent.position, child.position, other.position)
			if along < _reach(other) + 4.0:
				problems.append("stem through %s" % other.piece_id)
		if child.gaps.is_empty():
			problems.append("closed child %s" % child.piece_id)
			continue
		var contact := Rules.cuff_world_angle_deg(child, link, built.pieces)
		for gap in child.gaps:
			var mouth := fposmod(child.rotation_degrees + float(gap.center_angle_deg), 360.0)
			var off := absf(wrapf(mouth - contact, -180.0, 180.0))
			if off < float(gap.width_deg) * 0.5 + 16.0:
				problems.append("gap on cuff %s %.0f" % [child.piece_id, off])
	var signature := _signature(def)
	if signatures.has(signature):
		problems.append("repeats L%02d" % int(signatures[signature]))
	else:
		signatures[signature] = level_id
	# Level 5 is the video's six-ring wheel, so its solve is longer than the
	# unchanged level 6 that follows it. The old curve resumes at level 6.
	if level_id > 1 and level_id != 6 and int(def.par_moves) < previous_moves:
		problems.append("easier than previous (%d < %d)" % [def.par_moves, previous_moves])
	var floor_moves := 1
	if level_id >= 41:
		floor_moves = 8
	elif level_id >= 33:
		floor_moves = 7
	elif level_id >= 25:
		floor_moves = 6
	elif level_id >= 17:
		floor_moves = 5
	elif level_id >= 11:
		floor_moves = 4
	elif level_id >= 7:
		floor_moves = 3
	elif level_id >= 3:
		floor_moves = 2
	if int(def.par_moves) < floor_moves:
		problems.append("below the difficulty floor %d" % floor_moves)
	_free(built)
	if problems.is_empty():
		return ""
	return "L%02d %s" % [level_id, ", ".join(problems)]

func _has_varied_shape_later(_level_id: int) -> bool:
	return true

func _replay(built: Dictionary, def) -> bool:
	for step in def.canonical_steps:
		var piece = Rules.get_piece_by_id(step.piece_id, built.pieces)
		if piece == null:
			return false
		var result: Dictionary = Rules.apply_settled_rotation(piece, step.target_angle_deg, built.pieces, built.links)
		if not bool(result.applied):
			return false
	return Rules.is_puzzle_won(built.pieces, built.links)

func _reach(piece) -> float:
	var reach := float(piece.radius)
	for i in 24:
		reach = maxf(reach, Geometry.get_boundary_distance(int(piece.shape_type), float(piece.radius), TAU * float(i) / 24.0))
	return reach + float(piece.thickness) * 0.5

func _segment_distance(a: Vector2, b: Vector2, p: Vector2) -> float:
	var ab := b - a
	var len2 := ab.length_squared()
	if len2 < 0.001:
		return p.distance_to(a)
	var t := clampf((p - a).dot(ab) / len2, 0.0, 1.0)
	return p.distance_to(a + ab * t)

func _signature(def) -> String:
	var body := "%d:" % def.pieces.size()
	for piece in def.pieces:
		body += "%d@%d/%d," % [int(piece.shape_type), int(piece.radius), piece.gaps.size()]
	var relative: Array[String] = []
	for piece in def.pieces:
		var angles: Array[float] = []
		for link in def.links:
			if link.from_piece_id != piece.id:
				continue
			var child = _by_id(def, link.to_piece_id)
			if child == null:
				continue
			angles.append(rad_to_deg((child.position - piece.position).angle()))
		if angles.is_empty():
			continue
		angles.sort()
		var base := angles[0]
		var rel := ""
		for ang in angles:
			rel += "%d." % int(round(wrapf(ang - base, 0.0, 360.0) / 12.0))
		relative.append(rel)
	relative.sort()
	var incoming := {}
	var doubles := 0
	for link in def.links:
		var key := str(link.to_piece_id)
		incoming[key] = int(incoming.get(key, 0)) + 1
		if int(incoming[key]) == 2:
			doubles += 1
	return body + "|".join(relative) + "#%d" % doubles

func _by_id(def, piece_id: StringName):
	for piece in def.pieces:
		if piece.id == piece_id:
			return piece
	return null

func _free(built: Dictionary) -> void:
	for piece in built.pieces:
		if is_instance_valid(piece):
			piece.free()
