extends RefCounted
class_name CampaignBoard

const LevelDefinitionScript = preload("res://data/level_definition.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")
const LinkDefinitionScript = preload("res://data/link_definition.gd")
const SolutionStepScript = preload("res://data/solution_step.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")
const Geometry = preload("res://gameplay/piece_geometry.gd")
const RingPiece2DScript = preload("res://gameplay/ring_piece_2d.gd")
const ConnectorRuntime = preload("res://gameplay/connector_runtime.gd")
const BFSSolverScript = preload("res://tools/bfs_solver.gd")

const C := 0
const S := 1
const T := 2
const O := 3

const _PALETTE: Array[Color] = [
	Color("#32ADDA"),
	Color("#EA7829"),
	Color("#7B61FF"),
	Color("#C8202F"),
	Color("#2CA45C"),
	Color("#4361CF"),
	Color("#F38224"),
	Color("#3EC6B0"),
]

const _BOARD := Vector2(360, 610)
const _HALF := Vector2(292, 370)
const _AIR := 34.0

static var _cache: Dictionary = {}
static var _defer_solve: bool = true

static func build(level_id: int):
	if _cache.has(level_id):
		return _cache[level_id]
	var spec: Dictionary = _spec(level_id)
	var root: Dictionary = spec.root
	_paint(root, level_id % _PALETTE.size(), -1)
	var flat: Array = []
	var edges: Array = []
	_walk(root, Vector2.ZERO, flat, edges)
	_fit(flat)
	var def = LevelDefinitionScript.new()
	def.level_id = level_id
	def.chapter_id = 1 + int((level_id - 1) / 10)
	def.title = spec.title
	def.instruction = spec.instruction
	def.pieces = _pieces_from(flat)
	def.links = _links_from(flat, edges)
	if not _json_data.has(str(level_id)):
		_set_rest_angles(def)
	_stamp_solution(def)
	_cache[level_id] = def
	return def

static func _spec(level_id: int) -> Dictionary:
	var band := _layout(level_id)
	return _lv(band.title, band.instruction, band.root)

static func _layout(level_id: int) -> Dictionary:
	var title := _TITLES[level_id - 1] if level_id - 1 < _TITLES.size() else ("Level %d" % level_id)
	var line := "Clear the loose tips first. A clasped ring needs a second turn."
	if level_id - 1 < _LINES.size():
		line = _LINES[level_id - 1]
	return _lv(title, line, _root_for(level_id))

static func _root_for(level_id: int) -> Dictionary:
	var root := _authored(level_id)
	_grow(root, level_id)
	return root

static func _grow(node: Dictionary, level_id: int) -> void:
	var extra := _grow_count(level_id)
	if extra <= 0:
		return
	var found: Dictionary = _deep_tip(node, -90.0)
	var tip: Dictionary = found.node
	var bend := 48.0 + float(level_id % 4) * 3.0
	var heading := float(found.arrival) + bend
	var radii: Array[float] = [56.0, 60.0, 58.0, 64.0, 62.0]
	for i in extra:
		var leaf := _leaf(radii[(level_id + i) % radii.size()], 120.0 + float((i * 9 + level_id) % 24))
		tip.kids.append([heading, leaf])
		tip = leaf
		heading += bend

static func _deep_tip(node: Dictionary, arrival: float) -> Dictionary:
	var kids: Array = node.kids
	if kids.is_empty():
		return {"node": node, "arrival": arrival}
	var best_i := 0
	var best_n := _chain_depth(kids[0][1])
	for i in range(1, kids.size()):
		var depth := _chain_depth(kids[i][1])
		if depth >= best_n:
			best_i = i
			best_n = depth
	return _deep_tip(kids[best_i][1], float(kids[best_i][0]))

static func _chain_depth(node: Dictionary) -> int:
	var kids: Array = node.kids
	if kids.is_empty():
		return 1
	var best := 0
	for kid in kids:
		best = maxi(best, _chain_depth(kid[1]))
	return best + 1

static func _grow_count(level_id: int) -> int:
	# Extra links after level 5 so each solution is longer than the previous one.
	if level_id < 6 or level_id > 50:
		return 0
	var counts: Array[int] = []
	if level_id - 6 >= counts.size():
		return 0
	return counts[level_id - 6]

static func _video_root(level_id: int) -> Dictionary:
	# Layouts read from the Game Rush walkthrough (levels 2–5). Later levels in
	# that video were too crowded to copy without guessing.
	if level_id == 2:
		# Purple open root at the bottom, orange above-left, blue off the orange.
		var blue := _leaf(56.0, 168.0)
		var orange := _n(60.0, C, 1, 176.0, 0, [[-14.0, blue]])
		return _n(66.0, C, 1, 90.0, 0, [[-102.0, orange]])
	if level_id == 3:
		# Blue open root on top. Orange hangs down-left into red. Purple hangs down-right.
		var red := _leaf(56.0, 168.0)
		red["fixed_color"] = true
		red["color"] = 3
		var orange := _n(60.0, C, 1, 188.0, 1, [[96.0, red]])
		orange["fixed_color"] = true
		orange["color"] = 1
		var purple := _leaf(58.0, 172.0)
		purple["fixed_color"] = true
		purple["color"] = 2
		var root := _n(68.0, C, 1, 270.0, 0, [[128.0, orange], [46.0, purple]])
		root["fixed_color"] = true
		root["color"] = 0
		return root
	if level_id == 4:
		# Red open root on the left, two chains. Each joint has one child so a
		# freed stem can swing clear of the ring behind it.
		var orange := _leaf(56.0, 150.0)
		var upper_blue := _n(56.0, C, 1, 150.0, 0, [[85.0, orange]])
		var purple := _n(60.0, C, 1, 150.0, 0, [[75.0, upper_blue]])
		var lower_blue := _leaf(56.0, 150.0)
		var dark_green := _n(56.0, C, 1, 150.0, 0, [[-85.0, lower_blue]])
		var light_green := _n(60.0, C, 1, 150.0, 0, [[-75.0, dark_green]])
		return _n(68.0, C, 1, 180.0, 0, [[-55.0, purple], [60.0, light_green]])
	if level_id == 5:
		# Closed circle with six open rings. Three neighbor holds, not a loop:
		# a full loop would freeze every ring, because a parent cannot turn.
		var angles: Array[float] = [-90.0, -30.0, 30.0, 90.0, 150.0, 210.0]
		var radii: Array[float] = [56.0, 60.0, 56.0, 58.0, 62.0, 58.0]
		var kids: Array = []
		for i in angles.size():
			kids.append([angles[i], _leaf(radii[i], 150.0 + float(i % 3) * 8.0)])
		var hub := _n(78.0, C, 0, 0.0, 0, kids)
		hub["locks"] = [[0, 1], [2, 3], [4, 5]]
		return hub
	return {}

static func _one(anchor: float, shape: int, angle: float, leaf: float, turn: float) -> Dictionary:
	return _hold(anchor, shape, [[angle, _leaf(leaf, turn)]])

static func _k(angle: float, radius: float, turn: float, children: Array = [], gaps: int = 1) -> Array:
	return [angle, _n(radius, C, gaps, turn, 0, children.duplicate())]

static func _closed(radius: float, shape: int, children: Array, bridge: bool = false) -> Dictionary:
	return _n(radius, shape, 0, 0.0, 0, children, bridge, [])

static func _open_root(radius: float, turn: float, children: Array) -> Dictionary:
	return _n(radius, C, 1, turn, 0, children)

static func _spoke_fan(root_r: float, shape: int, spin: float, shift: int, lock_count: int, tail: int = 0, snug: bool = false, pattern: int = -1) -> Dictionary:
	var base: Array[float] = [-90.0, -30.0, 30.0, 90.0, 150.0, 210.0]
	var radii: Array[float] = [56.0, 64.0, 58.0, 66.0, 60.0, 62.0]
	if pattern >= 0:
		radii = [56.0, 56.0, 56.0, 56.0, 56.0, 56.0]
		radii[pattern % 6] = 58.0
		var other := int(pattern / 6) % 6
		if other != pattern % 6:
			radii[other] = 58.0
		radii[0] = 56.0
	elif snug:
		radii = [56.0, 56.0, 58.0, 56.0, 58.0, 56.0]
	var kids: Array = []
	for i in base.size():
		kids.append([base[i] + spin, _leaf(radii[(i + shift) % radii.size()], 128.0 + float((i * 11 + shift * 5) % 32))])
	if tail > 0:
		var spoke: Dictionary = kids[0][1]
		var heading := base[0] + spin + 18.0
		for t in tail:
			var link := _leaf(radii[(shift + 3 + t) % radii.size()], 134.0 + float(t) * 8.0)
			spoke.kids.append([heading, link])
			spoke = link
			heading += 22.0
	var pairs: Array = [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 0]]
	var locks: Array = []
	for n in mini(lock_count, pairs.size()):
		locks.append(pairs[n])
	var hub := _closed(root_r, shape, kids)
	hub["locks"] = locks
	return hub

static func _capped_fan(level_id: int) -> Dictionary:
	var n := level_id - 10
	var shape := C if n % 2 == 0 else O
	var spin := float((level_id % 5) * 3) - 6.0
	return _spoke_fan(54.0, shape, spin, 0, 5, 2, true, int(n / 2))

const JSONLevelsPath := "res://data/json_levels.json"
static var _json_data: Dictionary = {}

static func _load_json_levels() -> void:
	if not _json_data.is_empty():
		return
	if not FileAccess.file_exists(JSONLevelsPath):
		return
	var file := FileAccess.open(JSONLevelsPath, FileAccess.READ)
	if file == null:
		return
	var text := file.get_as_text()
	var json := JSON.new()
	if json.parse(text) == OK:
		_json_data = json.data

static func _color_index(c_str: String) -> int:
	match c_str.strip_edges().to_lower():
		"cyan", "sky_blue", "sky blue", "blue1", "light_cyan", "light cyan": return 0
		"orange", "coral": return 1
		"purple", "violet": return 2
		"red": return 3
		"green", "light_green", "light green": return 4
		"dark_blue", "blue", "dark blue": return 5
		"yellow": return 6
		_: return 0

static func _shape_enum(s_str: String) -> int:
	match s_str.strip_edges().to_upper():
		"C": return C
		"S": return S
		"T": return T
		"O": return O
		_: return C

static func _build_node_from_json(dict: Dictionary) -> Dictionary:
	var shape_val := _shape_enum(str(dict.get("shape", "C")))
	var gaps_val := int(dict.get("gaps", 1))
	var radius_val := float(dict.get("radius", 56.0))
	var turn_val := float(dict.get("turn", 0.0))
	var color_str := str(dict.get("color", "cyan"))
	var color_idx := _color_index(color_str)
	
	var kids: Array = []
	for kid_dict in dict.get("children", []):
		var angle_val := float(kid_dict.get("angle", 0.0))
		var child_piece_dict: Dictionary = kid_dict.get("piece", {})
		var child_node := _build_node_from_json(child_piece_dict)
		kids.append([angle_val, child_node])
		
	var node := _n(radius_val, shape_val, gaps_val, turn_val, color_idx, kids)
	node["fixed_color"] = true
	node["color"] = color_idx
	if dict.has("locks"):
		node["locks"] = dict.locks
	return node

