extends SceneTree

const Board = preload("res://data/campaign_board.gd")
const Band = preload("res://data/band_26_50.gd")
const BFS = preload("res://tools/bfs_solver.gd")
const LevelDef = preload("res://data/level_definition.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")

func _init() -> void:
	Board._defer_solve = true
	var args := OS.get_cmdline_user_args()
	var lo := 26
	var hi := 50
	if args.size() >= 2:
		lo = int(args[0])
		hi = int(args[1])
	var path := "D:/AI secound Brain/RotateRings/_godot_test_out/band_26_50.txt"
	var log := FileAccess.open(path, FileAccess.WRITE)
	var previous := 12
	var drops := 0
	var tip_bad := 0
	var unsolved := 0
	for level_id in range(lo, hi + 1):
		var target := level_id - 13
		var def = _build(level_id)
		var built: Dictionary = Board._spawn(def)
		var tips := _tips(built)
		var solved: Dictionary = BFS.solve_bfs(built.pieces, built.links)
		var moves := int(solved.get("moves", 0)) if bool(solved.get("solved", false)) else -1
		var mark := ""
		if moves < 0:
			unsolved += 1
			mark += " UNSOLVED"
		elif moves < target:
			mark += " SHORT target=%d" % target
		elif moves > target:
			mark += " LONG target=%d" % target
		if level_id > lo and moves >= 0 and moves <= previous:
			drops += 1
			mark += " DROP"
		if moves >= 0:
			previous = moves
		if tips != "":
			tip_bad += 1
			mark += " TIPS %s" % tips
		var line := "L%02d moves=%d pieces=%d links=%d%s" % [level_id, moves, def.pieces.size(), def.links.size(), mark]
		print(line)
		if log:
			log.store_line(line)
			log.flush()
		for piece in built.pieces:
			if is_instance_valid(piece):
				piece.free()
	var tail := "DONE drops=%d tip_bad=%d unsolved=%d" % [drops, tip_bad, unsolved]
	print(tail)
	if log:
		log.store_line(tail)
		log.close()
	quit(0)


func _build(level_id: int):
	var root: Dictionary = Band.root_for(level_id)
	Board._paint(root, level_id % 8, -1)
	var flat: Array = []
	var edges: Array = []
	Board._walk(root, Vector2.ZERO, flat, edges)
	Board._fit(flat)
	var def = LevelDef.new()
	def.level_id = level_id
	def.chapter_id = 1 + int((level_id - 1) / 10)
	def.title = "Band %d" % level_id
	def.instruction = "Clear the loose tip first. A clasped ring needs a second turn."
	def.pieces = Board._pieces_from(flat)
	def.links = Board._links_from(flat, edges)
	Board._set_rest_angles(def)
	return def


func _tips(built: Dictionary) -> String:
	var problems: Array[String] = []
	for piece in built.pieces:
		if piece.gaps.is_empty():
			continue
		var contacts: Array = _contacts(piece, built.links, built.pieces)
		for contact in contacts:
			for gap in piece.gaps:
				var mouth := fposmod(piece.rotation_degrees + float(gap.center_angle_deg), 360.0)
				var off := absf(wrapf(mouth - float(contact), -180.0, 180.0))
				var need := float(gap.width_deg) * 0.5 + 35.0
				if off + 0.01 < need:
					problems.append("%s off=%.0f need=%.0f" % [piece.piece_id, off, need])
	return ", ".join(problems)


func _contacts(piece, links: Array, pieces: Array) -> Array:
	var contacts: Array = []
	for link in links:
		if link.def.to_piece_id == piece.piece_id:
			contacts.append(Rules.cuff_world_angle_deg(piece, link, pieces))
		elif link.def.from_piece_id == piece.piece_id:
			var child = Rules.get_piece_by_id(link.def.to_piece_id, pieces)
			if child == null:
				continue
			contacts.append(rad_to_deg((child.position - piece.position).angle()))
	return contacts
