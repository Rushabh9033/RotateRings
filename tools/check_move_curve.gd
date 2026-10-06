extends SceneTree

const Board = preload("res://data/campaign_board.gd")

func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var lo := 1
	var hi := 10
	if args.size() >= 2:
		lo = int(args[0])
		hi = int(args[1])
	var path := "D:/AI secound Brain/RotateRings/_godot_test_out/moves_%02d_%02d.log" % [lo, hi]
	var log := FileAccess.open(path, FileAccess.WRITE)
	var previous := 0
	if lo > 1:
		previous = int(Board.build(lo - 1).par_moves)
	var drops := 0
	for level_id in range(lo, hi + 1):
		var def = Board.build(level_id)
		var moves := int(def.par_moves)
		var mark := ""
		if level_id > 1 and moves <= previous:
			drops += 1
			mark = " DROP"
		previous = moves
		var line := "L%02d moves=%d pieces=%d%s" % [level_id, moves, def.pieces.size(), mark]
		print(line)
		if log:
			log.store_line(line)
			log.flush()
	var tail := "DONE drops=%d" % drops
	print(tail)
	if log:
		log.store_line(tail)
		log.close()
	quit(0 if drops == 0 else 1)
