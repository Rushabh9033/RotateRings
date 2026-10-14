extends SceneTree

const Rules = preload("res://gameplay/puzzle_rules.gd")
const UserLevels = preload("res://data/user_levels.gd")
const ConnectorRuntimeScript = preload("res://gameplay/connector_runtime.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")

func _init() -> void:
	print("=== LEVEL 21 SIMULATION START ===")
	var def = UserLevels.build(21)
	if def == null:
		print("FAIL: could not load level 21 definition")
		quit(1)
		return

	var pieces: Array = []
	for p_def in def.pieces:
		var p = RingPiece2DScript.new()
		p.setup(p_def)
		pieces.append(p)

	var links: Array = []
	for l_def in def.links:
		var l = ConnectorRuntimeScript.new(l_def)
		links.append(l)

	# Slide out all sliding pipes
	for p in pieces:
		if p.def.motion_model == 1:
			var axis: Vector2 = p.def.motion_axis.normalized()
			p.position += axis * float(p.def.slide_max)
			p.state = RingPiece2DScript.State.RELEASED
			Rules.on_piece_released(p, links)
			print("Slid and released %s!" % [p.piece_id])

	var all_released := true
	for p in pieces:
		if p.state != RingPiece2DScript.State.RELEASED:
			print("Piece NOT released: %s" % [p.piece_id])
			all_released = false

	print("IS LEVEL 21 WON: %s" % [all_released])
	if all_released:
		print("=== LEVEL 21 SIMULATION SUCCESSFUL ===")
		quit(0)
	else:
		print("=== LEVEL 21 SIMULATION FAILED ===")
		quit(1)