static func _authored(level_id: int) -> Dictionary:
	_load_json_levels()
	var key := str(level_id)
	if _json_data.has(key):
		var level_dict: Dictionary = _json_data[key]
		if level_dict.has("root"):
			return _build_node_from_json(level_dict["root"])
	match level_id:
		1:
			return _one(88.0, C, 94.0, 60.0, 122.0)
		2:
			# Orange open ring holds a blue ring up-right and a purple ring below.
			return _open_root(62.0, 210.0, [
				_k(18.0, 58.0, 28.0),
				_k(108.0, 60.0, 86.0),
			])
		3:
			# Blue ring on top. Orange chain down the left ends in red. Purple hangs right.
			return _open_root(64.0, 270.0, [
				_k(148.0, 58.0, 200.0, [
					_k(112.0, 56.0, 188.0, [
						_k(96.0, 58.0, 84.0),
					]),
				]),
				_k(36.0, 58.0, 18.0),
			])
		4:
			# Orange tip, then blue, into a purple fork: red left, green pair right, blue below.
			return _open_root(58.0, 48.0, [
				_k(-78.0, 56.0, 206.0, [
					_k(-96.0, 54.0, 248.0),
				]),
				_k(168.0, 54.0, 156.0),
				_k(42.0, 58.0, 118.0, [
					_k(8.0, 60.0, 22.0),
					_k(96.0, 56.0, 78.0),
				]),
			])
		5:
			# Closed purple hub. Six open rings. Three neighbor holds, not a full loop.
			var wheel := _closed(72.0, C, [
				_k(-90.0, 56.0, 142.0),
				_k(-145.0, 54.0, 168.0),
				_k(-28.0, 56.0, 36.0),
				_k(28.0, 58.0, 18.0),
				_k(92.0, 54.0, 96.0),
				_k(158.0, 56.0, 154.0),
			])
			wheel["locks"] = [[0, 1], [3, 4], [2, 5]]
			return wheel
		6:
			# Loose cluster: closed orange ring, two bent bars, no center hub.
			return _open_root(56.0, 200.0, [
				_k(-20.0, 54.0, 48.0, [
					_k(24.0, 56.0, 12.0, [
						_k(70.0, 52.0, 96.0, [
							[118.0, _n(40.0, S, 1, 18.0, 0, [])],
						]),
					]),
				]),
				_k(-130.0, 54.0, 150.0, [
					[-168.0, _n(36.0, S, 1, -28.0, 0, [
						[-150.0, _n(50.0, C, 0, 0.0, 0, [
							_k(-110.0, 48.0, 220.0),
						])],
					])],
				]),
			])
		7:
			# Open blue center. Green bar left, red bar right, four loose tips.
			return _open_root(56.0, 92.0, [
				_k(-88.0, 52.0, 268.0),
				_k(-148.0, 54.0, 198.0),
				[-168.0, _n(58.0, S, 1, 90.0, 0, [
					_k(156.0, 50.0, 36.0),
					_k(108.0, 54.0, 78.0),
				])],
				[24.0, _n(58.0, S, 1, 8.0, 0, [
					_k(36.0, 50.0, 198.0),
					_k(92.0, 54.0, 256.0),
				])],
			])
		8:
			# Two bundles. Top pair of hooks, bottom fork of five.
			return _open_root(54.0, 176.0, [
				_k(-92.0, 52.0, 248.0),
				_k(16.0, 54.0, 38.0, [
					_k(-36.0, 52.0, 296.0),
				]),
				_k(78.0, 56.0, 118.0, [
					_k(154.0, 52.0, 76.0),
					_k(108.0, 50.0, 18.0),
					_k(28.0, 54.0, 198.0, [
						_k(-8.0, 48.0, 292.0),
						_k(42.0, 48.0, 72.0),
					]),
				]),
			])
		9:
			# Left chain off a closed blue ring. Right chain off a second closed ring.
			return _open_root(54.0, 96.0, [
				_k(-48.0, 52.0, 204.0, [
					[-86.0, _n(56.0, C, 0, 0.0, 0, [
						_k(164.0, 48.0, 42.0, [
							_k(122.0, 52.0, 84.0, [
								_k(86.0, 48.0, 22.0),
							]),
						]),
					])],
				]),
				_k(28.0, 54.0, 304.0, [
					[-24.0, _n(58.0, C, 0, 0.0, 0, [])],
					_k(72.0, 52.0, 38.0),
				]),
			])
		10:
			# Closed blue ring. Bent bars outside, three bars crossed inside the ring.
			return _closed(76.0, C, [
				[88.0, _n(30.0, S, 1, 0.0, 0, [])],
				[168.0, _n(34.0, S, 1, 90.0, 0, [])],
				[12.0, _n(34.0, S, 1, 90.0, 0, [])],
				_k(-42.0, 52.0, 36.0, [
					[-18.0, _n(38.0, S, 1, 42.0, 0, [])],
					_k(24.0, 46.0, 8.0),
					[58.0, _n(32.0, S, 1, 4.0, 0, [])],
					[86.0, _n(40.0, S, 1, -16.0, 0, [])],
				]),
				_k(148.0, 52.0, 196.0, [
					[176.0, _n(38.0, S, 1, 158.0, 0, [])],
					_k(204.0, 46.0, 142.0),
					[228.0, _n(40.0, S, 1, 92.0, 0, [])],
					[252.0, _n(36.0, S, 1, 78.0, 0, [])],
				]),
			])
		11:
			# Structure: Top row: red C, light cyan C, purple C with honey
			# Middle row: light cyan full, dark blue full with honey
			# Bottom row: light cyan C with honey, green C, orange full
			return _open_root(66, 132.0, [
				_k(-115, 68, 136.0),  # Red C-ring top-left
				_k(-35, 56, 148.0),   # Light cyan C-ring top-center
				_k(60, 64, 140.0, [   # Purple C-ring top-right (has honey)
					_k(145, 58, 158.0), # Connector to dark blue full
				]),
				_k(180, 72, 136.0, [  # Dark blue full middle (has honey)
					_k(-90, 60, 145.0, [  # Light cyan C-ring bottom-left (has honey)
						_k(-180, 58, 152.0), # Green C-ring bottom-center
					]),
				]),
				_k(100, 64, 142.0, [  # Orange full bottom-right
					_k(180, 62, 138.0),
				]),
			])
		12:
			# Structure: Light cyan C-ring on left with locks
			# Green C-ring middle, light cyan full with honey on right
			# Dark blue C-ring and orange C-ring at bottom
			# Purple bar at top, orange bar middle-left, dark blue bar middle-right
			return _closed(70, C, [
				_k(-110, 60, 132.0, [  # Light cyan C-ring left
					_k(-20, 56, 149.0, [], 1),  # Orange bar
				]),
				_k(70, 64, 132.0, [    # Green C-ring right
					_k(160, 58, 149.0, [   # Light cyan full (has honey)
						_k(250, 62, 136.0),    # Dark blue C-ring
					]),
				]),
			])
		13:
			# Structure: Complex tree with multiple paths
			# Dark blue C-ring root, green curvy connector, red full ring
			# Multiple branches with honey markers in purple and orange rings
			# Light cyan chains with green C-rings at bottom
			return _open_root(70, 90.0, [
				_k(-90, 68, 135.0, [    # Dark blue C-ring top-left
					_k(-10, 62, 148.0, [   # Green curved connector
						_k(80, 56, 142.0),     # Branch continuation
					]),
				]),
				_k(0, 72, 90.0, [       # Red full ring center
					_k(90, 64, 145.0, [    # Light cyan branch
						_k(180, 58, 152.0, [   # Orange C-ring (has honey)
							_k(270, 60, 138.0, [   # Purple C-ring
								_k(0, 66, 155.0),      # Full purple ring (has honey)
							]),
						]),
					]),
				]),
				_k(180, 68, 135.0, [    # Red C-ring bottom
					_k(270, 58, 148.0, [   # Orange C-ring (has honey)
						_k(0, 62, 142.0, [     # Purple full ring bottom
							_k(90, 56, 155.0),     # Another purple ring (has honey)
						]),
					]),
				]),
				_k(-180, 64, 145.0),    # Green full ring bottom-left
			])
		14:
			# Structure: Grid-like structure with many small rings
			# 3 rows of connected rings forming a symmetrical pattern
			# Top row: orange C, green cross, purple C-ring
			# Middle rows: Multiple small rings connected in sequence
			# Bottom row: green C, light cyan full, red full
			# Has 3 honey markers distributed across rings
			return _closed(64, C, [
				_k(-90, 58, 130.0, [     # Orange C-ring top-left
					_k(-50, 62, 145.0, [    # Green cross connector
						_k(-10, 56, 138.0, [    # Purple C-ring top
							_k(30, 60, 152.0, [     # Dark blue C-ring
								_k(70, 58, 140.0, [     # Orange C-ring middle-right
									_k(110, 64, 148.0, [    # Red C-ring
										_k(150, 62, 135.0),     # Green C-ring
									]),
								]),
							]),
						]),
					]),
				]),
				_k(90, 66, 132.0, [      # Dark blue C-ring middle
					_k(130, 58, 146.0, [    # Green C-ring
						_k(170, 60, 138.0, [    # Light cyan full (has honey)
							_k(210, 56, 150.0, [    # Red full (has honey)
								_k(250, 62, 142.0),     # Orange C-ring bottom
							]),
						]),
					]),
				]),
				_k(-70, 64, 135.0, [     # Green C-ring bottom-left (has honey)
					_k(-30, 58, 148.0),      # Light cyan C-ring bottom
				]),
			])
		15:
			# Structure: Nested rings with curved connectors
			# Large purple arc at top, multiple paths downward
			# Green curved sections, light cyan and blue rings scattered
			# Red rings at bottom-left with honey markers
			# Orange curved sections creating complex paths
			return _closed(72, C, [
				_k(-150, 64, 128.0, [    # Green C-ring top-left
					_k(-90, 58, 142.0, [    # Dark blue curved section
						_k(-30, 62, 135.0, [    # Green curved section
							_k(30, 56, 148.0),      # Light cyan C-ring
						]),
					]),
				]),
				_k(0, 68, 90.0, [        # Purple arc top-center
					_k(60, 60, 145.0, [     # Light cyan curved section
						_k(120, 58, 138.0, [    # Green C-ring
							_k(180, 64, 152.0),     # Purple C-ring right
						]),
					]),
				]),
				_k(-90, 66, 132.0, [     # Red ring bottom-left (has honey)
					_k(-30, 58, 146.0, [    # Light cyan curved section
						_k(30, 62, 140.0, [     # Red ring (has honey)
							_k(90, 56, 154.0),      # Orange C-ring (has honey)
						]),
					]),
				]),
				_k(150, 60, 135.0, [     # Orange curved section bottom-right
					_k(210, 58, 148.0),     # Light cyan C-ring
				]),
			])
		16:
			# Structure: Central red full ring with radiating connections
			# Orange ring at top with honey
			# Dark blue and purple C-rings to sides
			# Green C-rings form middle layer
			# Bottom has green, purple, orange, and blue rings with honey markers
			return _closed(68, O, [
				_k(0, 62, 90.0),        # Orange full ring top (has honey)
				_k(-60, 58, 132.0, [    # Dark blue C-ring left
					_k(-120, 60, 148.0),   # Green C-ring bottom-left
				]),
				_k(60, 64, 132.0, [     # Purple C-ring right
					_k(120, 56, 148.0, [   # Green C-ring
						_k(180, 58, 142.0),    # Red full ring center
					]),
				]),
				_k(-180, 66, 135.0, [   # Green C-ring bottom-left
					_k(-120, 60, 150.0, [  # Red full ring
						_k(-60, 58, 140.0, [   # Purple C-ring
							_k(0, 62, 155.0, [     # Orange full ring (has honey)
								_k(60, 56, 145.0),     # Dark blue full ring (has honey)
							]),
						]),
					]),
				]),
				_k(120, 64, 138.0, [    # Light cyan C-ring bottom-right
					_k(180, 58, 152.0),    # Orange C-ring
				]),
			])
		17:
			# Structure: Vertical chain structure
			# Top: Green C-ring with honey, red connector
			# Middle: Orange and red C-rings
			# Light cyan C-ring center, connecting to dark blue and purple
			# Bottom: Complex arrangement with green, light cyan, red rings
			# Multiple branches with honey in orange and green rings
			return _open_root(64, 90.0, [
				_k(0, 66, 130.0, [      # Green C-ring top (has honey)
					_k(90, 58, 145.0, [    # Red connector
						_k(180, 60, 138.0),    # Orange C-ring
					]),
				]),
				_k(90, 68, 132.0, [     # Light cyan C-ring middle
					_k(180, 62, 148.0, [   # Purple curved section
						_k(270, 56, 140.0, [   # Dark blue full ring
							_k(0, 58, 155.0, [     # Orange C-ring (has honey)
								_k(90, 64, 145.0),     # Branch continuation
							]),
						]),
					]),
				]),
				_k(180, 66, 135.0, [    # Green C-ring bottom-left (has honey)
					_k(270, 58, 150.0, [   # Light cyan C-ring
						_k(0, 60, 142.0, [     # Red C-ring
							_k(90, 56, 158.0, [    # Dark blue C-ring
								_k(180, 62, 148.0),    # Purple curved section
							]),
						]),
					]),
				]),
			])
		18:
			# Structure: Mixed shapes with bars (locks)
			# Top: Red rounded rectangle with 2 locks, purple C-rings on sides
			# Orange rings in upper portion
			# Green diagonal bar connector, multiple honey markers
			# Light cyan and dark blue rings at bottom, orange C-ring bottom-right
			# Purple bar at bottom-right
			return _closed(66, S, [  # Red rounded rectangle shape
				_k(-90, 60, 0.0),      # Purple C-ring left (lock)
				_k(90, 60, 0.0),       # Purple C-ring right (lock)
				_k(-45, 58, 135.0, [   # Orange C-ring upper-left
					_k(-90, 62, 148.0, [  # Green diagonal connector
						_k(-135, 56, 142.0, [  # Orange full ring center (has honey)
							_k(-180, 58, 155.0),   # Green C-ring
						]),
					]),
				]),
				_k(0, 64, 130.0, [     # Green C-ring right (has honey)
					_k(45, 60, 145.0, [    # Dark blue C-ring
						_k(90, 56, 138.0),     # Purple C-ring
					]),
				]),
				_k(-135, 62, 132.0, [  # Light cyan C-ring bottom-left
					_k(-180, 58, 148.0, [  # Dark blue full ring (has honey)
						_k(-225, 64, 140.0, [  # Light cyan C-ring
							_k(-270, 60, 155.0),   # Orange C-ring bottom-right
						]),
					]),
				]),
			])
		19:
			# Structure: Highly complex with many bars (connectors)
			# Multiple vertical and horizontal bar segments
			# Top section has purple, dark blue, and light cyan bars
			# Red C-ring left with honey, light cyan full ring middle-left (has honey)
			# Orange and purple curved sections throughout
			# Green curved sections at bottom, connecting to light cyan ring (has honey)
			# Rounded rectangle shapes at bottom (purple and light cyan)
			return _open_root(68, 90.0, [
				_k(-135, 58, 0.0, [     # Purple bar top-left
					_k(-90, 0, 0.0),       # (Bar segment, no ring)
				]),
				_k(-45, 62, 0.0, [      # Dark blue bar top
					_k(0, 0, 0.0, [        # (Bar segment)
						_k(45, 0, 0.0),        # Light cyan bar top-right
					]),
				]),
				_k(90, 60, 0.0, [       # Light cyan bar right
					_k(135, 0, 0.0),       # (Bar segment)
				]),
				_k(-180, 66, 132.0, [   # Red C-ring left (has honey)
					_k(-135, 58, 148.0, [  # Light cyan full ring (has honey)
						_k(-90, 64, 140.0, [   # Green curved section
							_k(-45, 56, 155.0, [   # Orange C-ring
								_k(0, 60, 145.0, [     # Red C-ring middle (has honey)
									_k(45, 58, 158.0, [    # Purple curved section
										_k(90, 62, 148.0),     # Green curved section
									]),
								]),
							]),
						]),
					]),
				]),
				_k(135, 64, 130.0, [    # Green C-ring bottom-left
					_k(180, 58, 145.0, [   # Light cyan bar bottom
						_k(-135, 60, 0.0),     # (Bar segment)
					]),
				]),
				_k(-90, 62, 135.0, [    # Green C-ring bottom-right
					_k(-45, 56, 150.0, [   # Light cyan C-ring (has honey)
						_k(0, 0, 0.0),         # Purple rounded rectangle bottom
					]),
				]),
			])
		20:
			# Structure: Large red circle containing nested rings
			# Forms a face-like pattern with 2 small rings as eyes
			# Green and dark blue small rings at top (eyes)
			# Light cyan and orange smallest rings inside purple arcs (glasses)
			# Has honey markers in the tiny eye rings
			# Angular shapes at top edges (green-blue and green-orange connectors)
			return _closed(150, O, [  # Large red outer circle
				_k(-135, 0, 0.0, [      # Green-blue angular connector top-left
					_k(-90, 0, 0.0),        # (Lock/connector segment)
				]),
				_k(-45, 0, 0.0, [       # Green-orange angular connector top-right
					_k(0, 0, 0.0),          # (Lock/connector segment)
				]),
				_k(-120, 56, 90.0, [    # Green small ring left-eye (has honey)
					_k(-90, 0, 0.0),        # Inner structure
				]),
				_k(-60, 58, 90.0, [     # Dark blue small ring right-eye (has honey)
					_k(-30, 0, 0.0),        # Inner structure
				]),
				_k(0, 68, 180.0, [      # Purple arc glasses frame bottom
					_k(-30, 42, 90.0, [    # Light cyan tiniest ring left (has honey)
						_k(0, 0, 0.0),         # Inner dot
					]),
					_k(30, 44, 90.0, [     # Orange tiniest ring right (has honey)
						_k(0, 0, 0.0),         # Inner dot
					]),
				]),
			])
		21:
			# Structure: Dense grid/web of bars creating intricate pattern
			# Many horizontal and vertical bar segments with locks
			# Forms almost a circuit-board like appearance
			# Multiple lock points throughout the structure
			# Organized in roughly 4 horizontal layers
			# Colors distributed across: light cyan, purple, green, orange, dark blue, red
			# No visible honey markers in this level
			return _open_root(0, 0.0, [  # No central ring, starts with bar network
				# Top layer bars
				_k(-180, 0, 0.0, [      # Light cyan bar far-left
					_k(-150, 0, 0.0, [     # Purple bar
						_k(-120, 0, 0.0),      # (Lock point)
					]),
				]),
				_k(-90, 0, 0.0, [       # Red bar top-center
					_k(-60, 0, 0.0, [      # Green bar
						_k(-30, 0, 0.0),       # (Lock point)
					]),
				]),
				_k(0, 0, 0.0, [         # Green bar top-right
					_k(30, 0, 0.0, [       # Light cyan bar
						_k(60, 0, 0.0),        # (Lock point)
					]),
				]),
				# Second layer
				_k(-165, 0, 0.0, [      # Light cyan vertical segment
					_k(-135, 0, 0.0, [     # Green L-shape
						_k(-105, 0, 0.0),      # (Lock point)
					]),
				]),
				_k(-75, 0, 0.0, [       # Dark blue vertical
					_k(-45, 0, 0.0, [      # Orange segment
						_k(-15, 0, 0.0, [      # Purple segment
							_k(15, 0, 0.0),        # Green segment (lock)
						]),
					]),
				]),
				# Third layer
				_k(-150, 0, 0.0, [      # Green horizontal bar
					_k(-120, 0, 0.0, [     # Light cyan segment
						_k(-90, 0, 0.0, [      # Purple L-shape
							_k(-60, 0, 0.0),       # (Lock point)
						]),
					]),
				]),
				_k(-30, 0, 0.0, [       # Orange horizontal
					_k(0, 0, 0.0, [        # Light cyan segment
						_k(30, 0, 0.0, [       # Orange segment
							_k(60, 0, 0.0),        # (Lock point)
						]),
					]),
				]),
				# Bottom layer
				_k(-180, 0, 0.0, [      # Red bar bottom-left
					_k(-150, 0, 0.0, [     # Green bar
						_k(-120, 0, 0.0),      # (Lock point)
					]),
				]),
				_k(-90, 0, 0.0, [       # Purple bar bottom-center
					_k(-60, 0, 0.0),       # (Lock point)
				]),
			])
		22:
			# Structure: Large red circle with complex internal network
			# Top section has smaller rings and bars radiating outward
			# Purple C-ring top-left (has honey)
			# Orange and light cyan branches with connectors
			# Center contains green C-ring (has honey), orange C-ring, light cyan C-ring (has honey)
			# Red circle encloses a smaller section
			# Bottom has light cyan bar with orange connector
			# Dark blue C-ring bottom-center
			# Right side has red and green bars with locks
			return _closed(145, O, [  # Large red outer circle
				_k(-135, 60, 132.0, [   # Purple C-ring top-left (has honey)
					_k(-90, 58, 148.0, [   # Orange connector
						_k(-45, 0, 0.0, [      # (Bar segment to lock)
							_k(0, 0, 0.0),         # Red bar lock
						]),
					]),
				]),
				_k(-45, 62, 135.0, [    # Orange C-ring top
					_k(0, 64, 150.0, [     # Light cyan connector
						_k(45, 58, 142.0, [    # Dark blue full ring
							_k(90, 56, 155.0),     # Green C-ring
						]),
					]),
				]),
				_k(90, 66, 130.0, [     # Red bar right side
					_k(135, 0, 0.0),       # Green bar with lock
				]),
				_k(0, 88, 90.0, [       # Inner red circle center
					_k(-45, 58, 145.0, [   # Green C-ring inside (has honey)
						_k(-90, 60, 158.0, [   # Orange C-ring
							_k(-135, 56, 148.0),   # Light cyan C-ring (has honey)
						]),
					]),
				]),
				_k(180, 64, 132.0, [    # Light cyan bar bottom
					_k(-135, 0, 0.0, [     # Orange connector bar
						_k(-90, 0, 0.0),       # (Lock segment)
					]),
				]),
				_k(-90, 62, 138.0),     # Dark blue C-ring bottom-center
			])
		23:
			# Structure: Dense cluster of overlapping rings
			# Top row: green full ring with light cyan full ring (has honey), green C-ring with honey
			# Middle rows have orange full rings with purple and light cyan arcs
			# Center has green circle with red curved section, dark blue C-ring below
			# Bottom section has green C-rings, dark blue full ring (has honey), light cyan C-ring
			# Red C-ring and orange full ring at bottom-right edge
			# Purple C-ring bottom-center
			return _open_root(66, 90.0, [
				_k(-150, 62, 90.0, [    # Purple full ring top-left
					_k(-90, 58, 145.0, [   # Light cyan C-ring
						_k(-30, 64, 138.0),    # Orange full ring
					]),
				]),
				_k(-90, 68, 90.0, [     # Green full ring top (has light cyan inside)
					_k(0, 60, 90.0, [      # Light cyan full ring (has honey)
						_k(90, 56, 155.0),     # Dark blue C-ring
					]),
				]),
				_k(0, 64, 132.0, [      # Green C-ring top-right (has honey)
					_k(90, 58, 148.0, [    # Orange connector
						_k(180, 62, 140.0),    # Purple C-ring
					]),
				]),
				_k(90, 72, 90.0, [      # Orange full ring middle-top
					_k(0, 66, 145.0, [     # Green circle center
						_k(-90, 58, 158.0, [   # Red curved section
							_k(-180, 60, 148.0, [  # Green C-ring
								_k(-270, 56, 162.0),   # Dark blue C-ring
							]),
						]),
					]),
					_k(180, 64, 135.0),    # Light cyan C-ring middle-right
				]),
				_k(180, 58, 132.0, [    # Green C-ring bottom-left
					_k(-90, 62, 148.0, [   # Dark blue full ring (has honey)
						_k(0, 56, 142.0, [     # Light cyan C-ring
							_k(90, 60, 155.0),     # Red C-ring
						]),
					]),
				]),
				_k(-45, 64, 138.0, [    # Orange full ring bottom-right
					_k(45, 58, 152.0),     # Purple C-ring bottom
				]),
			])
		24:
			# Structure: Layered grid structure with multiple rings and bars
			# Top row: green C-ring (has honey), light cyan full ring, orange C-ring
			# Second row: orange C-ring, purple full ring with purple L-connector
			# Third row (red bar) connects dark blue C-ring, green C-ring (has honey), orange C-ring
			# Fourth row: light cyan C-ring, dark blue full ring
			# Fifth row: dark blue C-ring, green full ring, purple curved, red full ring
			# Bottom row: green T-connector, light cyan full ring (has honey), orange bar with lock
			return _open_root(0, 0.0, [  # No central root, complex grid starts
				# Top layer
				_k(-180, 58, 132.0, [   # Green bar left (has honey on green C)
					_k(-150, 60, 148.0, [  # Light cyan full ring
						_k(-120, 62, 140.0, [  # Dark blue C-ring
							_k(-90, 56, 155.0, [   # Orange C-ring
								_k(-60, 64, 145.0, [   # Red C-ring
									_k(-30, 58, 158.0),    # Purple full ring
								]),
							]),
						]),
					]),
				]),
				# Middle layer (red horizontal bar)
				_k(0, 0, 0.0, [         # Red bar spanning width
					_k(-30, 62, 135.0, [   # Light cyan C-ring
						_k(0, 60, 148.0, [     # Dark blue C-ring
							_k(30, 58, 142.0),     # Green C-ring (has honey)
						]),
					]),
					_k(60, 56, 138.0, [    # Orange C-ring
						_k(90, 64, 152.0),     # Purple curved section
					]),
				]),
				# Lower layer
				_k(-150, 66, 130.0, [   # Dark blue C-ring bottom-left
					_k(-120, 58, 145.0, [  # Green full ring
						_k(-90, 60, 138.0, [   # Light cyan C-ring
							_k(-60, 56, 152.0, [   # Purple curved section
								_k(-30, 62, 145.0),    # Red full ring
							]),
						]),
					]),
				]),
				# Bottom layer
				_k(-180, 0, 0.0, [      # Green T-connector left
					_k(-150, 0, 0.0, [     # Light cyan bar
						_k(-120, 64, 132.0, [  # Light cyan full ring (has honey)
							_k(-90, 0, 0.0, [      # Orange bar
								_k(-60, 0, 0.0),       # (Lock point)
							]),
						]),
					]),
				]),
			])
		25:
			# Structure: Organic flowing design with curved connectors
			# Top has purple curved section (has honey), light cyan curved section
			# Orange C-ring top-right connecting to dark blue L-shape
			# Red C-ring left, orange curved section
			# Light cyan full ring center (has honey) with green curved section below
			# Purple and dark blue curved sections with green L-shape
			# Bottom has orange C-ring (has honey), green L-connector with dark blue curved section
			return _open_root(64, 90.0, [
				_k(-150, 60, 125.0, [   # Purple curved section top-left (has honey)
					_k(-90, 58, 142.0, [   # Light cyan curved section
						_k(-30, 62, 135.0, [   # Orange C-ring
							_k(30, 56, 150.0),     # Dark blue L-shape
						]),
					]),
				]),
				_k(-180, 66, 130.0, [   # Red C-ring left
					_k(-120, 64, 148.0, [  # Orange curved section
						_k(-60, 58, 140.0, [   # Light cyan full ring center (has honey)
							_k(0, 60, 155.0, [     # Green curved section
								_k(60, 56, 145.0),     # Dark blue curved section
							]),
						]),
					]),
				]),
				_k(90, 62, 132.0, [     # Purple curved section right
					_k(150, 58, 148.0, [   # Dark blue curved section
						_k(-150, 0, 0.0),      # Green L-connector
					]),
				]),
				_k(180, 64, 138.0, [    # Orange C-ring bottom (has honey)
					_k(-120, 0, 0.0, [     # Green L-shape
						_k(-60, 0, 0.0),       # Dark blue curved section (lock)
					]),
				]),
			])
		26:
			# Structure: Symmetrical radial pattern with central light cyan full ring
			# Top layer: green C-ring, orange connector, purple C-ring
			# Upper-middle: dark blue C-ring left, purple curved, red C-ring right
			# Center: light cyan full ring hub
			# Lower-middle: orange C-ring, green C-ring
			# Bottom: light cyan C-ring (has honey), light cyan full ring (has honey), red C-ring (has honey)
			# All arranged in roughly circular pattern around center
			return _closed(72, C, [  # Central light cyan full ring
				_k(-180, 58, 130.0, [   # Green C-ring top-left
					_k(-135, 60, 145.0, [  # Orange connector
						_k(-90, 56, 138.0),    # Purple C-ring top-right
					]),
				]),
				_k(-120, 62, 132.0, [   # Dark blue C-ring left
					_k(-60, 58, 148.0, [   # Purple curved section
						_k(0, 64, 140.0),      # Light cyan full ring left
					]),
				]),
				_k(60, 60, 135.0, [     # Red C-ring right
					_k(120, 56, 150.0, [   # Orange curved section
						_k(180, 58, 142.0),    # Purple C-ring bottom
					]),
				]),
				_k(-90, 66, 128.0, [    # Orange C-ring bottom-left
					_k(-30, 62, 145.0, [   # Green C-ring
						_k(30, 58, 138.0),     # Red C-ring
					]),
				]),
				_k(90, 64, 132.0, [     # Light cyan C-ring bottom-right (has honey)
					_k(150, 60, 148.0, [   # Light cyan full ring (has honey)
						_k(-150, 56, 155.0),   # Red C-ring (has honey)
					]),
				]),
			])
		27:
			# Structure: Mix of rings and long bars
			# Top: orange full ring (has honey), green L-bar, dark blue bar, purple bar
			# Middle-top: dark blue C-ring, purple C-ring left, orange bar right
			# Center: light cyan full ring with green C-ring (has honey), dark blue C-ring (has honey)
			# Middle-bottom: purple L-bar, light cyan C-ring, green full ring
			# Bottom: orange and green bars, green C-ring, red bar with lock
			return _open_root(68, 90.0, [
				_k(-180, 64, 90.0, [    # Orange full ring top-left (has honey)
					_k(-135, 0, 0.0, [     # Green L-bar
						_k(-90, 0, 0.0, [      # Dark blue bar top
							_k(-45, 0, 0.0),       # Purple bar
						]),
					]),
				]),
				_k(-120, 60, 132.0, [   # Dark blue C-ring left
					_k(-60, 58, 148.0, [   # Purple C-ring
						_k(0, 0, 0.0),         # Orange bar right
					]),
				]),
				_k(0, 72, 90.0, [       # Light cyan full ring center
					_k(-45, 62, 145.0, [   # Green C-ring (has honey)
						_k(-90, 56, 158.0, [   # Dark blue C-ring (has honey)
							_k(-135, 60, 148.0),   # Purple curved section
						]),
					]),
					_k(45, 64, 140.0, [    # Orange C-ring right
						_k(90, 58, 155.0),     # Light cyan curved section
					]),
				]),
				_k(135, 0, 0.0, [       # Purple L-bar bottom-right
					_k(180, 66, 132.0, [   # Light cyan C-ring
						_k(-135, 60, 148.0, [  # Green full ring
							_k(-90, 58, 142.0, [   # Orange C-ring
								_k(-45, 62, 158.0),    # Dark blue curved section
							]),
						]),
					]),
				]),
				_k(-180, 0, 0.0, [      # Orange bar bottom-left
					_k(-135, 0, 0.0, [     # Green bar
						_k(-90, 56, 135.0, [   # Green C-ring
							_k(-45, 0, 0.0),       # Red bar with lock
						]),
					]),
				]),
			])
		28:
			# Structure: Dense overlapping rings creating complex puzzle
			# Top: dark blue C-ring (has honey), green C-ring
			# Upper-middle: green full ring, red full ring, light cyan C-ring (has honey)
			# Center: purple C-ring, light cyan curved section with bar lock
			# Lower-middle: light cyan C-ring, green C-ring, orange full ring
			# Bottom: red full ring, purple C-ring, orange C-ring with red bar, light cyan bar lock
			# Multiple honey markers: dark blue, light cyan, green rings
			return _open_root(66, 90.0, [
				_k(-150, 58, 130.0, [   # Dark blue C-ring top (has honey)
					_k(-90, 60, 145.0, [   # Green C-ring
						_k(-30, 56, 138.0),    # Light cyan C-ring
					]),
				]),
				_k(-120, 64, 132.0, [   # Green full ring left
					_k(-60, 62, 148.0, [   # Red full ring
						_k(0, 58, 140.0, [     # Light cyan C-ring (has honey)
							_k(60, 60, 155.0),     # Purple curved section
						]),
					]),
				]),
				_k(30, 66, 135.0, [     # Purple C-ring right
					_k(90, 58, 150.0, [    # Orange C-ring
						_k(150, 0, 0.0),       # Light cyan bar lock
					]),
				]),
				_k(0, 68, 90.0, [       # Light cyan curved section center
					_k(45, 62, 145.0, [    # Green C-ring (has honey)
						_k(90, 56, 158.0, [    # Light cyan C-ring
							_k(135, 60, 148.0),    # Orange C-ring
						]),
					]),
				]),
				_k(180, 64, 132.0, [    # Red full ring bottom-left
					_k(-135, 58, 148.0, [  # Purple C-ring
						_k(-90, 60, 142.0, [   # Orange full ring
							_k(-45, 56, 155.0, [   # Light cyan C-ring
								_k(0, 0, 0.0, [        # Red bar
									_k(45, 0, 0.0),        # Light cyan bar lock
								]),
							]),
						]),
					]),
				]),
			])
		29:
			# Structure: Complex web of bars and rings
			# Top: light cyan C-ring, purple bar with lock, green bar
			# Upper section: purple curved section, light cyan C-ring, green C-ring (has honey)
			# Middle: dark blue C-ring, light cyan full ring, orange curved section with green bar lock
			# Center-right: purple U-shape bar, orange C-ring, light cyan bar, green-red connector
			# Lower-left: green curved section with lock, light cyan bar
			# Bottom: orange full ring (has honey), dark blue full ring, purple full ring (has honey)
			# Red C-ring, orange bar, green C-ring bottom-right
			return _open_root(0, 0.0, [  # No central root, complex bar structure
				# Top section
				_k(-180, 0, 0.0, [      # Green bar far-left
					_k(-150, 0, 0.0, [     # Purple bar with lock
						_k(-120, 0, 0.0),      # Light cyan C-ring
					]),
				]),
				_k(-90, 60, 125.0, [    # Purple curved section top
					_k(-30, 58, 142.0, [   # Light cyan C-ring
						_k(30, 56, 135.0),     # Green C-ring (has honey)
					]),
				]),
				_k(0, 0, 0.0, [         # Green bar top-right
					_k(30, 0, 0.0, [       # Dark blue bar
						_k(60, 0, 0.0),        # (Lock point)
					]),
				]),
				# Middle section
				_k(-120, 64, 130.0, [   # Dark blue C-ring left
					_k(-60, 62, 148.0, [   # Light cyan full ring
						_k(0, 58, 140.0, [     # Orange curved section
							_k(60, 0, 0.0),        # Green bar lock
						]),
					]),
				]),
				_k(90, 0, 0.0, [        # Purple U-shape bar right
					_k(120, 60, 145.0, [   # Orange C-ring
						_k(150, 0, 0.0, [      # Light cyan bar
							_k(180, 0, 0.0),       # Green-red connector
						]),
					]),
				]),
				# Bottom section
				_k(-180, 0, 0.0, [      # Green curved section bottom-left (lock)
					_k(-150, 0, 0.0, [     # Light cyan bar
						_k(-120, 56, 132.0, [  # Orange full ring (has honey)
							_k(-90, 58, 148.0, [   # Dark blue full ring
								_k(-60, 60, 142.0, [   # Purple full ring (has honey)
									_k(-30, 62, 155.0),    # Red C-ring
								]),
							]),
						]),
					]),
				]),
				_k(135, 0, 0.0, [       # Orange bar bottom-right
					_k(180, 64, 138.0),    # Green C-ring
				]),
			])
		30:
			# Structure: Symmetric diamond/gem shape made entirely of bars
			# Top apex: red bar, dark blue bar, green bar
			# Upper layer: purple bar left, light cyan bar center, green bar right
			# Middle layer (widest): orange bar left, green bar, light cyan bar, purple bar, orange bar, dark blue bar right
			# Lower layer: red bar left, purple bar, green bar right
			# Bottom apex converging bars
			# All elements are lock bars, no circular rings
			# Forms geometric pattern resembling a cut gemstone
			return _open_root(0, 0.0, [  # No rings, pure bar structure
				# Top apex
				_k(-180, 0, 0.0, [      # Green bar top-left
					_k(-150, 0, 0.0, [     # Red bar apex
						_k(-120, 0, 0.0),      # Dark blue bar top-right
					]),
				]),
				# Upper layer
				_k(-165, 0, 0.0, [      # Purple bar left
					_k(-135, 0, 0.0, [     # Light cyan bar center
						_k(-105, 0, 0.0),      # Green bar right
					]),
				]),
				# Middle wide layer
				_k(-150, 0, 0.0, [      # Orange bar far-left
					_k(-120, 0, 0.0, [     # Green bar
						_k(-90, 0, 0.0, [      # Light cyan bar center
							_k(-60, 0, 0.0, [      # Purple bar
								_k(-30, 0, 0.0, [      # Orange bar
									_k(0, 0, 0.0),         # Dark blue bar far-right
								]),
							]),
						]),
					]),
				]),
				# Lower layer
				_k(-165, 0, 0.0, [      # Red bar bottom-left
					_k(-135, 0, 0.0, [     # Purple bar
						_k(-105, 0, 0.0),      # Green bar bottom-right
					]),
				]),
				# Bottom apex
				_k(-180, 0, 0.0, [      # Light cyan bar
					_k(-150, 0, 0.0),      # Green bar bottom apex
				]),
			])

		# Helper to get level by number
		31:
			# Complex layout with square bridges and cuffed rings
			# Seen: Center green circle O with cuff, orange/purple/blue rings with cuffs
			# Red, purple, blue square bridges with locks
			return _closed(64.0, O, [
				_k(-135.0, 58.0, 140.0),  # Orange ring with cuff (top-left)
				_k(-45.0, 60.0, 145.0),   # Purple ring with cuff (top-right)
				_k(0.0, 62.0, 135.0),     # Blue ring (top)
				_k(90.0, 64.0, 150.0, [   # Green connector (right)
					_k(135.0, 58.0, 140.0),  # Blue ring
				]),
				_k(180.0, 56.0, 145.0),   # Red connector (bottom)
				_k(-90.0, 60.0, 140.0),   # Purple connector (left)
			])
		32:
			# Central orange circle O with cuff, multiple rings, square bridges with locks
			# Seen: Red circle top, purple with green bridge, blue with cuff top-right
			# Blue-purple square bridge bottom with lock spanning
			return _closed(66.0, O, [
				_k(-90.0, 62.0, 135.0),   # Red circle at top
				_k(-30.0, 58.0, 145.0, [  # Purple ring
					_k(0.0, 60.0, 140.0),   # Green square bridge effect
				]),
				_k(30.0, 64.0, 138.0),    # Blue circle with cuff (top-right)
				_k(90.0, 60.0, 150.0, [   # Blue ring (right)
					_k(120.0, 58.0, 145.0), # Orange ring
				]),
				_k(150.0, 62.0, 135.0),   # Red circle with cuff (bottom-right)
				_k(-150.0, 56.0, 142.0),  # Green circle O with cuff (bottom-left)
			])
		33:
			# Very complex scattered layout with many square bridges
			# Seen: Blue square bridge center, green circle O with cuff
			# Multiple square bridges forming complex grid
			return _closed(68.0, O, [
				_k(-120.0, 60.0, 135.0),  # Green ring (top-left)
				_k(-60.0, 58.0, 145.0),   # Red circle with cuff
				_k(-20.0, 62.0, 140.0),   # Blue ring (top)
				_k(20.0, 56.0, 138.0),    # Orange ring
				_k(60.0, 64.0, 150.0, [   # Blue connector
					_k(90.0, 58.0, 142.0),  # Orange connector
				]),
				_k(120.0, 60.0, 135.0, [  # Green connector
					_k(150.0, 62.0, 145.0), # Purple circle with cuff
				]),
				_k(180.0, 58.0, 140.0),   # Orange connector (bottom)
				_k(-150.0, 56.0, 138.0),  # Green circles (bottom-left)
			])
		34:
			# Grid-like pattern 4x4 arrangement
			# Seen: Purple/orange/blue rings with cuffs in organized grid
			# Multiple circles O in bottom rows
			return _closed(70.0, C, [
				_k(-135.0, 58.0, 135.0),  # Purple ring with cuff (top-left)
				_k(-90.0, 60.0, 140.0),   # Orange ring
				_k(-45.0, 62.0, 138.0),   # Blue ring with cuff
				_k(0.0, 56.0, 145.0),     # Green circle O
				_k(45.0, 64.0, 135.0),    # Orange circle
				_k(90.0, 58.0, 142.0),    # Purple with cuff
				_k(135.0, 60.0, 140.0, [  # Blue connector
					_k(150.0, 62.0, 145.0), # Orange connector
				]),
				_k(-135.0, 56.0, 138.0),  # Red ring (bottom)
			])
		35:
			# Scattered organic with square bridges
			# Seen: Blue square bridge top-left with lock, multiple circles O with cuffs
			# Orange and green square bridges on right with locks
			return _closed(66.0, O, [
				_k(-150.0, 60.0, 138.0),  # Blue square bridge area (top-left)
				_k(-90.0, 62.0, 145.0),   # Red circle with cuff
				_k(-30.0, 58.0, 135.0),   # Blue circle O with cuff
				_k(30.0, 64.0, 142.0),    # Purple and orange rings center
				_k(90.0, 56.0, 140.0, [   # Orange square bridge
					_k(120.0, 60.0, 145.0), # Green square bridge with locks
				]),
				_k(150.0, 62.0, 138.0),   # Green circle O with cuff (bottom-left)
			])
		36:
			# Vertical layout with square bridges
			# Seen: Blue ring top-left, orange circle O top-right with lock
			# Purple circle O with cuff, blue circle O with cuff at bottom
			return _closed(64.0, C, [
				_k(-120.0, 58.0, 135.0, [  # Blue ring (top-left)
					_k(-90.0, 60.0, 140.0),  # Green square bridge
				]),
				_k(-30.0, 64.0, 145.0),    # Orange circle O with red hook
				_k(0.0, 62.0, 138.0),      # Purple circle O with cuff (left)
				_k(60.0, 56.0, 142.0),     # Green rings center
				_k(120.0, 60.0, 140.0),    # Blue circle O with cuff
				_k(-150.0, 58.0, 135.0),   # Purple square bridge with lock
			])
		37:
			# Organic scattered with square bridges
			# Seen: Green ring with orange square bridge at top
			# Orange circle O with cuff center, green circle O with cuff bottom-left
			return _closed(66.0, O, [
				_k(-120.0, 60.0, 135.0, [  # Green ring (top)
					_k(-90.0, 58.0, 140.0),  # Orange square bridge
				]),
				_k(-30.0, 64.0, 145.0),    # Orange circle O with cuff (center)
				_k(30.0, 62.0, 138.0),     # Red and green rings
				_k(90.0, 56.0, 142.0),     # Purple and blue rings
				_k(150.0, 60.0, 140.0, [   # Blue square bridge
					_k(180.0, 58.0, 145.0),  # Red square bridge
				]),
				_k(-150.0, 64.0, 135.0),   # Green circle O with cuff (bottom-left)
			])
		38:
			# Highly structured GRID with square bridges
			# Seen: Blue/orange square bridges spanning top (locks)
			# 4x4 grid with purple circle O center, many cuffs
			# Green/blue square bridges bottom spanning (locks)
			return _closed(68.0, S, [
				_k(-135.0, 60.0, 135.0),  # Top-left cell
				_k(-90.0, 58.0, 140.0),   # Top-center-left
				_k(-45.0, 62.0, 138.0),   # Top-center-right
				_k(0.0, 56.0, 145.0),     # Top-right cell
				_k(45.0, 64.0, 135.0),    # Middle-right
				_k(90.0, 60.0, 142.0),    # Purple circle O (center)
				_k(135.0, 58.0, 140.0),   # Bottom-right
				_k(180.0, 62.0, 138.0),   # Bottom-center
				_k(-135.0, 56.0, 135.0),  # Bottom-left
				_k(-90.0, 64.0, 142.0),   # Bottom-center-left
			])
		39:
			# Symmetric vertical with square bridges
			# Seen: Red circle O with cuff top-left, blue circle O with cuff top-right
			# Purple square bridge vertical in center, orange circle O center
			return _closed(70.0, C, [
				_k(-150.0, 62.0, 140.0),  # Red circle O with cuff (top-left)
				_k(-90.0, 58.0, 135.0),   # Purple square bridge (vertical center)
				_k(-30.0, 64.0, 145.0),   # Blue circle O with cuff (top-right)
				_k(0.0, 60.0, 138.0),     # Green and purple circles O (middle)
				_k(60.0, 56.0, 142.0),    # Orange circle O (center)
				_k(120.0, 62.0, 140.0),   # Blue and orange rings (bottom)
				_k(180.0, 58.0, 135.0),   # Green square bridge (bottom)
			])
		40:
			# VEHICLE/CAR shape
			# Seen: Two large circles O at bottom (orange/purple with cuffs) as "wheels"
			# Green square bridge spans between wheels (lock)
			# Upper structure forms "body" with colored square bridges
			return _closed(64.0, O, [
				_k(-150.0, 66.0, 0.0),    # Orange circle O with cuff (left wheel)
				_k(-90.0, 58.0, 135.0, [  # Green square bridge (axle)
					_k(-60.0, 60.0, 140.0), # Purple square bridge (frame)
					_k(-30.0, 56.0, 145.0), # Blue square bridge
					_k(0.0, 62.0, 138.0),   # Green square bridge (top frame)
				]),
				_k(150.0, 66.0, 0.0),     # Purple circle O with cuff (right wheel)
			])
		41:
			# Complex scattered with many square bridges
			# Seen: Purple ring with cuff top-left, center has red/orange/green circles O
			# Many square bridges (green/blue/red horizontal with locks)
			return _closed(70.0, O, [
				_k(-135.0, 60.0, 135.0),  # Purple ring with cuff (top-left)
				_k(-90.0, 58.0, 140.0),   # Green ring
				_k(-45.0, 62.0, 145.0),   # Blue ring (top)
				_k(0.0, 64.0, 138.0),     # Red circle O (center-left)
				_k(45.0, 56.0, 142.0),    # Orange circle O with cuff (center)
				_k(90.0, 60.0, 140.0),    # Green circle O with cuff (center-right)
				_k(135.0, 58.0, 135.0, [  # Multiple square bridges
					_k(150.0, 62.0, 145.0), # Blue/red/purple spans
				]),
				_k(-150.0, 64.0, 138.0),  # Bottom section with bridges
			])
		42:
			# Vertical organic layout
			# Seen: Green square bridge top, multiple circle Os with cuffs
			# Blue square bridge vertical in center
			return _closed(66.0, C, [
				_k(-120.0, 58.0, 135.0),  # Green square bridge (top)
				_k(-60.0, 60.0, 140.0),   # Red and purple rings (top)
				_k(0.0, 64.0, 145.0),     # Purple circle O with cuff (center-left)
				_k(30.0, 62.0, 138.0),    # Blue square bridge (vertical center)
				_k(60.0, 56.0, 142.0),    # Red and purple rings (center-right)
				_k(120.0, 60.0, 140.0),   # Orange circle O with cuff (bottom-left)
				_k(150.0, 58.0, 135.0),   # Green circle O with cuff (bottom-right)
			])
		43:
			# Complex scattered with multiple square bridges
			# Seen: Large orange square bridge top-left, purple inside
			# Green/blue square bridges, multiple circle Os with cuffs
			return _closed(68.0, O, [
				_k(-150.0, 62.0, 135.0),  # Orange square bridge (large top-left)
				_k(-90.0, 58.0, 140.0),   # Green square bridge (top-center)
				_k(-30.0, 64.0, 145.0),   # Blue square bridge (top-right)
				_k(0.0, 60.0, 138.0),     # Purple circle O with cuff (center)
				_k(60.0, 56.0, 142.0),    # Green circle O with cuff (center)
				_k(120.0, 62.0, 140.0),   # Red ring with cuff
				_k(150.0, 58.0, 135.0),   # Orange and blue square bridges (bottom)
			])
		44:
			# Large green circle O dominates right side
			# Seen: Inside has orange/blue/purple rings with cuffs
			# Outside has square bridges and orange circle O with cuff
			return _closed(70.0, O, [
				_k(-150.0, 60.0, 135.0),  # Red and green rings (left)
				_k(-90.0, 58.0, 140.0),   # Blue rings and orange circle O with cuff (left)
				_k(-30.0, 64.0, 145.0),   # Purple square bridge (top)
				_k(30.0, 62.0, 138.0),    # Large green circle O area (right)
				_k(60.0, 56.0, 142.0),    # Orange ring with cuff (inside)
				_k(90.0, 60.0, 140.0),    # Blue and purple rings with cuffs (inside)
				_k(150.0, 58.0, 135.0),   # Green square bridge (left)
			])
		45:
			# Scattered organic with square bridges and locks
			# Seen: Orange/green/red square bridges at top
			# Multiple circle Os with cuffs, blue/green square bridges with locks
			return _closed(64.0, C, [
				_k(-135.0, 62.0, 135.0),  # Orange square bridge (top-left)
				_k(-90.0, 58.0, 140.0),   # Green square bridge with lock (top)
				_k(-45.0, 64.0, 145.0),   # Red circle O with cuff (center-top)
				_k(0.0, 60.0, 138.0),     # Orange circles O (center)
				_k(45.0, 56.0, 142.0),    # Purple ring with cuff
				_k(90.0, 62.0, 140.0),    # Blue rings and green circle O
				_k(135.0, 58.0, 135.0),   # Green circle O with cuff (bottom-right)
			])
		46:
			# Very complex dense tree/pyramid structure
			# Seen: Top row has multiple rings with cuffs
			# Purple/green square bridges (vertical), many branches
			# Bottom has green rings and orange ring
			return _closed(72.0, T, [
				_k(-150.0, 60.0, 135.0, [  # Top-left branch
					_k(-120.0, 58.0, 140.0), # Red ring
					_k(-90.0, 62.0, 145.0),  # Blue rings
				]),
				_k(-60.0, 64.0, 138.0, [   # Top-center-left branch
					_k(-30.0, 56.0, 142.0),  # Green rings O with cuffs
				]),
				_k(0.0, 60.0, 140.0, [     # Center branch (purple square bridges)
					_k(30.0, 58.0, 145.0),   # Orange/red/blue rings
				]),
				_k(60.0, 62.0, 135.0, [    # Center-right branch
					_k(90.0, 64.0, 140.0),   # Purple rings
				]),
				_k(120.0, 56.0, 138.0),    # Right branch
				_k(150.0, 60.0, 142.0),    # Bottom branches
			])
		47:
			# Two-section layout with square bridges
			# Seen: Top has blue ring with cuff, orange circle O, blue square bridge
			# Bottom has red/green/blue rings, square bridges with locks, circles O
			return _closed(66.0, C, [
				_k(-150.0, 62.0, 135.0),  # Blue ring with cuff (top-left)
				_k(-90.0, 58.0, 140.0),   # Orange circle O (top)
				_k(-30.0, 64.0, 145.0),   # Purple ring and blue square bridge (top-right)
				_k(30.0, 60.0, 138.0),    # Red circle O (bottom-left)
				_k(60.0, 56.0, 142.0),    # Green square bridge (horizontal lock)
				_k(120.0, 62.0, 140.0),   # Purple circle O and orange circle O (bottom)
			])
		48:
			# Scattered circular cluster
			# Seen: Orange circle O with cuff at center
			# Radiating rings around, multiple square bridges with locks
			return _closed(68.0, O, [
				_k(-135.0, 60.0, 135.0),  # Orange ring (top-left)
				_k(-90.0, 58.0, 140.0),   # Blue ring (top)
				_k(-45.0, 62.0, 145.0),   # Purple ring (top-right)
				_k(0.0, 64.0, 0.0),       # Orange circle O with cuff (center)
				_k(45.0, 56.0, 142.0),    # Red circle O and green ring
				_k(90.0, 60.0, 140.0),    # Purple circle O with cuff (right)
				_k(135.0, 58.0, 135.0),   # Blue/green/red square bridges with locks
			])
		49:
			# Dense triangular/pyramid cluster
			# Seen: Top row has green/blue/red/green/blue rings
			# Middle has purple/orange/red circle O with cuff
			# Bottom has blue circles O, orange circles O with cuffs
			return _closed(70.0, C, [
				_k(-135.0, 58.0, 135.0, [  # Top-left branch
					_k(-120.0, 60.0, 140.0), # Green rings
					_k(-105.0, 62.0, 145.0), # Blue ring
				]),
				_k(-90.0, 64.0, 138.0),    # Top-center (red ring)
				_k(-45.0, 56.0, 142.0, [   # Top-center-right
					_k(-30.0, 60.0, 140.0),  # Green and blue rings
				]),
				_k(0.0, 62.0, 135.0, [     # Center (red circle O with cuff)
					_k(15.0, 58.0, 145.0),   # Orange ring
				]),
				_k(45.0, 64.0, 140.0, [    # Bottom-left branch
					_k(60.0, 56.0, 138.0),   # Blue circles O with cuff
				]),
				_k(90.0, 60.0, 142.0, [    # Bottom-center
					_k(105.0, 62.0, 140.0),  # Orange circles O with cuff
				]),
				_k(135.0, 58.0, 135.0),    # Bottom-right (purple circle O)
			])
		50:
			# FLOWER/PINWHEEL pattern
			# Seen: Central blue circle O with cuff
			# Six radiating "petals" with square bridges and cuffs at ends
			# Bottom has large green-red square bridge and clusters
			var hub := _closed(64.0, O, [
				_k(-90.0, 60.0, 135.0, [   # Top petal (red-green)
					_k(-90.0, 58.0, 140.0),  # Square bridge segment
				]),
				_k(-30.0, 62.0, 138.0, [   # Top-right petal (green-purple)
					_k(-30.0, 56.0, 145.0),  # Square bridge segment
				]),
				_k(30.0, 64.0, 142.0, [    # Right petal (purple-red)
					_k(30.0, 60.0, 140.0),   # Square bridge segment
				]),
				_k(90.0, 58.0, 135.0, [    # Bottom-right petal (orange-blue)
					_k(90.0, 62.0, 138.0),   # Square bridge segment
				]),
				_k(150.0, 60.0, 140.0, [   # Bottom-left petal (blue-orange)
					_k(150.0, 56.0, 145.0),  # Square bridge segment
				]),
				_k(-150.0, 64.0, 142.0, [  # Left petal (orange-red)
					_k(-150.0, 58.0, 140.0), # Square bridge segment
				]),
			])
			hub["locks"] = [[0, 1], [1, 2], [2, 3], [3, 4], [4, 5], [5, 0]]
			return hub
		51:
			# Complex symmetric structure with multiple cuffed rings
			var hub := _closed(66.0, O, [
				_k(-150.0, 64.0, 132.0, [  # Red circle with cuff (left)
					_k(-120.0, 58.0, 149.0),  # Green hook
				]),
				_k(-90.0, 58.0, 132.0, [  # Orange ring (top-left)
					_k(-60.0, 60.0, 149.0),  # Blue hook
				]),
				_k(-30.0, 62.0, 132.0, [  # Blue ring (top)
					_k(0.0, 56.0, 149.0),  # Purple hook
				]),
				_k(30.0, 60.0, 132.0, [  # Purple ring with cuff (top-right)
					_k(60.0, 58.0, 149.0),  # Green hook
				]),
				_k(90.0, 64.0, 132.0, [  # Orange ring (right)
					_k(120.0, 56.0, 149.0),  # Blue hook
				]),
				_k(150.0, 58.0, 132.0, [  # Blue ring (bottom)
					_k(180.0, 60.0, 149.0),  # Orange hook
					_k(120.0, 62.0, 149.0),  # Green hook
				]),
			])
			hub["locks"] = [[0, 1], [3, 4]]
			return hub
		52:
			# Flower pattern - central circle with 6 radiating branches
			return _closed(68.0, C, [
				_k(-90.0, 56.0, 132.0, [  # Blue ring (top)
					_k(-120.0, 58.0, 149.0),  # Green hook (left)
					_k(-60.0, 60.0, 149.0),  # Green hook (right)
				]),
				_k(-30.0, 62.0, 132.0, [  # Orange ring (top-right)
					_k(0.0, 56.0, 149.0, [  # Purple hook
						_k(30.0, 58.0, 136.0),  # Green leaf with cuff
					]),
				]),
				_k(30.0, 58.0, 132.0, [  # Green ring (right)
					_k(60.0, 60.0, 149.0),  # Red hook with cuff
				]),
				_k(90.0, 62.0, 132.0, [  # Blue ring (bottom-right)
					_k(120.0, 56.0, 149.0),  # Orange hook
				]),
				_k(150.0, 60.0, 132.0, [  # Purple ring (bottom-left)
					_k(180.0, 58.0, 149.0, [  # Orange hook
						_k(210.0, 62.0, 136.0),  # Purple leaf with cuff
					]),
				]),
				_k(210.0, 58.0, 132.0, [  # Blue ring (left)
					_k(240.0, 60.0, 149.0),  # Red hook
				]),
			])
		53:
			# Organic scatter pattern with multiple cuffed rings
			return _closed(66.0, O, [
				_k(-150.0, 58.0, 132.0, [  # Green circle (top-left)
					_k(-180.0, 62.0, 149.0),  # Red hook with cuff
					_k(-120.0, 60.0, 149.0, [  # Blue hook
						_k(-90.0, 56.0, 136.0),  # Purple leaf
					]),
				]),
				_k(-60.0, 60.0, 132.0, [  # Purple ring (top)
					_k(-30.0, 58.0, 149.0),  # Purple hook
				]),
				_k(0.0, 64.0, 132.0, [  # Blue ring (top-right)
					_k(30.0, 56.0, 149.0, [  # Green hook
						_k(60.0, 62.0, 136.0),  # Red leaf
					]),
				]),
				_k(90.0, 58.0, 132.0, [  # Purple ring (bottom-right)
					_k(120.0, 60.0, 149.0),  # Blue hook
				]),
				_k(180.0, 62.0, 132.0, [  # Blue circle (left) with cuff
					_k(210.0, 56.0, 149.0, [  # Green hook with cuff
						_k(240.0, 58.0, 136.0),  # Green leaf
					]),
					_k(150.0, 60.0, 149.0),  # Red hook
				]),
			])
		54:
			# Diamond grid with square bridges
			var hub := _closed(64.0, O, [
				_k(-135.0, 58.0, 132.0, [  # Green ring (top-left)
					_k(-180.0, 60.0, 149.0),  # Orange hook
					_k(-90.0, 56.0, 149.0),   # Blue hook
				]),
				_k(-45.0, 62.0, 132.0, [  # Green ring (top-right) with cuff
					_k(0.0, 58.0, 149.0),    # Blue hook
					_k(90.0, 60.0, 149.0),   # Orange hook
				]),
				_k(45.0, 60.0, 132.0, [  # Green ring (right)
					_k(90.0, 58.0, 149.0),  # Blue hook
				]),
				_k(135.0, 56.0, 132.0, [  # Blue ring (bottom-right) with cuff
					_k(180.0, 60.0, 149.0, [  # Orange hook
						_k(225.0, 58.0, 136.0),  # Green leaf
					]),
				]),
				_k(225.0, 58.0, 132.0, [  # Purple ring (left)
					_k(270.0, 60.0, 149.0),  # Purple hook
				]),
			])
			hub["locks"] = [[0, 1], [2, 3]]
			return hub
		55:
			# Woven paths crossing at center
			return _closed(68.0, C, [
				_k(-135.0, 60.0, 132.0, [  # Blue ring (top-left)
					_k(-180.0, 58.0, 149.0),  # Green hook
					_k(-90.0, 62.0, 149.0),   # Blue hook
				]),
				_k(-45.0, 56.0, 132.0, [  # Purple ring (top)
					_k(-45.0, 60.0, 149.0, [  # Purple hook
						_k(0.0, 58.0, 136.0, [  # Green hook with cuff
							_k(45.0, 62.0, 153.0),  # Orange tail with cuff
						]),
					]),
				]),
				_k(45.0, 64.0, 132.0, [  # Green ring (right) with cuff
					_k(90.0, 56.0, 149.0, [  # Blue hook with cuff
						_k(135.0, 60.0, 136.0),  # Orange leaf
					]),
				]),
				_k(135.0, 58.0, 132.0, [  # Purple ring (bottom-right)
					_k(180.0, 62.0, 149.0, [  # Red hook with cuff
						_k(225.0, 56.0, 136.0),  # Blue leaf
					]),
				]),
				_k(225.0, 60.0, 132.0, [  # Blue ring (bottom-left)
					_k(270.0, 58.0, 149.0, [  # Red hook
						_k(315.0, 62.0, 136.0),  # Green leaf
					]),
				]),
			])
		56:
			# Cyan square frame on right with internal structure
			var cyan_square_internals: Array = []
			cyan_square_internals.append([180.0, _leaf(52.0, 135.0)])  # Red ring with gap bottom
			cyan_square_internals.append([90.0, _leaf(48.0, 145.0)])  # Blue ring right
			var cyan_square := _n(68.0, S, 0, 0.0, 0, cyan_square_internals)
			cyan_square["locks"] = [[0, 1]]

			# Green closed circle hub bottom-right with branches
			var green_hub_kids: Array = []
			green_hub_kids.append([-140.0, _leaf(54.0, 140.0)])  # Blue ring
			green_hub_kids.append([-50.0, _n(58.0, C, 0, 0.0, 0, [  # Orange closed
				[80.0, _leaf(52.0, 150.0)]  # Orange L
			])])
			green_hub_kids.append([40.0, _leaf(50.0, 135.0)])  # Green ring
			var green_hub := _n(64.0, C, 0, 0.0, 0, green_hub_kids)
			green_hub["locks"] = [[0, 1]]

			# Orange closed circle middle-left area
			var orange_hub := _n(62.0, C, 0, 0.0, 0, [
				[-90.0, _leaf(54.0, 145.0)],  # Cyan ring
				[30.0, _leaf(52.0, 140.0)]  # Orange ring
			])

			# Central blue closed circle connects everything
			var kids: Array = []
			kids.append([-135.0, _leaf(56.0, 140.0)])  # Red L-bar top-left
			kids.append([-75.0, _n(54.0, C, 1, 145.0, 0, [  # Purple ring
				[85.0, _leaf(52.0, 135.0)]  # Cyan ring
			])])
			kids.append([10.0, cyan_square])  # Cyan square structure
			kids.append([75.0, _leaf(50.0, 150.0)])  # Red ring with gap
			kids.append([135.0, green_hub])  # Green hub
			kids.append([-160.0, _n(56.0, C, 1, 140.0, 0, [  # Purple ring
				[-95.0, _leaf(54.0, 145.0)]  # Green bar
			])])

			var root := _n(72.0, C, 0, 0.0, 0, kids)
			root["locks"] = [[1, 2]]
			return root
		57:
			# Purple square at top
			var purple_square := _n(66.0, S, 0, 0.0, 0, [
				[-150.0, _leaf(52.0, 140.0)],  # Purple piece
				[30.0, _n(56.0, C, 1, 145.0, 0, [  # Red ring
					[70.0, _leaf(50.0, 135.0)]  # Green piece
				])]
			])

			# Green hub middle with connections
			var green_hub := _n(68.0, C, 0, 0.0, 0, [
				[-100.0, purple_square],
				[-30.0, _n(58.0, C, 1, 140.0, 0, [
					[80.0, _leaf(54.0, 145.0)]  # Cyan
				])],
				[40.0, _n(56.0, C, 1, 150.0, 0, [
					[75.0, _leaf(52.0, 135.0)]  # Blue
				])],
				[100.0, _leaf(54.0, 145.0)]  # Green bar
			])

			# Orange closed circle bottom
			var orange_hub := _n(70.0, C, 0, 0.0, 0, [
				[-130.0, _leaf(56.0, 145.0)],  # Blue
				[-40.0, _leaf(58.0, 140.0)],  # Orange
				[50.0, _n(60.0, C, 1, 150.0, 0, [
					[85.0, _leaf(54.0, 135.0)]  # Orange L
				])]
			])

			var root := _n(64.0, C, 1, 135.0, 0, [
				[-110.0, green_hub],
				[130.0, orange_hub]
			])
			root["locks"] = [[0, 1]]
			return root
		58:
			# Top chain with green rings
			var top_left := _n(60.0, C, 1, 145.0, 0, [
				[-85.0, _n(56.0, C, 1, 140.0, 0, [
					[-75.0, _leaf(52.0, 135.0)]
				])]
			])

			# Red square frame area
			var red_square := _n(66.0, S, 0, 0.0, 0, [
				[0.0, _leaf(54.0, 145.0)],
				[90.0, _leaf(52.0, 140.0)]
			])

			# Orange closed hub middle
			var orange_hub := _n(66.0, C, 0, 0.0, 0, [
				[-120.0, top_left],
				[-30.0, red_square],
				[60.0, _n(58.0, C, 1, 150.0, 0, [
					[80.0, _leaf(54.0, 140.0)]
				])]
			])

			# Bottom complex structure
			var bottom_left := _n(64.0, C, 1, 145.0, 0, [
				[-115.0, _n(60.0, C, 1, 150.0, 0, [
					[-80.0, _leaf(56.0, 135.0)]
				])]
			])

			var bottom_right := _n(62.0, C, 1, 140.0, 0, [
				[95.0, _n(60.0, C, 1, 145.0, 0, [
					[85.0, _n(68.0, S, 0, 0.0, 0, [
						[0.0, _leaf(54.0, 150.0)],
						[90.0, _leaf(52.0, 135.0)]
					])]
				])]
			])

			var root := _n(68.0, C, 1, 130.0, 0, [
				[-95.0, orange_hub],
				[-155.0, bottom_left],
				[40.0, bottom_right]
			])
			root["locks"] = [[0, 1], [1, 2]]
			return root
		59:
			var angles: Array[float] = [-90.0, -54.0, -18.0, 18.0, 54.0, 90.0, 126.0, 162.0, 198.0, 234.0, 270.0, 306.0, 342.0]
			var kids: Array = []

			# Create radial pattern with varying radii
			for i in angles.size():
				var radius := 58.0 if i % 2 == 0 else 56.0
				var turn := 130.0 + float(i * 6)

				# Inner and outer layers
				if i % 4 == 0:
					# Outer ring with connection
					kids.append([angles[i], _n(radius, C, 1, turn, 0, [
						[75.0, _leaf(50.0, turn + 20.0)]
					])])
				elif i % 3 == 1:
					# Middle ring
					kids.append([angles[i], _n(radius + 2.0, C, 1, turn, 0, [
						[80.0, _leaf(52.0, turn + 15.0)]
					])])
				else:
					# Simple leaf
					kids.append([angles[i], _leaf(radius - 2.0, turn)])

			var root := _n(75.0, C, 0, 0.0, 0, kids)
			root["locks"] = [[0, 1], [2, 3], [4, 5], [6, 7], [8, 9]]
			return root
		60:
			# Nested rectangles (innermost to outermost)
			var green_inner := _n(42.0, S, 0, 0.0, 0, [])
			var red_mid := _n(50.0, S, 0, 0.0, 0, [[0.0, green_inner]])
			var blue_outer1 := _n(58.0, S, 0, 0.0, 0, [[0.0, red_mid]])
			var purple_outer2 := _n(66.0, S, 0, 0.0, 0, [[0.0, blue_outer1]])
			var orange_outermost := _n(74.0, S, 0, 0.0, 0, [[0.0, purple_outer2]])

			# Top-right diamond cluster
			var diamond_kids: Array = []
			diamond_kids.append([45.0, _leaf(38.0, 135.0)])  # Red
			diamond_kids.append([135.0, _leaf(36.0, 140.0)])  # Purple
			diamond_kids.append([225.0, _leaf(38.0, 145.0)])  # Green
			diamond_kids.append([315.0, _leaf(36.0, 150.0)])  # Blue
			var diamond := _n(44.0, S, 0, 45.0, 0, diamond_kids)  # Rotated square

			# Left green circle
			var left_circle := _n(52.0, C, 0, 0.0, 0, [
				[90.0, _leaf(44.0, 135.0)]
			])

			# Bottom circles
			var bottom_heart_left := _n(46.0, C, 0, 0.0, 0, [])  # Green/blue
			var bottom_heart_mid := _n(50.0, C, 0, 0.0, 0, [
				[0.0, _leaf(40.0, 135.0)],
				[120.0, _leaf(42.0, 140.0)]
			])
			var bottom_heart_right := _n(48.0, C, 0, 0.0, 0, [])  # Orange/cyan

			# T-shape at bottom
			var t_vertical := _n(56.0, T, 0, 0.0, 0, [
				[0.0, _leaf(44.0, 145.0)],
				[180.0, _leaf(46.0, 140.0)]
			])

			# Virtual root to coordinate positions
			var root := _n(2.0, C, 1, 90.0, 0, [
				[0.0, orange_outermost],  # Center
				[50.0, diamond],  # Top-right
				[180.0, left_circle],  # Left
				[250.0, bottom_heart_left],  # Bottom-left
				[270.0, bottom_heart_mid],  # Bottom-center
				[290.0, bottom_heart_right],  # Bottom-right
				[270.0, t_vertical]  # Bottom T
			])

			root["locks"] = []
			return root
		61:
			# Top section
			var top_branch := _n(60.0, C, 1, 145.0, 0, [
				[-105.0, _leaf(56.0, 140.0)],  # Blue
				[-25.0, _n(62.0, C, 0, 0.0, 0, [  # Orange hub
					[55.0, _leaf(54.0, 135.0)]
				])],
				[45.0, _leaf(58.0, 150.0)]  # Purple
			])

			# Middle red hub
			var middle_hub := _n(64.0, C, 0, 0.0, 0, [
				[-95.0, top_branch],
				[-35.0, _n(60.0, C, 1, 140.0, 0, [
					[80.0, _leaf(56.0, 145.0)]  # Cyan
				])],
				[25.0, _n(62.0, C, 1, 135.0, 0, [
					[85.0, _leaf(58.0, 140.0)]  # Blue
				])]
			])

			# Bottom green hub
			var bottom_hub := _n(66.0, C, 0, 0.0, 0, [
				[-125.0, _n(58.0, C, 1, 150.0, 0, [
					[-80.0, _leaf(54.0, 135.0)]  # Green
				])],
				[-5.0, _n(60.0, C, 1, 145.0, 0, [
					[75.0, _leaf(56.0, 140.0)]  # Cyan
				])],
				[115.0, _n(62.0, C, 1, 140.0, 0, [
					[80.0, _leaf(58.0, 145.0)]  # Orange
				])]
			])

			var root := _n(68.0, C, 1, 130.0, 0, [
				[-115.0, middle_hub],
				[65.0, _n(60.0, C, 1, 145.0, 0, [
					[-35.0, _leaf(56.0, 140.0)]
				])],
				[135.0, bottom_hub]
			])
			root["locks"] = [[0, 1]]
			return root
		62:
			# Top purple square structure
			var purple_square := _n(68.0, S, 0, 0.0, 0, [
				[-120.0, _n(58.0, C, 1, 140.0, 0, [
					[-85.0, _leaf(54.0, 135.0)]
				])],
				[0.0, _n(60.0, C, 1, 145.0, 0, [
					[80.0, _leaf(56.0, 150.0)]
				])]
			])
			purple_square["locks"] = [[0, 1]]

			# Middle section with green hub
			var green_hub := _n(62.0, C, 0, 0.0, 0, [
				[-90.0, _leaf(56.0, 145.0)],  # Horizontal green bar
				[0.0, _n(60.0, C, 1, 140.0, 0, [
					[75.0, _leaf(54.0, 135.0)]
				])],
				[90.0, _n(64.0, S, 0, 0.0, 0, [  # Blue square
					[0.0, _leaf(52.0, 150.0)]
				])]
			])

			# Right orange branch
			var orange_chain := _n(58.0, C, 1, 150.0, 0, [
				[90.0, _n(68.0, S, 0, 0.0, 0, [  # Purple square
					[45.0, _leaf(54.0, 140.0)]
				])]
			])

			# Bottom cluster
			var bottom_hub := _n(66.0, C, 0, 0.0, 0, [
				[-135.0, _n(60.0, C, 1, 145.0, 0, [
					[-80.0, _leaf(56.0, 135.0)]
				])],
				[-45.0, _n(62.0, C, 0, 0.0, 0, [
					[70.0, _leaf(54.0, 140.0)]
				])],
				[45.0, _n(58.0, C, 1, 150.0, 0, [
					[85.0, _leaf(52.0, 145.0)]
				])]
			])
			bottom_hub["locks"] = [[0, 1], [1, 2]]

			var root := _n(70.0, C, 1, 130.0, 0, [
				[-100.0, purple_square],
				[-20.0, green_hub],
				[60.0, orange_chain],
				[140.0, bottom_hub]
			])
			root["locks"] = [[1, 2]]
			return root
		63:
			# Top section - orange and red curves
			var top_orange := _n(62.0, C, 1, 145.0, 0, [
				[-95.0, _leaf(56.0, 140.0)]  # Orange top
			])
			var top_red := _n(60.0, C, 1, 140.0, 0, [
				[-85.0, top_orange]
			])

			# Middle vertical cyan bar with purple branch
			var cyan_vertical := _n(58.0, C, 1, 90.0, 0, [
				[-90.0, _n(64.0, T, 0, 0.0, 0, [  # Purple T-junction
					[-90.0, _leaf(54.0, 145.0)],  # Green horizontal
					[0.0, top_red]  # Connect upward
				])],
				[0.0, _n(66.0, C, 0, 0.0, 0, [  # Green hub
					[-90.0, _n(60.0, S, 0, 0.0, 0, [  # Orange square
						[-90.0, _leaf(52.0, 135.0)]  # Green bar
					])],
					[90.0, _leaf(56.0, 140.0)]  # Cyan elbow
				])]
			])

			# Right blue bar
			var blue_vertical := _n(56.0, C, 1, 90.0, 0, [
				[90.0, _leaf(54.0, 145.0)]  # Horizontal piece
			])

			# Bottom horizontal chain
			var bottom_chain := _n(68.0, C, 0, 0.0, 0, [  # Green circle
				[-180.0, _n(62.0, C, 1, 150.0, 0, [
					[-90.0, _leaf(56.0, 135.0)]  # Red
				])],
				[0.0, _n(60.0, C, 1, 145.0, 0, [
					[90.0, _leaf(54.0, 140.0)]  # Blue
				])]
			])
			bottom_chain["locks"] = [[0, 1]]

			# Left green L-bar
			var left_green := _n(58.0, C, 1, 180.0, 0, [
				[-90.0, _leaf(54.0, 145.0)]
			])

			var root := _n(4.0, C, 1, 0.0, 0, [  # Virtual center
				[90.0, cyan_vertical],  # Main vertical
				[0.0, blue_vertical],  # Right vertical
				[270.0, bottom_chain],  # Bottom
				[180.0, left_green]  # Left
			])

			return root
		64:
			# Innermost cyan circle with gap
			var inner_cyan := _n(48.0, C, 1, 135.0, 0, [])

			# Orange ring around cyan
			var mid_orange := _n(56.0, C, 0, 0.0, 0, [
				[90.0, inner_cyan]
			])

			# Purple ring around orange
			var outer_purple := _n(64.0, C, 0, 0.0, 0, [
				[90.0, mid_orange],
				[-90.0, _leaf(52.0, 145.0)]  # Purple T at top
			])

			# Red outermost ring
			var outermost_red := _n(72.0, C, 0, 0.0, 0, [
				[90.0, outer_purple],
				[180.0, _leaf(54.0, 140.0)]  # Red T at bottom
			])

			# Bottom green square frame with purple center
			var bottom_frame := _n(62.0, S, 0, 0.0, 0, [
				[0.0, _n(52.0, C, 0, 0.0, 0, [  # Purple center bar
					[0.0, _leaf(44.0, 145.0)]
				])]
			])
			bottom_frame["locks"] = [[0]]

			# Attached to bottom frame
			var bottom_structure := _n(66.0, C, 0, 0.0, 0, [  # Orange circle
				[-90.0, bottom_frame],
				[-150.0, _leaf(56.0, 140.0)],  # Green curve
				[-30.0, _leaf(54.0, 145.0)],  # Green curve  
				[30.0, _n(60.0, C, 1, 150.0, 0, [  # Red curve
					[80.0, _leaf(52.0, 135.0)]  # Cyan bar
				])],
				[90.0, _leaf(56.0, 140.0)]  # Green piece
			])
			bottom_structure["locks"] = [[1, 2]]

			# Connect all parts
			var root := _n(2.0, C, 0, 0.0, 0, [
				[0.0, outermost_red],  # Central concentric circles
				[180.0, bottom_structure]  # Bottom structure
			])

			return root
		65:
			# Top section - green bars and blue connections
			var top_left_green := _n(58.0, S, 0, 0.0, 0, [
				[90.0, _leaf(54.0, 145.0)]
			])

			var top_mid_green := _n(60.0, C, 1, 140.0, 0, [
				[85.0, _n(62.0, C, 1, 145.0, 0, [
					[80.0, _leaf(56.0, 135.0)]  # Blue ring
				])]
			])

			# Middle-left section with cyan square
			var cyan_square_complex := _n(66.0, S, 0, 0.0, 0, [
				[-90.0, _n(58.0, C, 1, 150.0, 0, [
					[-85.0, _leaf(54.0, 140.0)]  # Blue
				])],
				[90.0, _leaf(56.0, 145.0)]  # Cyan bar
			])

			# Central cluster with closed rings
			var purple_hub := _n(60.0, C, 0, 0.0, 0, [
				[-120.0, _leaf(54.0, 140.0)],  # Purple piece
				[0.0, _leaf(56.0, 145.0)]  # Cyan bar
			])

			var red_hub := _n(68.0, C, 0, 0.0, 0, [
				[-90.0, cyan_square_complex],
				[0.0, purple_hub],
				[90.0, _n(62.0, C, 1, 150.0, 0, [
					[80.0, _leaf(58.0, 135.0)]  # Green
				])]
			])
			red_hub["locks"] = [[1, 2]]

			# Right side structures
			var right_structure := _n(64.0, C, 1, 145.0, 0, [
				[85.0, _n(70.0, S, 0, 0.0, 0, [  # Red bar frame
					[0.0, _leaf(54.0, 140.0)]
				])]
			])

			# Bottom section
			var bottom_purple := _n(62.0, C, 1, 150.0, 0, [
				[-95.0, _n(60.0, C, 1, 145.0, 0, [
					[-80.0, _leaf(56.0, 135.0)]
				])],
				[85.0, _n(66.0, C, 1, 140.0, 0, [
					[90.0, _n(64.0, C, 1, 145.0, 0, [
						[75.0, _leaf(58.0, 135.0)]
					])]
				])]
			])

			# Assemble
			var root := _n(2.0, C, 1, 0.0, 0, [
				[-120.0, top_left_green],
				[-60.0, top_mid_green],
				[0.0, red_hub],
				[60.0, right_structure],
				[150.0, bottom_purple]
			])

			return root
		66:
			# Top purple square with vertical bar
			var purple_top := _n(68.0, S, 0, 0.0, 0, [
				[0.0, _n(58.0, C, 1, 90.0, 0, [  # Vertical bar
					[-90.0, _leaf(54.0, 145.0)]  # Horizontal top
				])]
			])

			# Left orange curve
			var orange_left := _n(62.0, C, 1, 140.0, 0, [
				[-95.0, _leaf(56.0, 135.0)]  # Green branch
			])

			# Central green hub complex
			var green_hub := _n(70.0, C, 0, 0.0, 0, [
				[-150.0, orange_left],
				[-90.0, purple_top],
				[-30.0, _n(60.0, C, 1, 145.0, 0, [  # Purple ring
					[80.0, _leaf(56.0, 140.0)]  # Green ring
				])],
				[30.0, _n(58.0, C, 1, 150.0, 0, [  # Blue vertical
					[90.0, _leaf(54.0, 135.0)]  # Green ring
				])],
				[90.0, _leaf(56.0, 145.0)]  # Green vertical bar
			])
			green_hub["locks"] = [[2, 3]]

			# Bottom left red hub
			var red_hub := _n(66.0, C, 0, 0.0, 0, [
				[-90.0, _n(62.0, S, 0, 0.0, 0, [  # Purple square
					[-90.0, _leaf(54.0, 140.0)]
				])],
				[0.0, _n(60.0, C, 1, 145.0, 0, [
					[85.0, _leaf(56.0, 135.0)]  # Blue ring
				])]
			])
			red_hub["locks"] = [[0, 1]]

			# Bottom right blue/cyan hub
			var blue_hub := _n(68.0, C, 0, 0.0, 0, [
				[-180.0, _n(58.0, C, 1, 150.0, 0, [
					[-85.0, _leaf(54.0, 140.0)]  # Cyan
				])],
				[-90.0, _leaf(56.0, 145.0)],  # Orange piece
				[0.0, _leaf(54.0, 135.0)]  # Cyan piece
			])
			blue_hub["locks"] = [[1, 2]]

			# Bottom structures with bars
			var bottom_cyan := _n(64.0, C, 1, 180.0, 0, [
				[-90.0, _leaf(56.0, 145.0)]  # Cyan bar
			])

			var bottom_red := _n(62.0, S, 0, 0.0, 0, [
				[0.0, _leaf(54.0, 140.0)]  # Red bar
			])

			var root := _n(4.0, C, 1, 0.0, 0, [
				[0.0, green_hub],  # Central hub
				[-150.0, red_hub],  # Bottom-left
				[150.0, blue_hub],  # Bottom-right
				[180.0, bottom_cyan],  # Bottom cyan bar
				[200.0, bottom_red]  # Bottom red bar
			])

			return root
		67:
			# Top long purple bar with connections
			var purple_top := _n(58.0, C, 1, 180.0, 0, [
				[-90.0, _n(62.0, C, 1, 145.0, 0, [  # Purple curve
					[-85.0, _leaf(56.0, 140.0)]  # Orange branch
				])],
				[0.0, _leaf(54.0, 150.0)],  # Horizontal bar center
				[90.0, _n(60.0, C, 1, 135.0, 0, [  # Green curve
					[80.0, _leaf(56.0, 145.0)]  # Right piece
				])]
			])
			purple_top["locks"] = [[0, 2]]

			# Middle orange closed hub
			var orange_hub := _n(66.0, C, 0, 0.0, 0, [
				[-90.0, _n(60.0, C, 1, 145.0, 0, [  # Red curve
					[-85.0, _leaf(56.0, 140.0)]  # Cyan
				])],
				[0.0, _leaf(54.0, 135.0)],  # Orange piece bottom
				[90.0, _n(64.0, C, 0, 0.0, 0, [  # Blue circle
					[90.0, _leaf(58.0, 150.0)]  # Right extension
				])]
			])
			orange_hub["locks"] = [[0, 2]]

			# Left vertical structures
			var left_cyan := _n(62.0, C, 1, 140.0, 0, [
				[-90.0, _leaf(56.0, 145.0)]  # Red top
			])

			var left_green := _n(60.0, C, 1, 180.0, 0, [
				[-90.0, _leaf(54.0, 135.0)]  # Cyan bar
			])

			# Bottom section with three green hubs
			var bottom_left_green := _n(58.0, C, 1, 145.0, 0, [
				[-85.0, _leaf(54.0, 140.0)]  # Green piece
			])

			var bottom_mid_green := _n(64.0, C, 0, 0.0, 0, [
				[-120.0, bottom_left_green],
				[0.0, _leaf(56.0, 150.0)],  # Cyan
				[120.0, _leaf(58.0, 135.0)]  # Green
			])

			var bottom_right := _n(60.0, C, 1, 140.0, 0, [
				[85.0, _n(62.0, C, 1, 145.0, 0, [
					[80.0, _leaf(56.0, 135.0)]  # Cyan
				])]
			])

			# Purple circle at bottom
			var purple_bottom := _n(66.0, C, 1, 150.0, 0, [])

			var root := _n(4.0, C, 1, 0.0, 0, [
				[0.0, purple_top],  # Top bar
				[45.0, orange_hub],  # Middle orange
				[-150.0, left_cyan],  # Left structures
				[-120.0, left_green],
				[180.0, bottom_mid_green],  # Bottom
				[150.0, bottom_right],
				[200.0, purple_bottom]
			])

			return root
		68:
			# Top section with orange and green pieces
			var top_orange := _n(60.0, C, 1, 145.0, 0, [
				[-95.0, _leaf(56.0, 140.0)]  # Orange L extension
			])

			var top_green := _n(62.0, C, 1, 140.0, 0, [
				[85.0, _n(64.0, C, 1, 145.0, 0, [  # Blue
					[80.0, _n(68.0, S, 0, 0.0, 0, [  # Orange square
						[45.0, _leaf(54.0, 135.0)]
					])]
				])]
			])

			# Middle section with cyan circle and purple square
			var cyan_mid := _n(66.0, C, 1, 150.0, 0, [
				[-85.0, _leaf(58.0, 140.0)]  # Green
			])

			var purple_square := _n(70.0, S, 0, 0.0, 0, [
				[-90.0, top_orange],
				[-30.0, top_green],
				[30.0, cyan_mid],
				[90.0, _n(60.0, C, 1, 145.0, 0, [  # Blue T
					[80.0, _leaf(56.0, 135.0)]
				])]
			])
			purple_square["locks"] = [[1, 2]]

			# Orange and red closed circles middle-left
			var orange_hub := _n(68.0, C, 0, 0.0, 0, [
				[-120.0, _leaf(58.0, 140.0)],  # Red curve
				[0.0, _n(64.0, C, 0, 0.0, 0, [  # Orange inner
					[90.0, _leaf(56.0, 145.0)]
				])]
			])
			orange_hub["locks"] = [[0, 1]]

			# Bottom complex structures
			var bottom_left_purple := _n(62.0, C, 1, 150.0, 0, [
				[-90.0, _leaf(58.0, 135.0)]
			])

			var bottom_green_square := _n(66.0, S, 0, 0.0, 0, [
				[-90.0, _n(60.0, C, 1, 145.0, 0, [
					[-85.0, _leaf(56.0, 140.0)]
				])],
				[90.0, _leaf(54.0, 135.0)]
			])

			var bottom_red := _n(64.0, C, 1, 140.0, 0, [
				[85.0, _n(62.0, C, 1, 145.0, 0, [
					[80.0, _leaf(58.0, 135.0)]  # Cyan
				])]
			])

			var root := _n(4.0, C, 1, 0.0, 0, [
				[30.0, purple_square],  # Top-middle
				[-120.0, orange_hub],  # Middle-left
				[-150.0, bottom_left_purple],  # Bottom-left
				[180.0, bottom_green_square],  # Bottom
				[150.0, bottom_red]  # Bottom-right
			])

			return root
		69:
			# Top row of rings
			var top_cyan := _n(58.0, C, 1, 145.0, 0, [
				[-85.0, _n(60.0, C, 1, 140.0, 0, [  # Green
					[-80.0, _leaf(56.0, 135.0)]  # Blue with marker
				])]
			])

			var top_green := _n(62.0, C, 1, 140.0, 0, [])

			# Middle-left orange cluster
			var orange_mid := _n(64.0, C, 1, 150.0, 0, [
				[-95.0, _n(60.0, C, 1, 145.0, 0, [
					[-85.0, _leaf(56.0, 135.0)]  # Orange L
				])]
			])

			# Middle section with blue T and purple/red connections
			var blue_t := _n(66.0, T, 0, 0.0, 0, [
				[0.0, _n(58.0, C, 1, 140.0, 0, [
					[80.0, _leaf(54.0, 145.0)]  # Green
				])],
				[90.0, _leaf(56.0, 135.0)],  # Horizontal right
				[-90.0, _leaf(58.0, 140.0)]  # Horizontal left
			])

			var purple_mid := _n(62.0, C, 1, 145.0, 0, [
				[85.0, _n(64.0, C, 1, 150.0, 0, [  # Red
					[80.0, _leaf(60.0, 135.0)]  # Green
				])]
			])

			# Right side structures
			var green_right := _n(60.0, C, 1, 140.0, 0, [
				[90.0, _n(66.0, S, 0, 0.0, 0, [  # Red bar
					[0.0, _leaf(54.0, 145.0)]
				])]
			])

			# Bottom cluster
			var bottom_blue := _n(68.0, C, 1, 150.0, 0, [
				[-90.0, _n(62.0, C, 1, 145.0, 0, [  # Green
					[-85.0, _n(64.0, C, 1, 140.0, 0, [  # Cyan
						[-80.0, _n(60.0, C, 1, 145.0, 0, [  # Orange with marker
							[-75.0, _leaf(56.0, 135.0)]
						])]
					])]
				])]
			])

			var bottom_orange := _n(66.0, C, 1, 135.0, 0, [
				[80.0, _leaf(58.0, 140.0)]  # Orange L
			])

			var root := _n(4.0, C, 1, 0.0, 0, [
				[-120.0, top_cyan],
				[-60.0, top_green],
				[-150.0, orange_mid],
				[-30.0, blue_t],
				[30.0, purple_mid],
				[90.0, green_right],
				[160.0, bottom_blue],
				[200.0, bottom_orange]
			])

			return root
		70:
			# Top "head" - two curved pieces
			var top_green := _n(56.0, C, 1, 145.0, 0, [])
			var top_red := _n(58.0, C, 1, 140.0, 0, [])

			# Upper body - green/cyan rectangle
			var upper_rect := _n(64.0, S, 0, 0.0, 0, [
				[-90.0, top_green],
				[90.0, top_red],
				[0.0, _leaf(52.0, 135.0)]  # Cyan bar inside
			])
			upper_rect["locks"] = [[0, 1]]

			# Middle "shoulders" - orange and cyan curves
			var left_shoulder := _n(60.0, C, 1, 150.0, 0, [])  # Cyan
			var right_shoulder := _n(62.0, C, 1, 145.0, 0, [])  # Orange

			# Center body - large green/purple curves with yellow markers
			var left_body := _n(70.0, C, 1, 140.0, 0, [])  # Orange curve
			var right_body := _n(72.0, C, 1, 135.0, 0, [])  # Purple curve

			# Lower rectangles - green and blue
			var lower_green := _n(66.0, S, 0, 0.0, 0, [
				[0.0, _leaf(54.0, 145.0)]  # Green bar inside
			])
			var lower_blue := _n(68.0, S, 0, 0.0, 0, [
				[0.0, _leaf(56.0, 140.0)]  # Cyan bar inside
			])

			# Bottom "legs" - purple triangle with complex connections
			var leg_structure := _n(74.0, T, 0, 180.0, 0, [  # Purple triangle inverted
				[-120.0, _n(58.0, C, 1, 150.0, 0, [
					[-85.0, _leaf(54.0, 135.0)]  # Purple
				])],
				[-60.0, _n(60.0, C, 1, 145.0, 0, [
					[-80.0, _leaf(56.0, 140.0)]  # Red
				])],
				[0.0, _n(62.0, C, 1, 140.0, 0, [
					[80.0, _n(58.0, C, 1, 145.0, 0, [  # Green
						[75.0, _leaf(54.0, 135.0)]
					])]
				])],
				[60.0, _leaf(56.0, 150.0)],  # Purple piece
				[120.0, _leaf(58.0, 135.0)]  # Green piece
			])
			leg_structure["locks"] = [[0, 1], [2, 3]]

			# Assemble robot shape
			var root := _n(4.0, C, 1, 0.0, 0, [
				[0.0, upper_rect],  # Head/upper
				[-150.0, left_shoulder],
				[150.0, right_shoulder],
				[-90.0, left_body],
				[90.0, right_body],
				[-30.0, lower_green],
				[30.0, lower_blue],
				[180.0, leg_structure]  # Legs
			])

			return root
		71:
			# Top-left structures
			var top_blue_L := _n(58.0, S, 0, 0.0, 0, [
				[-90.0, _leaf(54.0, 145.0)]  # Blue bar
			])

			var top_green := _n(60.0, C, 1, 140.0, 0, [
				[85.0, _n(66.0, C, 0, 0.0, 0, [  # Red circle
					[90.0, _leaf(56.0, 135.0)]  # Purple curve
				])]
			])

			# Top-right orange cluster
			var top_right := _n(62.0, C, 1, 150.0, 0, [
				[80.0, _n(64.0, C, 1, 145.0, 0, [  # Green
					[75.0, _leaf(58.0, 140.0)]  # Cyan
				])]
			])

			# Middle-left cyan and purple complex
			var cyan_hub := _n(68.0, C, 0, 0.0, 0, [
				[-120.0, _leaf(56.0, 145.0)],  # Purple
				[-30.0, _n(60.0, C, 1, 140.0, 0, [  # Orange
					[80.0, _leaf(54.0, 135.0)]  # Green
				])]
			])

			# Central green hub with multiple connections
			var green_hub := _n(70.0, C, 0, 0.0, 0, [
				[-150.0, top_green],
				[-90.0, _n(62.0, C, 1, 145.0, 0, [
					[-85.0, _leaf(58.0, 140.0)]  # Red
				])],
				[-30.0, _n(64.0, C, 1, 150.0, 0, [
					[80.0, _leaf(60.0, 135.0)]  # Blue
				])],
				[30.0, _leaf(56.0, 145.0)],  # Green curve
				[90.0, _n(58.0, C, 1, 140.0, 0, [
					[85.0, _leaf(54.0, 135.0)]  # Orange L
				])]
			])
			green_hub["locks"] = [[1, 2], [3, 4]]

			# Bottom structures
			var bottom_left_red := _n(66.0, C, 0, 0.0, 0, [
				[-90.0, _n(62.0, S, 0, 0.0, 0, [  # Blue square
					[-90.0, _n(58.0, C, 1, 145.0, 0, [
						[-85.0, _leaf(54.0, 140.0)]  # Orange bar
					])]
				])],
				[0.0, _leaf(56.0, 135.0)]  # Green T
			])
			bottom_left_red["locks"] = [[0, 1]]

			var bottom_right_blue := _n(64.0, C, 1, 150.0, 0, [
				[90.0, _n(68.0, S, 0, 0.0, 0, [  # Green bar
					[0.0, _leaf(56.0, 140.0)]
				])]
			])

			var root := _n(4.0, C, 1, 0.0, 0, [
				[-150.0, top_blue_L],
				[-60.0, top_green],
				[60.0, top_right],
				[-120.0, cyan_hub],
				[0.0, green_hub],
				[-180.0, bottom_left_red],
				[150.0, bottom_right_blue]
			])

			return root
		72:
			# Top three green rings with purple center
			var top_left := _n(60.0, C, 1, 145.0, 0, [])
			var top_center := _n(62.0, C, 1, 140.0, 0, [
				[-90.0, top_left],
				[0.0, _leaf(56.0, 135.0)],  # Purple center
				[90.0, _leaf(60.0, 145.0)]  # Right green
			])
			top_center["locks"] = [[0, 2]]

			# Upper level - green T with blue connections
			var upper_green := _n(66.0, T, 0, 0.0, 0, [
				[-90.0, _n(58.0, C, 1, 150.0, 0, [
					[-85.0, _leaf(54.0, 140.0)]  # Blue
				])],
				[90.0, _n(60.0, C, 1, 145.0, 0, [
					[85.0, _leaf(56.0, 135.0)]  # Orange
				])]
			])
			upper_green["locks"] = [[0, 1]]

			# Central orange circle
			var orange_center := _n(70.0, C, 0, 0.0, 0, [
				[-90.0, upper_green],
				[0.0, _leaf(58.0, 140.0)],  # Orange marker
				[90.0, top_center]
			])

			# Middle level - cyan T with connections
			var middle_cyan := _n(72.0, T, 0, 0.0, 0, [
				[-90.0, _n(62.0, C, 0, 0.0, 0, [  # Red circle
					[-90.0, _leaf(56.0, 145.0)]  # Red T
				])],
				[0.0, orange_center],
				[90.0, _n(64.0, C, 0, 0.0, 0, [  # Green circle
					[90.0, _leaf(58.0, 140.0)]  # Green T
				])]
			])
			middle_cyan["locks"] = [[0, 2]]

			# Lower level - purple circle with branches
			var purple_lower := _n(74.0, C, 0, 0.0, 0, [
				[-90.0, _n(60.0, C, 1, 150.0, 0, [
					[-85.0, _leaf(56.0, 135.0)]  # Orange
				])],
				[0.0, middle_cyan],
				[90.0, _n(62.0, C, 1, 145.0, 0, [
					[85.0, _leaf(58.0, 140.0)]  # Orange
				])]
			])
			purple_lower["locks"] = [[0, 2]]

			# Bottom level - three more rings
			var bottom_cyan := _n(66.0, C, 1, 140.0, 0, [])
			var bottom_red := _n(68.0, C, 1, 145.0, 0, [])
			var bottom_green := _n(64.0, C, 1, 135.0, 0, [])

			var root := _n(4.0, C, 1, 0.0, 0, [
				[0.0, purple_lower],  # Main vertical structure
				[-150.0, bottom_cyan],  # Bottom spread
				[180.0, bottom_red],
				[150.0, bottom_green]
			])

			return root
		73:
			# Top section
			var top_orange_L := _n(60.0, C, 1, 145.0, 0, [
				[-95.0, _leaf(56.0, 140.0)]  # Orange extension
			])

			var top_purple_hub := _n(66.0, C, 0, 0.0, 0, [
				[-120.0, top_orange_L],
				[-30.0, _n(62.0, C, 1, 150.0, 0, [  # Red curve
					[80.0, _leaf(58.0, 135.0)]
				])],
				[90.0, _n(64.0, C, 1, 145.0, 0, [  # Purple curve
					[85.0, _n(68.0, C, 1, 140.0, 0, [  # Orange with marker
						[80.0, _leaf(60.0, 135.0)]
					])]
				])]
			])
			top_purple_hub["locks"] = [[1, 2]]

			# Left side cyan L
			var left_cyan := _n(58.0, T, 0, 0.0, 0, [
				[-90.0, _leaf(54.0, 145.0)]  # Cyan bar
			])

			# Middle structures
			var mid_orange := _n(62.0, C, 1, 140.0, 0, [
				[85.0, _n(66.0, S, 0, 0.0, 0, [  # Blue square
					[0.0, _leaf(56.0, 135.0)]
				])]
			])

			var mid_green := _n(64.0, C, 1, 150.0, 0, [
				[-85.0, _leaf(58.0, 145.0)]
			])

			# Right and bottom structures
			var right_orange := _n(60.0, C, 1, 135.0, 0, [
				[90.0, _n(68.0, T, 0, 0.0, 0, [  # Blue T
					[90.0, _n(62.0, C, 1, 140.0, 0, [
						[85.0, _leaf(58.0, 145.0)]  # Cyan
					])]
				])]
			])

			var bottom_green := _n(66.0, C, 1, 145.0, 0, [])

			var bottom_blue := _n(70.0, C, 0, 0.0, 0, [
				[-120.0, _leaf(58.0, 140.0)],  # Green
				[0.0, _n(64.0, C, 1, 135.0, 0, [  # Red with marker
					[80.0, _leaf(60.0, 145.0)]
				])],
				[120.0, _n(62.0, C, 1, 150.0, 0, [  # Blue bar
					[85.0, _leaf(58.0, 140.0)]
				])]
			])
			bottom_blue["locks"] = [[0, 1]]

			var root := _n(4.0, C, 1, 0.0, 0, [
				[-60.0, top_purple_hub],
				[-150.0, left_cyan],
				[-30.0, mid_orange],
				[30.0, mid_green],
				[90.0, right_orange],
				[160.0, bottom_green],
				[200.0, bottom_blue]
			])

			return root
		74:
			# Top-left orange structures
			var top_left_square := _n(66.0, S, 0, 0.0, 0, [
				[-90.0, _n(60.0, C, 1, 145.0, 0, [
					[-85.0, _leaf(56.0, 140.0)]  # Purple
				])],
				[0.0, _leaf(54.0, 135.0)]  # Orange curve
			])
			top_left_square["locks"] = [[0, 1]]

			# Top-middle structures
			var top_red := _n(62.0, C, 1, 150.0, 0, [])

			var top_blue_hub := _n(68.0, C, 1, 145.0, 0, [
				[-85.0, _n(64.0, C, 1, 140.0, 0, [  # Purple
					[-80.0, _leaf(60.0, 135.0)]
				])]
			])

			# Top-right green structures
			var top_right_green := _n(58.0, C, 1, 135.0, 0, [])

			var top_right_blue := _n(70.0, S, 0, 0.0, 0, [
				[-90.0, _leaf(56.0, 145.0)],  # Green bar
				[90.0, _n(62.0, C, 1, 140.0, 0, [
					[85.0, _leaf(58.0, 135.0)]  # Green curve
				])]
			])

			# Middle-left structures
			var mid_left_blue := _n(64.0, C, 1, 150.0, 0, [
				[-90.0, _leaf(58.0, 145.0)]  # Blue bar
			])

			# Central green T junction
			var green_center := _n(72.0, T, 0, 0.0, 0, [
				[-90.0, top_left_square],
				[0.0, _n(66.0, C, 1, 140.0, 0, [  # Orange with marker
					[80.0, top_blue_hub]
				])],
				[90.0, _leaf(60.0, 135.0)]  # Green bar right
			])

			# Middle-right purple curve
			var mid_right := _n(60.0, C, 1, 145.0, 0, [
				[85.0, _leaf(56.0, 140.0)]  # Green curve
			])

			# Bottom-left complex
			var bottom_left_cyan := _n(68.0, C, 1, 135.0, 0, [
				[-90.0, _n(64.0, T, 0, 0.0, 0, [
					[-90.0, _leaf(58.0, 145.0)]
				])],
				[0.0, _n(62.0, C, 1, 140.0, 0, [
					[80.0, _leaf(58.0, 135.0)]  # Red
				])]
			])
			bottom_left_cyan["locks"] = [[0, 1]]

			# Bottom-right purple/cyan structure
			var bottom_right := _n(70.0, S, 0, 0.0, 0, [
				[-90.0, _n(66.0, C, 1, 150.0, 0, [  # Purple square
					[-85.0, _n(64.0, C, 1, 145.0, 0, [  # Cyan
						[-80.0, _leaf(60.0, 140.0)]  # Orange
					])]
				])],
				[90.0, _n(62.0, C, 1, 135.0, 0, [
					[85.0, _leaf(58.0, 145.0)]  # Blue
				])]
			])

			# Red bar at bottom
			var bottom_red := _n(58.0, S, 0, 0.0, 0, [
				[0.0, _leaf(54.0, 140.0)]
			])

			var root := _n(4.0, C, 1, 0.0, 0, [
				[-120.0, top_red],
				[-60.0, top_right_green],
				[0.0, green_center],
				[60.0, top_right_blue],
				[-150.0, mid_left_blue],
				[90.0, mid_right],
				[-180.0, bottom_left_cyan],
				[150.0, bottom_right],
				[200.0, bottom_red]
			])

			return root
		75:
			# Top-left green square frame
			var top_left_square := _n(68.0, S, 0, 0.0, 0, [
				[-90.0, _n(62.0, C, 1, 145.0, 0, [  # Cyan curve
					[-85.0, _n(66.0, C, 1, 140.0, 0, [  # Green curve
						[-80.0, _leaf(60.0, 135.0)]  # Blue curve
					])]
				])],
				[0.0, _leaf(58.0, 150.0)]  # Green bar inside
			])
			top_left_square["locks"] = [[0]]

			# Top-middle blue curve
			var top_mid_blue := _n(64.0, C, 1, 140.0, 0, [])

			# Top-right cyan curve
			var top_right_cyan := _n(60.0, C, 1, 145.0, 0, [
				[85.0, _n(58.0, C, 1, 150.0, 0, [  # Orange bar
					[80.0, _leaf(54.0, 135.0)]
				])]
			])

			# Middle-left structures
			var mid_left_orange := _n(62.0, C, 1, 135.0, 0, [])

			var mid_green_hub := _n(70.0, C, 0, 0.0, 0, [
				[-150.0, mid_left_orange],
				[-90.0, top_left_square],
				[-30.0, _n(66.0, C, 1, 140.0, 0, [
					[80.0, _leaf(62.0, 145.0)]  # Orange with marker
				])],
				[30.0, top_mid_blue],
				[90.0, _n(64.0, C, 1, 150.0, 0, [
					[85.0, _leaf(60.0, 135.0)]  # Cyan square
				])]
			])
			mid_green_hub["locks"] = [[2, 3]]

			# Middle-right structures
			var mid_right_orange := _n(68.0, C, 1, 145.0, 0, [
				[90.0, _n(72.0, S, 0, 0.0, 0, [  # Cyan square frame
					[0.0, _leaf(60.0, 140.0)]
				])]
			])

			# Bottom structures
			var bottom_purple := _n(66.0, C, 1, 140.0, 0, [
				[-90.0, _n(62.0, C, 1, 145.0, 0, [
					[-85.0, _leaf(58.0, 135.0)]  # Purple
				])]
			])

			var bottom_red := _n(64.0, C, 1, 150.0, 0, [])

			var bottom_green_square := _n(68.0, S, 0, 0.0, 0, [
				[-90.0, _n(60.0, C, 1, 135.0, 0, [
					[-85.0, _leaf(56.0, 140.0)]  # Green bar
				])],
				[0.0, _leaf(58.0, 145.0)]  # Red bar
			])

			var root := _n(4.0, C, 1, 0.0, 0, [
				[-90.0, mid_green_hub],  # Main hub
				[60.0, top_right_cyan],
				[120.0, mid_right_orange],
				[-160.0, bottom_purple],
				[-120.0, bottom_red],
				[180.0, bottom_green_square]
			])

			return root
		76:
			# Top-left structures
			var top_left_blue := _n(60.0, C, 1, 145.0, 0, [
				[-90.0, _n(62.0, C, 1, 140.0, 0, [  # Green
					[-85.0, _leaf(58.0, 135.0)]
				])]
			])

			# Top-middle structures
			var top_green := _n(64.0, C, 1, 150.0, 0, [
				[85.0, _n(66.0, C, 1, 145.0, 0, [  # Purple
					[80.0, _leaf(62.0, 140.0)]
				])]
			])

			# Top-right red circle with marker
			var top_right := _n(68.0, C, 1, 135.0, 0, [])

			# Middle-left structures
			var mid_left_purple := _n(58.0, C, 1, 140.0, 0, [
				[-90.0, _leaf(54.0, 145.0)]
			])

			# Central orange hub with marker
			var orange_hub := _n(70.0, C, 0, 0.0, 0, [
				[-150.0, mid_left_purple],
				[-90.0, _n(62.0, C, 1, 150.0, 0, [  # Purple
					[-85.0, _leaf(58.0, 135.0)]  # Red
				])],
				[-30.0, _n(66.0, C, 0, 0.0, 0, [  # Cyan circle
					[0.0, _leaf(60.0, 140.0)]  # Cyan curve
				])],
				[30.0, _n(64.0, C, 1, 145.0, 0, [  # Red
					[80.0, _leaf(62.0, 135.0)]  # Green
				])],
				[90.0, _n(68.0, C, 1, 140.0, 0, [  # Purple
					[85.0, _leaf(64.0, 145.0)]  # Green
				])]
			])
			orange_hub["locks"] = [[1, 2], [3, 4]]

			# Right structures
			var right_cyan := _n(60.0, C, 1, 135.0, 0, [])
			var right_blue := _n(62.0, C, 1, 150.0, 0, [
				[90.0, _n(66.0, C, 1, 145.0, 0, [
					[85.0, _leaf(60.0, 140.0)]  # Orange
				])]
			])

			# Bottom structures
			var bottom_left_orange := _n(58.0, C, 1, 140.0, 0, [])

			var root := _n(4.0, C, 1, 0.0, 0, [
				[-120.0, top_left_blue],
				[-60.0, top_green],
				[0.0, top_right],
				[-180.0, orange_hub],  # Main hub
				[90.0, right_cyan],
				[150.0, right_blue],
				[-150.0, bottom_left_orange]
			])

			return root
		77:
			# Top row - four red and green curves
			var top_row: Array = []
			for i in range(4):
				var angle := -135.0 + float(i) * 90.0
				var radius := 58.0 if i % 2 == 0 else 60.0
				top_row.append(_n(radius, C, 1, 145.0, 0, []))

			# Second row - three green rings with connections
			var row2_left := _n(62.0, C, 1, 140.0, 0, [])
			var row2_mid := _n(64.0, C, 1, 135.0, 0, [
				[0.0, _leaf(56.0, 150.0)]  # Blue bar horizontal
			])
			var row2_right := _n(62.0, C, 1, 145.0, 0, [])

			# Third row - cyan/blue with orange bars
			var row3_left := _n(66.0, C, 1, 140.0, 0, [])
			var row3_mid := _n(68.0, C, 1, 135.0, 0, [
				[0.0, _leaf(58.0, 145.0)]  # Orange bar horizontal
			])
			var row3_right := _n(66.0, C, 1, 150.0, 0, [])

			# Fourth row - green bars with purple square
			var row4_left := _n(60.0, C, 1, 145.0, 0, [
				[-90.0, _n(72.0, S, 0, 0.0, 0, [  # Purple square
					[-90.0, _leaf(58.0, 140.0)]
				])]
			])

			var row4_mid_purple := _n(64.0, C, 0, 0.0, 0, [  # Purple circle
				[0.0, _leaf(56.0, 135.0)]  # Cyan bar
			])

			var row4_right := _n(62.0, C, 1, 140.0, 0, [])

			# Bottom row - three red/purple curves with orange center
			var bottom_left_green := _n(58.0, C, 1, 150.0, 0, [])
			var bottom_mid_purple := _n(70.0, C, 0, 0.0, 0, [  # Purple with marker
				[0.0, _leaf(60.0, 145.0)]  # Cyan bar
			])
			var bottom_right_red := _n(58.0, C, 1, 135.0, 0, [])

			# Assemble grid
			var root := _n(4.0, C, 1, 0.0, 0, [
				[-135.0, top_row[0]],
				[-45.0, top_row[1]],
				[45.0, top_row[2]],
				[135.0, top_row[3]],
				[-120.0, row2_left],
				[0.0, row2_mid],
				[120.0, row2_right],
				[-150.0, row3_left],
				[-30.0, row3_mid],
				[150.0, row3_right],
				[-165.0, row4_left],
				[-60.0, row4_mid_purple],
				[165.0, row4_right],
				[-180.0, bottom_left_green],
				[0.0, bottom_mid_purple],
				[180.0, bottom_right_red]
			])

			root["locks"] = [[0, 1], [2, 3], [4, 6], [7, 9]]
			return root
		78:
			# Top structures
			var top_orange_L := _n(58.0, C, 1, 145.0, 0, [])

			var top_green_bar := _n(60.0, C, 1, 90.0, 0, [
				[0.0, _leaf(54.0, 140.0)]  # Green horizontal bar
			])

			# Upper-left cyan structure
			var upper_left_cyan := _n(62.0, C, 1, 135.0, 0, [
				[-90.0, _n(66.0, C, 1, 150.0, 0, [  # Green curve
					[-85.0, _leaf(60.0, 145.0)]  # Blue
				])]
			])

			# Right red curve with closed circle
			var right_red := _n(64.0, C, 1, 140.0, 0, [
				[85.0, _n(72.0, C, 0, 0.0, 0, [  # Red closed circle
					[90.0, _leaf(62.0, 135.0)]  # Green curve
				])]
			])

			# Main large green hub center
			var green_hub := _n(74.0, C, 0, 0.0, 0, [
				[-150.0, upper_left_cyan],
				[-90.0, top_green_bar],
				[-30.0, _n(60.0, C, 1, 145.0, 0, [
					[80.0, _n(68.0, C, 0, 0.0, 0, [  # Cyan circle with marker
						[85.0, right_red]
					])]
				])],
				[30.0, _n(58.0, C, 1, 140.0, 0, [  # Purple curve
					[80.0, _n(70.0, S, 0, 0.0, 0, [  # Purple bar
						[90.0, _leaf(62.0, 145.0)]
					])]
				])],
				[90.0, _leaf(64.0, 135.0)]  # Orange piece
			])
			green_hub["locks"] = [[2, 3]]

			# Bottom-left structures
			var bottom_left_red := _n(66.0, C, 1, 150.0, 0, [
				[-90.0, _n(62.0, C, 1, 145.0, 0, [  # Red curve
					[-85.0, _leaf(58.0, 140.0)]  # Green
				])]
			])

			# Bottom structures with squares
			var bottom_purple_square := _n(68.0, S, 0, 0.0, 0, [
				[-90.0, _n(64.0, C, 1, 135.0, 0, [
					[-85.0, _leaf(60.0, 140.0)]  # Purple
				])],
				[90.0, _n(66.0, C, 1, 150.0, 0, [
					[85.0, _leaf(62.0, 145.0)]  # Green
				])]
			])
			bottom_purple_square["locks"] = [[0, 1]]

			var bottom_cyan_bar := _n(60.0, C, 1, 180.0, 0, [
				[0.0, _leaf(56.0, 145.0)]  # Cyan bar
			])

			var bottom_blue_square := _n(64.0, S, 0, 0.0, 0, [
				[0.0, _leaf(58.0, 140.0)]  # Cyan bar
			])

			var root := _n(4.0, C, 1, 0.0, 0, [
				[-120.0, top_orange_L],
				[0.0, green_hub],  # Main hub
				[-165.0, bottom_left_red],
				[-135.0, bottom_purple_square],
				[180.0, bottom_cyan_bar],
				[150.0, bottom_blue_square]
			])

			return root
		79:
			# Top chain - orange and purple curves
			var top_orange := _n(62.0, C, 1, 145.0, 0, [
				[-90.0, _n(64.0, C, 1, 140.0, 0, [  # Purple
					[-85.0, _n(60.0, C, 1, 135.0, 0, [  # Orange with marker
						[-80.0, _leaf(58.0, 150.0)]  # Purple
					])]
				])]
			])

			# Upper-middle structures
			var upper_cyan := _n(66.0, C, 1, 140.0, 0, [])
			var upper_orange := _n(68.0, C, 1, 145.0, 0, [])

			# Middle green T-bar
			var green_t := _n(70.0, T, 0, 0.0, 0, [
				[-90.0, _n(62.0, C, 1, 150.0, 0, [
					[-85.0, _leaf(58.0, 135.0)]  # Orange L
				])],
				[0.0, _leaf(64.0, 140.0)],  # Green bar vertical
				[90.0, _n(60.0, C, 1, 145.0, 0, [  # Red curve
					[80.0, _leaf(58.0, 140.0)]
				])]
			])
			green_t["locks"] = [[0, 2]]

			# Left side structures
			var left_orange_L := _n(58.0, C, 1, 135.0, 0, [
				[-90.0, _leaf(54.0, 145.0)]
			])

			var left_blue_T := _n(66.0, T, 0, 0.0, 0, [
				[-90.0, _leaf(60.0, 140.0)],  # Orange bar
				[90.0, _leaf(62.0, 135.0)]  # Red bar
			])

			# Right side structures
			var right_green := _n(64.0, C, 1, 150.0, 0, [
				[85.0, _n(68.0, C, 1, 145.0, 0, [  # Cyan
					[80.0, _leaf(62.0, 140.0)]
				])]
			])

			var right_red_T := _n(70.0, T, 0, 0.0, 0, [
				[0.0, _leaf(64.0, 135.0)]  # Red bar
			])

			# Bottom structures
			var bottom_left_green := _n(60.0, C, 1, 140.0, 0, [
				[-90.0, _n(62.0, C, 1, 145.0, 0, [  # Green with marker
					[-85.0, _leaf(58.0, 135.0)]  # Cyan
				])]
			])

			var bottom_mid_cyan := _n(66.0, C, 0, 0.0, 0, [  # Cyan circle
				[0.0, _leaf(60.0, 150.0)]  # Green curve
			])

			var bottom_right := _n(64.0, C, 1, 135.0, 0, [
				[85.0, _n(68.0, C, 1, 140.0, 0, [  # Orange
					[80.0, _leaf(62.0, 145.0)]  # Cyan
				])]
			])

			var root := _n(4.0, C, 1, 0.0, 0, [
				[-90.0, top_orange],
				[-60.0, upper_cyan],
				[-30.0, upper_orange],
				[0.0, green_t],
				[-150.0, left_orange_L],
				[-120.0, left_blue_T],
				[90.0, right_green],
				[120.0, right_red_T],
				[-180.0, bottom_left_green],
				[180.0, bottom_mid_cyan],
				[150.0, bottom_right]
			])

			return root
		80:
			# Top nose cone - red and green curved pieces
			var nose_top := _n(58.0, C, 1, 145.0, 0, [])  # Red
			var nose_left := _n(60.0, C, 1, 140.0, 0, [])  # Green

			# Upper body - purple bar
			var upper_purple := _n(62.0, C, 1, 90.0, 0, [
				[-90.0, nose_left],
				[90.0, nose_top]
			])
			upper_purple["locks"] = [[0, 1]]

			# Main body - large orange circle with inner structure
			var inner_cyan := _n(56.0, C, 1, 135.0, 0, [])  # Cyan with marker
			var mid_orange := _n(70.0, C, 0, 0.0, 0, [
				[-90.0, upper_purple],
				[0.0, inner_cyan],
				[90.0, _n(64.0, C, 1, 145.0, 0, [  # Blue bar
					[90.0, _leaf(58.0, 140.0)]
				])]
			])
			mid_orange["locks"] = [[1, 2]]

			# Side "wings" with bars
			var left_wing := _n(66.0, C, 1, 180.0, 0, [
				[-90.0, _n(68.0, C, 1, 145.0, 0, [  # Purple curve
					[-85.0, _leaf(62.0, 140.0)]  # Purple/green piece
				])],
				[0.0, _leaf(60.0, 135.0)]  # Orange bar
			])

			var right_wing := _n(64.0, C, 1, 0.0, 0, [
				[90.0, _n(66.0, C, 1, 150.0, 0, [  # Purple/cyan curve
					[85.0, _leaf(60.0, 145.0)]  # Orange piece
				])],
				[0.0, _leaf(58.0, 140.0)]  # Red bar
			])

			# Lower body - red bar with green structure
			var lower_red := _n(68.0, S, 0, 0.0, 0, [
				[0.0, _n(62.0, C, 1, 90.0, 0, [  # Green bar vertical
					[-90.0, _leaf(58.0, 145.0)]  # Blue/green
				])]
			])

			# Bottom structures
			var bottom_left := _n(60.0, C, 1, 135.0, 0, [
				[-90.0, _n(66.0, T, 0, 0.0, 0, [  # Green T
					[-90.0, _leaf(60.0, 140.0)]
				])]
			])

			var bottom_right := _n(64.0, C, 1, 145.0, 0, [
				[90.0, _n(68.0, T, 0, 0.0, 0, [  # Blue T
					[90.0, _leaf(62.0, 135.0)]
				])]
			])

			# Bottom exhaust - complex structure
			var exhaust_left := _n(58.0, C, 1, 150.0, 0, [
				[-90.0, _leaf(54.0, 145.0)]  # Purple piece
			])
			var exhaust_mid_blue := _n(60.0, C, 1, 140.0, 0, [])
			var exhaust_mid_red := _n(62.0, C, 1, 135.0, 0, [])
			var exhaust_right := _n(56.0, C, 1, 145.0, 0, [
				[90.0, _leaf(52.0, 150.0)]  # Purple piece
			])

			var root := _n(4.0, C, 1, 0.0, 0, [
				[0.0, mid_orange],  # Main body
				[-150.0, left_wing],
				[150.0, right_wing],
				[180.0, lower_red],
				[-135.0, bottom_left],
				[135.0, bottom_right],
				[-165.0, exhaust_left],
				[-180.0, exhaust_mid_blue],
				[180.0, exhaust_mid_red],
				[165.0, exhaust_right]
			])

			root["locks"] = [[5, 6]]
			return root

		# Helper functions matching campaign_board.gd
		81:
			return _open_root(68, 132.0, [
				_k(-120, 58, 132.0, [
					_k(-50, 62, 149.0, [
						_k(20, 56, 136.0),
					]),
				]),
				_k(-20, 66, 132.0, [
					_k(50, 56, 149.0, [
						_k(120, 60, 136.0, [
							_k(190, 58, 153.0),
						]),
					]),
				]),
				_k(80, 64, 132.0, [
					_k(150, 56, 149.0),
				]),
			])
		82:
			var internal_cluster := _closed(56, C, [
				_k(-90, 58, 132.0, [
					_k(0, 56, 149.0),
				]),
				_k(30, 60, 132.0, [
					_k(120, 56, 149.0),
				]),
				_k(150, 58, 132.0),
			])
			return _closed(92, C, [
				_k(-150, 56, 132.0),
				_k(-90, 60, 132.0),
				_k(-30, 58, 132.0, [
					_k(40, 64, 149.0, [
						_k(110, 56, 136.0),
					]),
				]),
				_k(30, 66, 132.0, [
					[0, internal_cluster],
				]),
			])
		83:
			var blue_hub := _closed(46, C, [
				_k(-120, 56, 132.0, [
					_k(-60, 58, 149.0),
				]),
				_k(0, 58, 132.0, [
					_k(60, 56, 149.0),
				]),
				_k(120, 58, 132.0),
			])
			return _closed(88, C, [
				_k(0, 56, 132.0),
				_k(90, 60, 132.0, [
					[-90, blue_hub],
				]),
				_k(180, 58, 132.0, [
					_k(240, 56, 149.0, [
						_k(300, 58, 136.0),
					]),
				]),
				_k(270, 56, 132.0),
			])
		84:
			var top_cluster := _closed(58, C, [
				_k(-120, 56, 132.0, [
					_k(-60, 58, 149.0),
				]),
				_k(0, 58, 132.0, [
					_k(60, 56, 149.0),
				]),
				_k(120, 56, 132.0),
			])
			var bottom_cluster := _closed(58, C, [
				_k(-120, 56, 132.0),
				_k(0, 58, 132.0, [
					_k(60, 56, 149.0),
				]),
				_k(120, 58, 132.0),
			])
			var left_ring := _n(62, C, 1, 140.0, 0, [
				[-90, top_cluster],
			])
			var right_ring := _n(62, C, 1, 140.0, 0, [
				[90, bottom_cluster],
			])
			return _closed(66, T, [
				[-150, left_ring],
				[30, right_ring],
			])
		85:
			return _open_root(70, 132.0, [
				_k(-140, 58, 132.0, [
					_k(-80, 62, 149.0, [
						_k(-20, 56, 136.0, [
							_k(40, 60, 153.0),
						]),
					]),
				]),
				_k(-70, 66, 132.0, [
					_k(-10, 56, 149.0, [
						_k(50, 58, 136.0, [
							_k(110, 56, 153.0, [
								_k(170, 62, 140.0),
							]),
						]),
					]),
				]),
				_k(20, 64, 132.0, [
					_k(80, 56, 149.0, [
						_k(140, 60, 136.0),
					]),
				]),
			])
		86:
			var center_spoke := _closed(54, C, [
				_k(-90, 56, 132.0),
				_k(-30, 58, 132.0, [
					_k(40, 56, 149.0),
				]),
				_k(30, 60, 132.0),
				_k(90, 56, 132.0, [
					_k(160, 58, 149.0),
				]),
				_k(150, 58, 132.0),
				_k(210, 56, 132.0),
			])
			return _open_root(76, 132.0, [
				_k(-135, 58, 132.0, [
					_k(-75, 56, 149.0),
				]),
				_k(-45, 60, 132.0, [
					[-90, center_spoke],
				]),
				_k(45, 58, 132.0, [
					_k(105, 56, 149.0, [
						_k(165, 58, 136.0),
					]),
				]),
				_k(135, 56, 132.0),
			])
		87:
			return _open_root(64, 132.0, [
				_k(-150, 58, 132.0, [
					_k(-80, 62, 149.0, [
						_k(-10, 56, 136.0, [
							_k(60, 60, 153.0),
						]),
					]),
				]),
				_k(-50, 66, 132.0, [
					_k(20, 56, 149.0, [
						_k(90, 58, 136.0, [
							_k(160, 56, 153.0, [
								_k(230, 62, 140.0),
							]),
						]),
					]),
				]),
				_k(30, 64, 132.0, [
					_k(110, 56, 149.0, [
						_k(190, 60, 136.0),
					]),
				]),
			])
		88:
			return _open_root(66, 132.0, [
				_k(-120, 58, 132.0, [
					_k(-50, 62, 149.0, [
						_k(20, 56, 136.0, [
							_k(90, 60, 153.0),
						]),
					]),
				]),
				_k(-30, 66, 132.0, [
					_k(40, 56, 149.0, [
						_k(110, 58, 136.0, [
							_k(180, 56, 153.0, [
								_k(250, 62, 140.0),
							]),
						]),
					]),
				]),
				_k(60, 64, 132.0, [
					_k(130, 56, 149.0),
				]),
			])
		89:
			var hub := _closed(62, C, [
				_k(-135, 56, 132.0, [
					_k(-75, 58, 149.0, [
						_k(-15, 56, 136.0),
					]),
				]),
				_k(-45, 60, 132.0, [
					_k(15, 56, 149.0, [
						_k(75, 58, 136.0),
					]),
				]),
				_k(45, 58, 132.0, [
					_k(105, 56, 149.0),
				]),
				_k(135, 56, 132.0, [
					_k(195, 60, 149.0, [
						_k(255, 58, 136.0),
					]),
				]),
			])
			return _open_root(78, 132.0, [
				[-90, hub],
				_k(90, 58, 132.0),
			])
		90:
			var outer_ring := _closed(76, C, [
				_k(-120, 56, 132.0),
				_k(-60, 58, 132.0),
				_k(0, 56, 132.0),
				_k(60, 60, 132.0),
				_k(120, 56, 132.0),
				_k(180, 58, 132.0),
			])
			var middle_ring := _closed(56, C, [
				_k(-90, 58, 132.0),
				_k(30, 56, 132.0),
				_k(150, 60, 132.0),
			])
			return _n(88, C, 1, 270.0, 0, [
				[-90, outer_ring],
				[0, middle_ring],
			])
		91:
			return _open_root(72, 132.0, [
				_k(-150, 58, 132.0, [
					_k(-80, 62, 149.0, [
						_k(-10, 56, 136.0, [
							_k(60, 60, 153.0, [
								_k(130, 56, 140.0),
							]),
						]),
					]),
				]),
				_k(-60, 66, 132.0, [
					_k(10, 56, 149.0, [
						_k(80, 58, 136.0, [
							_k(150, 56, 153.0),
						]),
					]),
				]),
				_k(30, 64, 132.0, [
					_k(100, 56, 149.0, [
						_k(170, 60, 136.0),
					]),
				]),
			])
		92:
			return _open_root(68, 132.0, [
				_k(-140, 58, 132.0, [
					_k(-70, 62, 149.0, [
						_k(0, 56, 136.0, [
							_k(70, 60, 153.0, [
								_k(140, 56, 140.0),
							]),
						]),
					]),
				]),
				_k(-50, 66, 132.0, [
					_k(20, 56, 149.0, [
						_k(90, 58, 136.0, [
							_k(160, 56, 153.0, [
								_k(230, 62, 140.0, [
									_k(300, 58, 144.0),
								]),
							]),
						]),
					]),
				]),
				_k(40, 64, 132.0, [
					_k(110, 56, 149.0, [
						_k(180, 60, 136.0),
					]),
				]),
			])
		93:
			var hub := _closed(58, C, [
				_k(-90, 56, 132.0, [
					_k(-30, 58, 149.0),
				]),
				_k(30, 60, 132.0, [
					_k(90, 56, 149.0),
				]),
				_k(150, 58, 132.0, [
					_k(210, 56, 149.0),
				]),
			])
			return _open_root(66, 132.0, [
				_k(-135, 58, 132.0, [
					_k(-75, 56, 149.0),
				]),
				[-45, hub],
				_k(45, 60, 132.0, [
					_k(105, 58, 149.0),
				]),
				_k(135, 56, 132.0),
			])
		94:
			return _open_root(70, 132.0, [
				_k(-145, 58, 132.0, [
					_k(-85, 62, 149.0, [
						_k(-25, 56, 136.0, [
							_k(35, 60, 153.0, [
								_k(95, 56, 140.0, [
									_k(155, 62, 157.0),
								]),
							]),
						]),
					]),
				]),
				_k(-65, 66, 132.0, [
					_k(-5, 56, 149.0, [
						_k(55, 58, 136.0, [
							_k(115, 56, 153.0, [
								_k(175, 60, 140.0),
							]),
						]),
					]),
				]),
				_k(25, 64, 132.0, [
					_k(85, 56, 149.0, [
						_k(145, 60, 136.0),
					]),
				]),
			])
		95:
			return _open_root(68, 132.0, [
				_k(-150, 58, 132.0, [
					_k(-90, 62, 149.0, [
						_k(-30, 56, 136.0, [
							_k(30, 60, 153.0, [
								_k(90, 56, 140.0, [
									_k(150, 62, 157.0),
								]),
							]),
						]),
					]),
				]),
				_k(-60, 66, 132.0, [
					_k(0, 56, 149.0, [
						_k(60, 58, 136.0, [
							_k(120, 56, 153.0, [
								_k(180, 60, 140.0),
							]),
						]),
					]),
				]),
				_k(20, 64, 132.0, [
					_k(80, 56, 149.0, [
						_k(140, 60, 136.0, [
							_k(200, 58, 153.0),
						]),
					]),
				]),
			])
		96:
			return _open_root(72, 132.0, [
				_k(-145, 58, 132.0, [
					_k(-80, 62, 149.0, [
						_k(-15, 56, 136.0, [
							_k(50, 60, 153.0, [
								_k(115, 56, 140.0, [
									_k(180, 62, 157.0, [
										_k(245, 58, 144.0),
									]),
								]),
							]),
						]),
					]),
				]),
				_k(-55, 66, 132.0, [
					_k(10, 56, 149.0, [
						_k(75, 58, 136.0, [
							_k(140, 56, 153.0, [
								_k(205, 60, 140.0),
							]),
						]),
					]),
				]),
				_k(35, 64, 132.0, [
					_k(100, 56, 149.0, [
						_k(165, 60, 136.0, [
							_k(230, 58, 153.0),
						]),
					]),
				]),
			])
		97:
			return _open_root(66, 132.0, [
				_k(-140, 58, 132.0, [
					_k(-75, 62, 149.0, [
						_k(-10, 56, 136.0, [
							_k(55, 60, 153.0),
						]),
					]),
				]),
				_k(-50, 66, 132.0, [
					_k(15, 56, 149.0, [
						_k(80, 58, 136.0, [
							_k(145, 56, 153.0, [
								_k(210, 62, 140.0),
							]),
						]),
					]),
				]),
				_k(30, 64, 132.0, [
					_k(95, 56, 149.0, [
						_k(160, 60, 136.0, [
							_k(225, 58, 153.0),
						]),
					]),
				]),
			])
		98:
			var hub := _closed(54, C, [
				_k(-120, 56, 132.0, [
					_k(-60, 58, 149.0),
				]),
				_k(-20, 60, 132.0, [
					_k(40, 56, 149.0),
				]),
				_k(80, 58, 132.0, [
					_k(140, 56, 149.0),
				]),
				_k(180, 58, 132.0, [
					_k(240, 60, 149.0),
				]),
			])
			return _open_root(74, 132.0, [
				_k(-150, 58, 132.0, [
					_k(-90, 56, 149.0),
				]),
				[-45, hub],
				_k(45, 60, 132.0, [
					_k(105, 58, 149.0, [
						_k(165, 56, 136.0),
					]),
				]),
				_k(135, 56, 132.0),
			])
		99:
			return _open_root(68, 132.0, [
				_k(-135, 58, 132.0, [
					_k(-70, 62, 149.0, [
						_k(-5, 56, 136.0, [
							_k(60, 60, 153.0, [
								_k(125, 56, 140.0, [
									_k(190, 62, 157.0),
								]),
							]),
						]),
					]),
				]),
				_k(-50, 66, 132.0, [
					_k(15, 56, 149.0, [
						_k(80, 58, 136.0, [
							_k(145, 56, 153.0, [
								_k(210, 60, 140.0, [
									_k(275, 58, 157.0),
								]),
							]),
						]),
					]),
				]),
				_k(30, 64, 132.0, [
					_k(95, 56, 149.0, [
						_k(160, 60, 136.0),
					]),
				]),
			])
		100:
			var inner_ring := _closed(56, C, [
				_k(-150, 58, 132.0),
				_k(-90, 60, 132.0),
				_k(-30, 56, 132.0),
				_k(30, 58, 132.0),
				_k(90, 56, 132.0),
				_k(150, 60, 132.0),
			])
			return _closed(88, C, [
				_k(-150, 58, 132.0, [
					_k(-90, 56, 149.0, [
						_k(-30, 60, 136.0),
					]),
				]),
				_k(-90, 60, 132.0, [
					[-45, inner_ring],
				]),
				_k(-30, 56, 132.0, [
					_k(30, 58, 149.0),
				]),
				_k(30, 58, 132.0, [
					_k(90, 56, 149.0),
				]),
				_k(90, 60, 132.0, [
					_k(150, 58, 149.0),
				]),
				_k(150, 56, 132.0),
			])
		_:
			return _closed(70.0, C, [_k(-90.0, 56.0, 140.0)])

