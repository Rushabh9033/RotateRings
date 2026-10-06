extends RefCounted
class_name LateCampaign

const LevelDefinitionScript = preload("res://data/level_definition.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")
const LinkDefinitionScript = preload("res://data/link_definition.gd")
const SolutionStepScript = preload("res://data/solution_step.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")
const ConnectorRuntime = preload("res://gameplay/connector_runtime.gd")

const _COLORS: Array[Color] = [
	Color("#32ADDA"),
	Color("#EA7829"),
	Color("#8228D9"),
	Color("#C8202F"),
	Color("#62C73E"),
	Color("#4361CF"),
	Color("#F38224"),
	Color("#29B6F6"),
]

static func build(level_id: int):
	var def = LevelDefinitionScript.new()
	def.level_id = level_id
	def.chapter_id = 1 + int((level_id - 1) / 10)
	if level_id >= 47:
		_build_dual_lock(def, level_id)
	else:
		_build_chain(def, level_id)
	return def

static func _build_chain(def, level_id: int) -> void:
	var count := 3
	if level_id >= 19:
		count = 4
	if level_id >= 27:
		count = 5
	if level_id >= 35:
		count = 6
	if level_id >= 43:
		count = 7
	var shapes: Array[int] = []
	shapes.resize(count)
	shapes.fill(0)
	if level_id >= 25:
		shapes[0] = PieceDefinitionScript.ShapeType.ROUNDED_SQUARE
	if level_id >= 33:
		shapes[count - 1] = PieceDefinitionScript.ShapeType.ROUNDED_TRIANGLE
	if level_id >= 41:
		shapes[count - 1] = PieceDefinitionScript.ShapeType.OVAL
	def.instruction = "Clear the open ring at the end, then work back to the closed anchor."
	var positions := _snake(count, 210.0)
	var pieces: Array = []
	for i in count:
		var gaps: Array = []
		if i > 0:
			gaps.append(GapDefinitionScript.new(0.0, 56.0, 6.0))
		var piece = PieceDefinitionScript.new(
			StringName("ring_%d" % i),
			positions[i],
			76.0,
			24.0,
			_COLORS[i % _COLORS.size()],
			0.0,
			gaps,
			0.0,
			shapes[i]
		)
		pieces.append(piece)
	var links: Array = []
	for i in count - 1:
		links.append(LinkDefinitionScript.new(
			StringName("link_%d" % i),
			StringName("ring_%d" % i),
			StringName("ring_%d" % (i + 1)),
			pieces[i].color
		))
	var order: Array = []
	for i in range(count - 1, 0, -1):
		order.append({ "id": StringName("ring_%d" % i), "link": StringName("link_%d" % (i - 1)), "gap": 0 })
	_stamp_solution(def, pieces, links, order)
	def.title = _chain_title(level_id, pieces)

static func _build_dual_lock(def, level_id: int) -> void:
	var extras := level_id - 47
	def.title = "Two Locks"
	def.instruction = "Free the outer rings, then turn the center onto each anchor."
	def.par_moves = extras + 3
	var pieces: Array = []
	var center_pos := Vector2(360, 640)
	var anchor_shape_l := 0
	var anchor_shape_r := 0
	if level_id >= 49:
		anchor_shape_l = PieceDefinitionScript.ShapeType.ROUNDED_SQUARE
		anchor_shape_r = PieceDefinitionScript.ShapeType.ROUNDED_TRIANGLE
	pieces.append(PieceDefinitionScript.new(&"ring_0", center_pos + Vector2(-210, 0), 76.0, 24.0, _COLORS[0], 0.0, [], 0.0, anchor_shape_l))
	pieces.append(PieceDefinitionScript.new(&"ring_1", center_pos + Vector2(210, 0), 76.0, 24.0, _COLORS[1], 0.0, [], 0.0, anchor_shape_r))
	pieces.append(PieceDefinitionScript.new(
		&"ring_2",
		center_pos,
		76.0,
		24.0,
		_COLORS[2],
		0.0,
		[GapDefinitionScript.new(0.0, 56.0, 6.0)],
		0.0,
		0
	))
	var links: Array = [
		LinkDefinitionScript.new(&"link_left", &"ring_0", &"ring_2", pieces[0].color),
		LinkDefinitionScript.new(&"link_right", &"ring_1", &"ring_2", pieces[1].color),
	]
	var order: Array = []
	var previous := StringName("ring_2")
	var leaf_spots: Array[Vector2] = [
		center_pos + Vector2(0, -210),
		center_pos + Vector2(-210, -210),
		center_pos + Vector2(-210, -420),
		center_pos + Vector2(0, -420),
	]
	for i in range(extras + 1):
		var leaf_id := StringName("ring_%d" % (3 + i))
		var link_id := StringName("link_leaf_%d" % i)
		pieces.append(PieceDefinitionScript.new(
			leaf_id,
			leaf_spots[i],
			76.0,
			24.0,
			_COLORS[(3 + i) % _COLORS.size()],
			0.0,
			[GapDefinitionScript.new(0.0, 56.0, 6.0)],
			0.0,
			0
		))
		links.append(LinkDefinitionScript.new(link_id, previous, leaf_id, _COLORS[2]))
		order.append({ "id": leaf_id, "link": link_id, "gap": 0 })
		previous = leaf_id
	order.reverse()
	order.append({ "id": &"ring_2", "link": &"link_left", "gap": 0 })
	order.append({ "id": &"ring_2", "link": &"link_right", "gap": 0 })
	_stamp_solution(def, pieces, links, order)

