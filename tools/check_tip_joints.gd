extends SceneTree

const Board = preload("res://data/campaign_board.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")

func _init() -> void:
	Board._defer_solve = true
	var args := OS.get_cmdline_user_args()
	var lo := 1
	var hi := 50
	if args.size() >= 2:
		lo = int(args[0])
		hi = int(args[1])
	var path := "D:/AI secound Brain/RotateRings/_godot_test_out/tips_%02d_%02d.log" % [lo, hi]
	var log := FileAccess.open(path, FileAccess.WRITE)
	var bad_levels := 0
	for level_id in range(lo, hi + 1):
		var def = Board.build(level_id)
		var note := _tips(def)
		var line := "OK L%02d" % level_id
		if note != "":
			bad_levels += 1
			line = "FAIL L%02d %s" % [level_id, note]
		print(line)
		if log:
			log.store_line(line)
			log.flush()
	var tail := "DONE bad_levels=%d" % bad_levels
	print(tail)
	if log:
		log.store_line(tail)
		log.close()
	quit(0 if bad_levels == 0 else 1)


func _tips(def) -> String:
	var built: Dictionary = Board._spawn(def)
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
	for piece in built.pieces:
		if is_instance_valid(piece):
			piece.free()
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