const _TITLES: Array[String] = [
	"First Twist", "Purple Hook", "Blue Fork", "Red Branch", "Wheel of Six",
	"Side Clasp", "Square Hook", "Uneven Fork", "Offset Pair", "Short Curl",
	"Forked Tail", "Two Clusters", "Loose Pairs", "Tall Curl", "Split Sides",
	"Nested Curl", "Broken Crown", "Jay Hook", "Side Bud", "Keyhole",
	"Opposite Curls", "Kinked Hook", "Heavy Base", "Clasped Vine", "Uneven Branch",
	"Offset Vines", "Mid Branch", "Twin Tip", "Single Elbow", "Left Heavy",
	"Tight Coil", "Deep Clusters", "Triple Arm", "Long Elbow", "Long And Short",
	"Clasped Mouth", "Nested Vine", "Split Bundles", "Open Scatter", "Center Bud",
	"Wide Coil", "Twin Bundles", "Balanced Arms", "Elbow Mouth", "Long Side Pair",
	"Fat And Thin", "Arc Tail", "Open Fork", "Clasped Frame", "Master Branch",
	"Bridge Frame", "Flower Wheel", "Organic Scatter", "Diamond Grid", "Woven Paths",
]

const _LINES: Array[String] = [
	"Turn the open ring until its gap takes the cuff.",
	"Three open rings in a hook. Free the blue tip first.",
	"The blue ring holds two paths. Clear the side, then the tail.",
	"A red ring roots a branch of six. Start at the loose tips.",
	"A closed circle holds six rings. Three of those rings are held twice.",
	"An oval clasps two rings. Clear either neighbor.",
	"A square trails a short hook. Start at the tip.",
	"Three different rings on a triangle, none evenly spaced.",
	"A short ring on one side, a longer chain on the other.",
	"An oval trails a short curl. Start at the tip.",
	"A triangle holds three rings, and one of those rings carries a tail.",
	"One cluster sits above the square, a longer one below.",
	"Three loose pairs. No ring sits in the middle as a hub.",
	"Follow the curl from the loose end.",
	"A triangle splits into a left chain and a right chain.",
	"Sizes alternate along one curl. Big, then small.",
	"Three rings along the top, and a tail off to the side.",
	"The chain drops, then hooks back once.",
	"A long chain, plus a short bud on the other side.",
	"One large ring on the left. A small chain leaves the right.",
	"Two curls leave the circle in opposite directions.",
	"The hook runs straight, kinks, then runs straight again.",
	"Three large rings along the bottom. A thin chain goes up.",
	"A clasp near the square, then a longer vine.",
	"Three arms, and none of them the same length.",
	"Two vines run side by side off the oval.",
	"The chain drops, then a bud leaves from the middle.",
	"The last ring has two mouths. Either mouth can take the cuff.",
	"One elbow. The chain turns a single corner.",
	"A heavy chain on the left, a short pair on the right.",
	"A tighter coil than the tall curl. Start at the outside.",
	"A cluster of three beside a cluster of four.",
	"Three arms on a triangle. Read each tip.",
	"A long straight run, then one corner.",
	"A chain of five beside a chain of two.",
	"Neighbors clasp, and the far tip has two mouths.",
	"Big rings and small rings trade places along the vine.",
	"A short bundle beside a longer one.",
	"Three large rings and a small chain, with no closed hub.",
	"A bud leaves the middle of the chain.",
	"A wide coil. Eight rings, one closed oval.",
	"Two bundles of four leave the triangle.",
	"Three arms again, this time closer in length.",
	"The elbow ends in a ring with two mouths.",
	"Six rings down one side, two down the other.",
	"Fat rings and thin rings alternate on one vine.",
	"A short arc, then a longer tail.",
	"An open ring forks into three arms.",
	"A clasp, a long arm, and a double mouth at the tip.",
	"The oval splits into a long arm and two short ones.",
	"A square bridge spans the top. Locked clusters anchor the frame.",
	"A symmetric flower spreads from the central circle. Work from the outside in.",
	"An organic scatter with no clear pattern. Read each connection carefully.",
	"Diamond clusters with square bridges. The grid has multiple entry points.",
	"Woven paths cross at the center. Untangle from the outermost rings.",
]