static func _stamp_solution(def, pieces: Array, links: Array, order: Array) -> void:
	var steps: Array = []
	for action in order:
		var authored = _piece_def(pieces, action.id)
		var target := _fit_target(pieces, links, action)
		if authored.gaps.size() > 0 and not _clears_at(pieces, links, steps, action, target):
			authored.shape_type = PieceDefinitionScript.ShapeType.CIRCLE
			authored.gaps[int(action.gap)].width_deg = 72.0
			target = _fit_target(pieces, links, action)
		var placed := false
		for offset in [72.0, 48.0, 100.0, 120.0]:
			authored.start_angle_deg = fposmod(target + offset, 360.0)
			if _clears_at(pieces, links, steps, action, target):
				placed = true
				break
		if not placed:
			authored.start_angle_deg = fposmod(target + 72.0, 360.0)
		steps.append(SolutionStepScript.new(action.id, target, true))
	def.pieces = pieces
	def.links = links
	def.canonical_steps = steps
	def.par_moves = steps.size()

static func _fit_target(pieces: Array, links: Array, action: Dictionary) -> float:
	var built := _mount(pieces, links)
	var piece = built.map[action.id]
	var link = built.link_map[action.link]
	var gap = piece.gaps[int(action.gap)]
	var target: float = Rules.alignment_rotation_deg(piece, link, built.pieces, gap)
	_free_mount(built)
	return target

static func _clears_at(pieces: Array, links: Array, prior: Array, action: Dictionary, target: float) -> bool:
	var built := _mount(pieces, links)
	for step in prior:
		var earlier = built.map[step.piece_id]
		var applied: Dictionary = Rules.apply_settled_rotation(earlier, step.target_angle_deg, built.pieces, built.links)
		if not bool(applied.applied):
			_free_mount(built)
			return false
	var piece = built.map[action.id]
	var applied_now: Dictionary = Rules.apply_settled_rotation(piece, target, built.pieces, built.links)
	var link = built.link_map[action.link]
	var cleared: bool = bool(applied_now.applied) and link.state == ConnectorRuntime.State.DETACHED
	_free_mount(built)
	return cleared

static func _mount(pieces: Array, links: Array) -> Dictionary:
	var nodes: Array = []
	var piece_map := {}
	for p_def in pieces:
		var node = RingPiece2DScript.new()
		node.setup(p_def)
		node.position = p_def.position
		nodes.append(node)
		piece_map[p_def.id] = node
	var runtimes: Array = []
	var link_map := {}
	for link_def in links:
		var runtime = ConnectorRuntime.new(link_def.duplicate())
		var from_p = piece_map[runtime.def.from_piece_id]
		var to_p = piece_map[runtime.def.to_piece_id]
		Rules.bind_connector(runtime.def, from_p.position, from_p.rotation_degrees, to_p.position)
		runtime.current_stem_dist = runtime.def.stem_dist
		runtimes.append(runtime)
		link_map[link_def.id] = runtime
	return { "pieces": nodes, "links": runtimes, "map": piece_map, "link_map": link_map }

static func _free_mount(built: Dictionary) -> void:
	for node in built.pieces:
		node.free()

static func _piece_def(pieces: Array, id: StringName):
	for piece in pieces:
		if piece.id == id:
			return piece
	return null

static func _snake(count: int, gap: float) -> Array[Vector2]:
	var cols := 3
	var points: Array[Vector2] = []
	for i in count:
		var row := int(i / cols)
		var col := i % cols
		if row % 2 == 1:
			col = cols - 1 - col
		var x := 360.0 + (float(col) - 1.0) * gap
		var y := 360.0 + float(row) * 210.0
		points.append(Vector2(x, y))
	return points

static func _chain_title(level_id: int, pieces: Array) -> String:
	var shapes: Array[int] = []
	for piece in pieces:
		shapes.append(int(piece.shape_type))
	if shapes.has(PieceDefinitionScript.ShapeType.OVAL):
		return "Oval Link"
	if shapes.has(PieceDefinitionScript.ShapeType.ROUNDED_TRIANGLE):
		return "Triangle Link"
	if shapes.has(PieceDefinitionScript.ShapeType.ROUNDED_SQUARE):
		return "Square Link"
	if level_id >= 43:
		return "Long Chain"
	return "Open Chain"
