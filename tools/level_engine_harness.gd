extends RefCounted

const LevelDatabaseScript = preload("res://data/level_database.gd")
const BFSSolver = preload("res://tools/bfs_solver.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")
const ConnectorRuntime = preload("res://gameplay/connector_runtime.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")

static func solve_level(level_id: int) -> Dictionary:
	var built := build_level(level_id)
	return BFSSolver.solve_bfs(built.pieces, built.links)

static func build_level(level_id: int) -> Dictionary:
	var def = LevelDatabaseScript.get_level(level_id)
	var pieces: Array = []
	var piece_map := {}
	for p_def in def.pieces:
		var node = RingPiece2DScript.new()
		node.setup(p_def)
		node.position = p_def.position
		pieces.append(node)
		piece_map[p_def.id] = node
	var links: Array = []
	for link_def in def.links:
		var runtime = ConnectorRuntime.new(link_def.duplicate())
		var from_p = piece_map[runtime.def.from_piece_id]
		var to_p = piece_map[runtime.def.to_piece_id]
		Rules.bind_connector(runtime.def, from_p.position, from_p.rotation_degrees, to_p.position)
		runtime.current_stem_dist = runtime.def.stem_dist
		links.append(runtime)
	return { "pieces": pieces, "links": links }