static func _lv(title: String, instruction: String, root: Dictionary) -> Dictionary:
	return { "title": title, "instruction": instruction, "root": root }

static func _n(r: float, shape: int, gaps: int, turn: float, color: int, kids: Array, bridge: bool = false, extra: Array = []) -> Dictionary:
	return {
		"r": r,
		"shape": shape,
		"gaps": gaps,
		"turn": turn,
		"color": color,
		"kids": kids,
		"bridge": bridge,
		"extra": extra,
		"thick": 16.0,
	}

static func _leaf(r: float, turn: float, gaps: int = 1) -> Dictionary:
	return _n(r, C, gaps, turn, 0, [])

static func _hold_open(r: float, turn: float, kids: Array, gaps: int = 1) -> Dictionary:
	return _n(r, C, gaps, turn, 0, kids)

static func _hold(r: float, shape: int, kids: Array, bridge: bool = false, extra: Array = []) -> Dictionary:
	return _n(r, shape, 0, 0, 0, kids, bridge, extra)

static func _fan(r: float, shape: int, leaves: Array, bridge: bool = false) -> Dictionary:
	var kids: Array = []
	for leaf in leaves:
		var gaps := 1
		if leaf.size() > 3:
			gaps = int(leaf[3])
		kids.append([float(leaf[0]), _leaf(float(leaf[1]), float(leaf[2]), gaps)])
	return _hold(r, shape, kids, bridge)

