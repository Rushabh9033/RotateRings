extends SceneTree

const Board = preload("res://data/campaign_board.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")
const Geometry = preload("res://gameplay/piece_geometry.gd")

func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var lo := 6
	var hi := 15
	if args.size() >= 2:
		lo = int(args[0])
		hi = int(args[1])
	var path := "D:/AI secound Brain/RotateRings/_godot_test_out/unique_%02d_%02d.log" % [lo, hi]
	var log := FileAccess.open(path, FileAccess.WRITE)
	var failures := 0
	var previous := 0
	if lo > 1:
		var prior = Board.build(lo - 1)
		previous = int(prior.par_moves)
	for level_id in range(lo, hi + 1):
		var def = Board.build(level_id)
		var note := _audit(def, previous)
		previous = int(def.par_moves)
		var line := "OK L%02d %-16s pieces=%d moves=%d" % [level_id, def.title, def.pieces.size(), def.par_moves]
		if note != "":
			failures += 1
			line = "FAIL L%02d pieces=%d moves=%d %s" % [level_id, def.pieces.size(), def.par_moves, note]
		print(line)
		if log:
			log.store_line(line)
			log.flush()
	var tail := "DONE failures=%d" % failures
	print(tail)
	if log:
		log.store_line(tail)
		log.close()
	quit(1 if failures > 0 else 0)

func _audit(def, previous: int) -> String:
	var level_id := int(def.level_id)
	var problems: Array[String] = []
	if def.canonical_steps.is_empty():
		problems.append("no solution")
	var built: Dictionary = Board._spawn(def)
	if Rules.resolve_releases(built.pieces, built.links).size() > 0:
		problems.append("open at rest")
	for piece in def.pieces:
		if piece.gaps.is_empty():
			continue
		if float(piece.radius) + 0.1 < 56.0:
			problems.append("small %s %.0f" % [piece.id, piece.radius])
	var closed := 0
	for piece in def.pieces:
		if piece.gaps.is_empty():
			closed += 1
			if piece.id != &"ring_0":
				problems.append("closed child %s" % piece.id)
	if closed > 1:
		problems.append("extra closed")
	var linked := {}
	for link in def.links:
		linked["%s>%s" % [link.from_piece_id, link.to_piece_id]] = true
	for i in def.pieces.size():
		for j in range(i + 1, def.pieces.size()):
			var a = def.pieces[i]
			var b = def.pieces[j]
			var gap: float = a.position.distance_to(b.position) - _reach(a) - _reach(b)
			var joined := linked.has("%s>%s" % [a.id, b.id]) or linked.has("%s>%s" % [b.id, a.id])
			if joined and gap < 28.0:
				problems.append("air %s %s %.1f" % [a.id, b.id, gap])
			elif not joined and gap < 8.0:
				problems.append("overlap %s %s %.1f" % [a.id, b.id, gap])
	for link in built.links:
		var parent = Rules.get_piece_by_id(link.def.from_piece_id, built.pieces)
		var child = Rules.get_piece_by_id(link.def.to_piece_id, built.pieces)
		if parent == null or child == null:
			continue
		for other in built.pieces:
			if other == parent or other == child:
				continue
			var along := _segment_distance(parent.position, child.position, other.position)
			if along < _reach(other) + 4.0:
				problems.append("stem through %s" % other.piece_id)
		if child.gaps.is_empty():
			continue
		var contact := Rules.cuff_world_angle_deg(child, link, built.pieces)
		for gap in child.gaps:
			var mouth := fposmod(child.rotation_degrees + float(gap.center_angle_deg), 360.0)
			var off := absf(wrapf(mouth - contact, -180.0, 180.0))
			if off < float(gap.width_deg) * 0.5 + 16.0:
				problems.append("gap on cuff %s %.0f" % [child.piece_id, off])
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
		problems.append("floor %d < %d" % [int(def.par_moves), floor_moves])
	if level_id > 1 and level_id != 6 and int(def.par_moves) < previous:
		problems.append("easier %d < %d" % [int(def.par_moves), previous])
	for piece in built.pieces:
		if is_instance_valid(piece):
			piece.free()
	if problems.is_empty():
		return ""
	return ", ".join(problems)

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