static func _chain(radii: Array, angles: Array, turns: Array, root_shape: int = C) -> Dictionary:
	var node := _leaf(float(radii[radii.size() - 1]), float(turns[turns.size() - 1]))
	for i in range(radii.size() - 2, -1, -1):
		var gaps := 0 if i == 0 else 1
		var shape := root_shape if i == 0 else C
		node = _n(float(radii[i]), shape, gaps, float(turns[i]), 0, [[float(angles[i]), node]])
	return node

static func _paint(node: Dictionary, color: int, parent_color: int) -> void:
	if node.get("fixed_color", false):
		var kids: Array = node.kids
		for i in kids.size():
			var kid: Dictionary = kids[i][1]
			_paint(kid, kid.get("color", 0), node.color)
		return
	var chosen := color % _PALETTE.size()
	if chosen == parent_color:
		chosen = (chosen + 3) % _PALETTE.size()
	node.color = chosen
	var kids: Array = node.kids
	for i in kids.size():
		var kid: Dictionary = kids[i][1]
		_paint(kid, chosen + 3 + i, chosen)

static func _walk(node: Dictionary, pos: Vector2, flat: Array, edges: Array) -> void:
	node.pos = pos
	node.idx = flat.size()
	flat.append(node)
	var kids: Array = node.kids
	var placed: Array = []
	for i in kids.size():
		var ang := float(kids[i][0])
		var kid: Dictionary = kids[i][1]
		var partner := _clasp_partner(node, i)
		if partner >= 0:
			var first: Dictionary = kids[partner][1]
			var arm_a := _sep(node, first)
			var arm_b := _sep(node, kid)
			var side := _sep(first, kid)
			var base := rad_to_deg((first.pos - pos).angle())
			ang = base + _spread(arm_a, arm_b, side)
		elif not bool(node.get("fixed_color", false)):
			ang = _clear_angle(node, pos, kid, ang, flat)
		var dist := _sep(node, kid)
		_walk(kid, pos + Vector2.from_angle(deg_to_rad(ang)) * dist, flat, edges)
		edges.append([node.idx, kid.idx])
		placed.append(kid)
	if bool(node.bridge) and placed.size() >= 2:
		edges.append([placed[0].idx, placed[1].idx])
	var locks: Array = node.get("locks", [])
	for pair in locks:
		var lock_a: Dictionary = placed[int(pair[0])]
		var lock_b: Dictionary = placed[int(pair[1])]
		edges.append([lock_a.idx, lock_b.idx])
	for pair in node.extra:
		var a: Dictionary = placed[int(pair[0])]
		var b: Dictionary = placed[int(pair[1])]
		edges.append([a.idx, b.idx])

static func _clasp_partner(node: Dictionary, index: int) -> int:
	if bool(node.bridge) and index == 1:
		return 0
	for pair in node.extra:
		if int(pair[1]) == index:
			return int(pair[0])
	return -1

static func _clear_angle(parent: Dictionary, pos: Vector2, kid: Dictionary, preferred: float, flat: Array) -> float:
	var dist := _sep(parent, kid)
	for step in 30:
		var delta := 0.0 if step == 0 else float((step + 1) / 2) * 8.0
		if step % 2 == 1:
			delta = -delta
		var ang := preferred + delta
		var spot := pos + Vector2.from_angle(deg_to_rad(ang)) * dist
		if _spot_clear(spot, kid, parent, pos, flat):
			return ang
	return preferred

static func _spot_clear(spot: Vector2, kid: Dictionary, parent: Dictionary, parent_pos: Vector2, flat: Array) -> bool:
	for other in flat:
		if other == parent:
			continue
		var gap := spot.distance_to(other.pos) - _outer(kid) - _outer(other)
		if gap < 10.0:
			return false
		if _segment_gap(parent_pos, spot, other.pos) < _outer(other) + 6.0:
			return false
	return true

static func _segment_gap(a: Vector2, b: Vector2, p: Vector2) -> float:
	var ab := b - a
	var len2 := ab.length_squared()
	if len2 < 0.001:
		return p.distance_to(a)
	var t := clampf((p - a).dot(ab) / len2, 0.0, 1.0)
	return p.distance_to(a + ab * t)

static func _spread(ab: float, ac: float, bc: float) -> float:
	var denom := 2.0 * ab * ac
	if denom <= 0.001:
		return 64.0
	var cosine := clampf((ab * ab + ac * ac - bc * bc) / denom, -1.0, 1.0)
	return rad_to_deg(acos(cosine))

static func _outer(node: Dictionary) -> float:
	var reach := float(node.r)
	var shape := int(node.shape)
	var radius := float(node.r)
	for i in 36:
		reach = maxf(reach, Geometry.get_boundary_distance(shape, radius, TAU * float(i) / 36.0))
	return reach + float(node.thick) * 0.5

static func _sep(a: Dictionary, b: Dictionary) -> float:
	return _outer(a) + _outer(b) + _AIR

static func _fit(flat: Array) -> void:
	var min_x := INF
	var max_x := -INF
	var min_y := INF
	var max_y := -INF
	for node in flat:
		var pos: Vector2 = node.pos
		var o := _outer(node)
		min_x = minf(min_x, pos.x - o)
		max_x = maxf(max_x, pos.x + o)
		min_y = minf(min_y, pos.y - o)
		max_y = maxf(max_y, pos.y + o)
	var center := Vector2((min_x + max_x) * 0.5, (min_y + max_y) * 0.5)
	var need := 1.0
	for node in flat:
		var pos: Vector2 = node.pos - center
		var o := _outer(node) + 10.0
		need = maxf(need, (absf(pos.x) + o) / _HALF.x)
		need = maxf(need, (absf(pos.y) + o) / _HALF.y)
	var scale := 1.0 if need <= 1.0 else maxf(0.86, 1.0 / need)
	for node in flat:
		node.pos = (node.pos - center) * scale + _BOARD

static func _pieces_from(flat: Array) -> Array:
	var pieces: Array = []
	for node in flat:
		var gaps: Array = []
		var width := _gap_width(float(node.r), float(node.thick), int(node.gaps))
		if int(node.gaps) >= 1:
			gaps.append(GapDefinitionScript.new(0.0, width, 6.0))
		if int(node.gaps) >= 2:
			gaps.append(GapDefinitionScript.new(180.0, width, 6.0))
		var piece = PieceDefinitionScript.new(
			StringName("ring_%d" % int(node.idx)),
			node.pos,
			float(node.r),
			float(node.thick),
			_PALETTE[int(node.color) % _PALETTE.size()],
			0.0,
			gaps,
			0.0,
			int(node.shape)
		)
		piece.z_index = 4 + int(node.idx)
		pieces.append(piece)
		node.piece = piece
	return pieces

static func _links_from(flat: Array, edges: Array) -> Array:
	var links: Array = []
	for i in edges.size():
		var edge: Array = edges[i]
		var parent: Dictionary = flat[int(edge[0])]
		var child: Dictionary = flat[int(edge[1])]
		links.append(LinkDefinitionScript.new(
			StringName("link_%d" % i),
			StringName("ring_%d" % int(parent.idx)),
			StringName("ring_%d" % int(child.idx)),
			_PALETTE[int(parent.color) % _PALETTE.size()]
		))
	return links

static func _gap_width(radius: float, thick: float, gaps: int) -> float:
	var width := 112.0 if gaps < 2 else 96.0
	var opening := Geometry.usable_opening_length(C, radius, width, thick)
	if Geometry.opening_accepts_cuff(opening, ConnectorRuntime.TANGENTIAL_WIDTH, ConnectorRuntime.SAFETY_MARGIN):
		return width
	var grown := width
	while grown < 140.0:
		grown += 4.0
		opening = Geometry.usable_opening_length(C, radius, grown, thick)
		if Geometry.opening_accepts_cuff(opening, ConnectorRuntime.TANGENTIAL_WIDTH, ConnectorRuntime.SAFETY_MARGIN):
			return grown
	return 140.0

static func _set_rest_angles(def) -> void:
	var built := _spawn(def)
	var root = Rules.get_piece_by_id(StringName("ring_0"), built.pieces)
	if root != null and not root.gaps.is_empty():
		var root_turn := _authored_turn(def, root.piece_id)
		root.rotation_degrees = fposmod(root_turn, 360.0)
		root.current_angle_deg = root.rotation_degrees
		_piece_def(def, root.piece_id).start_angle_deg = root.rotation_degrees
	for piece in built.pieces:
		if not piece.gaps.is_empty():
			continue
		var face := _facing_child(piece, built.links, built.pieces)
		piece.rotation_degrees = face
		piece.current_angle_deg = face
		_piece_def(def, piece.piece_id).start_angle_deg = face
	_rebind(built)
	for link in built.links:
		var child = Rules.get_piece_by_id(link.def.to_piece_id, built.pieces)
		if child == null or child.gaps.is_empty():
			continue
		if absf(child.rotation_degrees) > 0.01:
			continue
		var align := Rules.alignment_rotation_deg(child, link, built.pieces, child.gaps[0])
		var turn := _authored_turn(def, child.piece_id)
		if turn < 70.0:
			turn = 124.0
		child.rotation_degrees = fposmod(align + turn, 360.0)
		child.current_angle_deg = child.rotation_degrees
		_piece_def(def, child.piece_id).start_angle_deg = child.rotation_degrees
	_seat_mouths(def, built.pieces, built.links)
	_free_nodes(built.pieces)

const _TIP_MARGIN := 35.0

static func _seat_mouths(def, pieces: Array, links: Array) -> void:
	for _round in 4:
		var stuck := false
		for piece in pieces:
			if piece.gaps.is_empty():
				continue
			var seat: Dictionary = _best_seat(piece, links, pieces)
			_apply_rest(def, piece, float(seat.rot))
			if float(seat.slack) < -0.01:
				stuck = true
		if not stuck:
			return
		if not _bend_tight_joints(def, pieces, links):
			return
	for piece in pieces:
		if piece.gaps.is_empty():
			continue
		var seat: Dictionary = _best_seat(piece, links, pieces)
		_apply_rest(def, piece, float(seat.rot))

static func _best_seat(piece, links: Array, pieces: Array) -> Dictionary:
	_rebind_lists(links, pieces)
	var contacts := _contact_angles(piece, links, pieces)
	var best_rot := float(piece.rotation_degrees)
	var best_slack := 180.0
	if contacts.is_empty():
		return {"rot": best_rot, "slack": best_slack}
	best_slack = -180.0
	for step in 360:
		var rot := float(step)
		var slack := _mouth_slack(piece, rot, contacts)
		if slack > best_slack:
			best_slack = slack
			best_rot = rot
	return {"rot": best_rot, "slack": best_slack}

static func _contact_angles(piece, links: Array, pieces: Array) -> Array:
	var contacts: Array = []
	for link in links:
		if link.def.to_piece_id == piece.piece_id:
			contacts.append(Rules.cuff_world_angle_deg(piece, link, pieces))
		elif link.def.from_piece_id == piece.piece_id:
			var child = Rules.get_piece_by_id(link.def.to_piece_id, pieces)
			if child == null:
				continue
			contacts.append(fposmod(rad_to_deg((child.position - piece.position).angle()), 360.0))
	return contacts

static func _mouth_slack(piece, rotation_deg: float, contacts: Array) -> float:
	var worst := 180.0
	for gap in piece.gaps:
		var need := float(gap.width_deg) * 0.5 + _TIP_MARGIN
		var mouth := fposmod(rotation_deg + float(gap.center_angle_deg), 360.0)
		for contact in contacts:
			var off := absf(wrapf(mouth - float(contact), -180.0, 180.0))
			worst = minf(worst, off - need)
	return worst

static func _bend_tight_joints(def, pieces: Array, links: Array) -> bool:
	var moved := false
	for piece in pieces:
		if piece.gaps.is_empty():
			continue
		if float(_best_seat(piece, links, pieces).slack) >= -0.01:
			continue
		var swung := false
		for link in links:
			if link.def.from_piece_id != piece.piece_id:
				continue
			var child = Rules.get_piece_by_id(link.def.to_piece_id, pieces)
			if child != null and _try_swing(def, pieces, links, piece, child):
				swung = true
		if swung:
			moved = true
			continue
		var parent = _parent_piece(piece, links, pieces)
		if parent != null and _try_swing(def, pieces, links, parent, piece):
			moved = true
	return moved

static func _try_swing(def, pieces: Array, links: Array, pivot, child) -> bool:
	var snap := _copy_positions(pieces)
	var base := _crowd_slack(pieces, links)
	var chosen := 0.0
	var chosen_slack := base
	for step in range(1, 16):
		for sign in [-1.0, 1.0]:
			var delta: float = float(sign) * float(step) * 8.0
			_paste_positions(pieces, def, snap)
			_swing_descendants(pivot, child, delta, pieces, links, def)
			if not _layout_clear(pieces, links):
				continue
			var slack := _crowd_slack(pieces, links)
			if slack > chosen_slack + 0.25:
				chosen_slack = slack
				chosen = delta
			if chosen_slack >= -0.01:
				break
		if chosen_slack >= -0.01:
			break
	_paste_positions(pieces, def, snap)
	if absf(chosen) < 0.1:
		_rebind_lists(links, pieces)
		return false
	_swing_descendants(pivot, child, chosen, pieces, links, def)
	return true

static func _crowd_slack(pieces: Array, links: Array) -> float:
	var worst := 180.0
	for piece in pieces:
		if piece.gaps.is_empty():
			continue
		worst = minf(worst, float(_best_seat(piece, links, pieces).slack))
	return worst

static func _parent_piece(piece, links: Array, pieces: Array):
	for link in links:
		if link.def.to_piece_id != piece.piece_id:
			continue
		return Rules.get_piece_by_id(link.def.from_piece_id, pieces)
	return null

static func _copy_positions(pieces: Array) -> Dictionary:
	var snap := {}
	for piece in pieces:
		snap[piece.piece_id] = piece.position
	return snap

static func _paste_positions(pieces: Array, def, snap: Dictionary) -> void:
	for piece in pieces:
		piece.position = snap[piece.piece_id]
		var source = _piece_def(def, piece.piece_id)
		if source != null:
			source.position = piece.position

static func _swing_descendants(pivot, child, delta_deg: float, pieces: Array, links: Array, def) -> void:
	var origin: Vector2 = pivot.position
	var members: Array = []
	_gather_descendants(child, links, pieces, members)
	var rad := deg_to_rad(delta_deg)
	for member in members:
		var rel: Vector2 = member.position - origin
		member.position = origin + rel.rotated(rad)
		var source = _piece_def(def, member.piece_id)
		if source != null:
			source.position = member.position
	_rebind_lists(links, pieces)

static func _gather_descendants(piece, links: Array, pieces: Array, members: Array) -> void:
	members.append(piece)
	for link in links:
		if link.def.from_piece_id != piece.piece_id:
			continue
		var kid = Rules.get_piece_by_id(link.def.to_piece_id, pieces)
		if kid == null:
			continue
		_gather_descendants(kid, links, pieces, members)

static func _layout_clear(pieces: Array, links: Array) -> bool:
	for piece in pieces:
		var reach := _piece_reach(piece)
		if piece.position.x - reach < 48.0 or piece.position.x + reach > 672.0:
			return false
		if piece.position.y - reach < 210.0 or piece.position.y + reach > 1040.0:
			return false
	var linked := {}
	for link in links:
		linked["%s>%s" % [link.def.from_piece_id, link.def.to_piece_id]] = true
	for i in pieces.size():
		for j in range(i + 1, pieces.size()):
			var a = pieces[i]
			var b = pieces[j]
			var separation: float = a.position.distance_to(b.position) - _piece_reach(a) - _piece_reach(b)
			var joined := linked.has("%s>%s" % [a.piece_id, b.piece_id]) or linked.has("%s>%s" % [b.piece_id, a.piece_id])
			if joined and separation < 28.0:
				return false
			if not joined and separation < 8.0:
				return false
	for link in links:
		var parent = Rules.get_piece_by_id(link.def.from_piece_id, pieces)
		var child = Rules.get_piece_by_id(link.def.to_piece_id, pieces)
		if parent == null or child == null:
			continue
		for other in pieces:
			if other == parent or other == child:
				continue
			if _segment_gap(parent.position, child.position, other.position) < _piece_reach(other) + 4.0:
				return false
	return true

static func _piece_reach(piece) -> float:
	var reach := float(piece.radius)
	for i in 12:
		reach = maxf(reach, Geometry.get_boundary_distance(int(piece.shape_type), float(piece.radius), TAU * float(i) / 12.0))
	return reach + float(piece.thickness) * 0.5

static func _rebind_lists(links: Array, pieces: Array) -> void:
	var piece_map := {}
	for piece in pieces:
		piece_map[piece.piece_id] = piece
	for link in links:
		var from_p = piece_map[link.def.from_piece_id]
		var to_p = piece_map[link.def.to_piece_id]
		Rules.bind_connector(link.def, from_p.position, from_p.rotation_degrees, to_p.position)
		link.current_stem_dist = link.def.stem_dist

static func _apply_rest(def, child, rotation_deg: float) -> void:
	child.rotation_degrees = rotation_deg
	child.current_angle_deg = rotation_deg
	_piece_def(def, child.piece_id).start_angle_deg = rotation_deg

static func _rebind(built: Dictionary) -> void:
	var piece_map := {}
	for piece in built.pieces:
		piece_map[piece.piece_id] = piece
	for link in built.links:
		var from_p = piece_map[link.def.from_piece_id]
		var to_p = piece_map[link.def.to_piece_id]
		Rules.bind_connector(link.def, from_p.position, from_p.rotation_degrees, to_p.position)
		link.current_stem_dist = link.def.stem_dist

static func _authored_turn(def, piece_id: StringName) -> float:
	var spec: Dictionary = _spec(int(def.level_id))
	var found: Array = []
	_find_turn(spec.root, piece_id, 0, found)
	if found.is_empty():
		return 124.0
	return float(found[0])

static func _find_turn(node: Dictionary, piece_id: StringName, idx: int, found: Array) -> int:
	if StringName("ring_%d" % idx) == piece_id:
		found.append(float(node.turn) if int(node.gaps) > 0 else 0.0)
		return idx + 1
	var next := idx + 1
	for kid in node.kids:
		next = _find_turn(kid[1], piece_id, next, found)
		if not found.is_empty():
			return next
	return next

static func _facing_child(parent, links: Array, pieces: Array) -> float:
	for link in links:
		if link.def.from_piece_id != parent.piece_id:
			continue
		var child = Rules.get_piece_by_id(link.def.to_piece_id, pieces)
		if child == null:
			continue
		return rad_to_deg((child.position - parent.position).angle())
	return 0.0

static func _piece_def(def, piece_id: StringName):
	for piece in def.pieces:
		if piece.id == piece_id:
			return piece
	return null

static func _stamp_solution(def) -> void:
	if _defer_solve:
		return
	var built := _spawn(def)
	var initial := Rules.resolve_releases(built.pieces, built.links)
	if initial.size() > 0:
		push_warning("Campaign level %d is already open at rest." % int(def.level_id))
	var solved: Dictionary = BFSSolverScript.solve_bfs(built.pieces, built.links)
	var steps: Array = []
	for move in solved.get("path", []):
		steps.append(SolutionStepScript.new(move.piece_id, float(move.target_rot), bool(move.released)))
	def.canonical_steps = steps
	def.par_moves = maxi(int(solved.get("moves", steps.size())), 1)
	if not bool(solved.get("solved", false)):
		push_warning("Campaign level %d has no solution." % int(def.level_id))
		def.par_moves = 1
	_free_nodes(built.pieces)

static func _spawn(def) -> Dictionary:
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

static func _free_nodes(pieces: Array) -> void:
	for piece in pieces:
		if is_instance_valid(piece):
			piece.free()
