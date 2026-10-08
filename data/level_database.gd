extends Resource
class_name LevelDatabase

const LevelDefinitionScript = preload("res://data/level_definition.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")
const LinkDefinitionScript = preload("res://data/link_definition.gd")
const CampaignBoardScript = preload("res://data/campaign_board.gd")
const ExtractedLevelsScript = preload("res://data/extracted_levels.gd")
const UserLevelsScript = preload("res://data/user_levels.gd")
const RingVisualsScript = preload("res://data/ring_visuals.gd")

# === Authored levels (all 1..100) ===
const HIGHEST_DEFINED_LEVEL: int = 100

# All public API is static — callers in save_service.gd / scene_router.gd /
# test_level_contract.gd expect to invoke these without instantiating the class.
# This matches the pre-existing convention used before this session.

static func is_level_playable(level_id: int) -> bool:
	if ExtractedLevelsScript != null:
		var def = ExtractedLevelsScript.build(level_id)
		if def != null:
			return true
	if level_id == 1:
		return true  # Level 1 is the pixel-accurate reference reconstruction
	return level_id >= 1 and level_id <= HIGHEST_DEFINED_LEVEL

static func get_max_playable_level() -> int:
	var m := 0
	for lid in range(1, HIGHEST_DEFINED_LEVEL + 1):
		if is_level_playable(lid) and lid > m:
			m = lid
	return m

static func get_next_playable_level(current_id: int) -> int:
	for i in range(current_id + 1, HIGHEST_DEFINED_LEVEL + 2):
		if is_level_playable(i):
			return i
	return 0

static func get_total_levels() -> int:
	return HIGHEST_DEFINED_LEVEL

# === Compatibility stubs for the pre-existing test suite (tools/test_level_contract.gd).
# These methods were removed during earlier refactors. The test file calls them
# statically; adding back the minimal API keeps the parse chain intact. ===

static func is_level_defined(level_id: int) -> bool:
	return is_level_playable(level_id) or (level_id >= 1 and level_id <= HIGHEST_DEFINED_LEVEL)

static func get_playable_level_ids() -> Array[int]:
	var out: Array[int] = []
	for lid in range(1, HIGHEST_DEFINED_LEVEL + 1):
		if is_level_playable(lid):
			out.append(lid)
	return out

static func get_defined_level_count() -> int:
	var n := 0
	for lid in range(1, HIGHEST_DEFINED_LEVEL + 1):
		if get_level(lid) != null:
			n += 1
	return n

static func get_playable_level_count() -> int:
	return get_playable_level_ids().size()

static func get_level(level_id: int):
	# Priority order (first hit wins):
	#  1. User-authored JSON in data/user_levels/<n>.json — written by the
	#     in-game level editor (scenes/level_editor/LevelEditor.tscn).
	#  2. Hard-coded overrides for Level 1 and Level 2 (hand-authored).
	#  3. extracted_levels.gd builtins (Levels 56+ from image extraction).
	#  4. Campaign pipeline authored structure (Levels 3..100).
	if UserLevelsScript != null:
		var u = UserLevelsScript.build(level_id)
		if u != null: return u
	if level_id == 1:
		return _build_level_one_reference()
	if level_id == 2:
		return _build_level_two_reference()
	if ExtractedLevelsScript != null:
		var ex = ExtractedLevelsScript.build(level_id)
		if ex != null: return ex
	# Fall back to the authored campaign board for all other levels.
	if CampaignBoardScript != null:
		return CampaignBoardScript.build(level_id)
	return null

# Level 1: two open C-rings; one chunky cuff = the connector between them.
# Values picked so Level 1 matches the rest of the campaign visually:
#   RING_RADIUS         = 90  (data/ring_visuals.gd)
#   RING_THICKNESS      = 18  (data/ring_visuals.gd)
#   GAP_DEG             = 60  (data/ring_visuals.gd)
#   palette[0]          = #32ADDA  blue ring
#   palette[1]          = #EA7829  orange ring
#   cuff TANGENTIAL_WIDTH=32, RADIAL_DEPTH=18  (gameplay/connector_runtime.gd)
# Cuff drawing itself lives in puzzle_controller._on_cuffs_layer_draw —
# the chunky rounded block in the reference image is exactly what the
# engine already draws at the link's mid-point.
#
# Cuff sleeve color is #32ADDA — SAME as the blue ring (NOT a darker tone).
# Rings sit close together so the cuff dominates the visible connector,
# not a long stem-line.
static func _build_level_one_reference() -> LevelDefinition:
	var def = LevelDefinitionScript.new()
	def.level_id = 1
	def.chapter_id = 1
	def.title = "Twin Cuffs"
	def.instruction = "Rotate each ring until its gap faces outward."
	def.par_moves = 2
	def.theme_id = &"porcelain"

	const COLOR_BLUE: Color = Color("#32ADDA")     # palette[0]
	const COLOR_ORANGE: Color = Color("#EA7829")   # palette[1]
	const CUFF_COLOR: Color = Color("#32ADDA")

	const RADIUS: float = 90.0
	const THICKNESS: float = 18.0
	const GAP_DEG: float = 60.0

	var gap = [GapDefinitionScript.new(0.0, GAP_DEG, 16.0)]

	var root_anchor := PieceDefinitionScript.new(
		&"root_anchor", Vector2(360.0, 560.0),
		0.0, 1.0, Color.TRANSPARENT, 0.0, [], 0.0,
		PieceDefinitionScript.ShapeType.CIRCLE
	)
	root_anchor.role = PieceDefinitionScript.PieceRole.ROOT_ANCHOR

	var blue_ring := PieceDefinitionScript.new(
		&"ring_left", Vector2(260.0, 560.0),
		RADIUS, THICKNESS, COLOR_BLUE, 180.0, gap, 0.0,
		PieceDefinitionScript.ShapeType.CIRCLE
	)
	var orange_ring := PieceDefinitionScript.new(
		&"ring_right", Vector2(460.0, 560.0),
		RADIUS, THICKNESS, COLOR_ORANGE, 0.0, gap, 0.0,
		PieceDefinitionScript.ShapeType.CIRCLE
	)

	def.pieces = [root_anchor, blue_ring, orange_ring]

	var link1 := LinkDefinitionScript.new(
		&"link_root_to_blue", &"root_anchor", &"ring_left",
		CUFF_COLOR, 0.0, 100.0
	)
	var link2 := LinkDefinitionScript.new(
		&"link_root_to_orange", &"root_anchor", &"ring_right",
		CUFF_COLOR, 0.0, 100.0
	)
	def.links = [link1, link2]
	return def

# Level 2 — GRID-aligned layout. Treats the 720x1280 canvas as a coordinate
# grid (canvas-relative, not radial). Authored positions place each ring at
# measured coordinates (from tools/measure_level2.py on 2.jpeg). Rings of
# equal radius (no per-ring size variation), positioned so inner edges have a
# small breathing gap (~12 px) where the chunky 32x18 cuff draws between them.
#
# Layout (canvas 720x1280):
#   orange at (270, 540), radius 80  →  bbox x ∈ [180, 360],  y ∈ [450, 630]
#   cyan   at (450, 540), radius 80  →  bbox x ∈ [360, 540],  y ∈ [450, 630]
#   purple at (360, 700), radius 80  →  bbox x ∈ [270, 450],  y ∈ [610, 790]
#
# Inner-edge distances (with thickness=18 → outer radius=89):
#   orange right edge = 270+89 = 359
#   cyan   left  edge = 450-89 = 361  → gap = 2 px at top of cluster
#   orange lower edge = 540+89 = 629
#   purple upper edge = 700-89 = 611  → overlap of 18 px → lower cuff clamps inside
#
# The composite cluster sits in y=450..790, h=340 px. The canvas's visible
# play area is roughly y=200..1080 (h=880) — cluster occupies ~39% of the
# play area's height, centered vertically at the cluster midpoint y=620.
#
# Gap directions per ring (so each gap faces AWAY from BOTH its connectors):
#   orange  → gap world direction = 270° (UP). Connectors emerge at right &
#             lower-right, so up is the safe orientation.
#   cyan    → gap world direction =  90° (DOWN). Connector emerges at left.
#   purple  → gap world direction = 270° (UP). Connector emerges at top.
#
# Cuff colors match the destination ring color, like the reference image:
#   link orange→cyan   joint_color = orange
#   link orange→purple joint_color = purple
static func _build_level_two_reference() -> LevelDefinition:
	var def = LevelDefinitionScript.new()
	def.level_id = 2
	def.chapter_id = 1
	def.title = "Three Cuffs"
	def.instruction = "Rotate orange to release the others."
	def.par_moves = 3
	def.theme_id = &"porcelain"

	const COLOR_ORANGE: Color = Color("#EA7829")
	const COLOR_CYAN: Color = Color("#32ADDA")
	const COLOR_PURPLE: Color = Color("#7B61FF")
	const CUFF_ORANGE: Color = Color("#EA7829")
	const CUFF_PURPLE: Color = Color("#7B61FF")

	const RADIUS: float = 88.0
	const THICKNESS: float = 22.0
	const GAP_DEG: float = 100.0     # wider gap so cuff seats cleanly into opening

	var orange_ring := PieceDefinitionScript.new(
		&"ring_orange", Vector2(260.0, 510.0),
		RADIUS, THICKNESS, COLOR_ORANGE, 270.0,
		[GapDefinitionScript.new(0.0, GAP_DEG, 16.0)],
		0.0, PieceDefinitionScript.ShapeType.CIRCLE
	)
	var cyan_ring := PieceDefinitionScript.new(
		&"ring_cyan", Vector2(460.0, 510.0),
		RADIUS, THICKNESS, COLOR_CYAN, 90.0,
		[GapDefinitionScript.new(0.0, GAP_DEG, 16.0)],
		0.0, PieceDefinitionScript.ShapeType.CIRCLE
	)
	var purple_ring := PieceDefinitionScript.new(
		&"ring_purple", Vector2(360.0, 680.0),
		RADIUS, THICKNESS, COLOR_PURPLE, 270.0,
		[GapDefinitionScript.new(0.0, GAP_DEG, 16.0)],
		0.0, PieceDefinitionScript.ShapeType.CIRCLE
	)

	def.pieces = [orange_ring, cyan_ring, purple_ring]

	# Two CHAIN links. placeholder stem_dist is inert — bind_connector
	# recomputes from actual piece positions.
	def.links = [
		LinkDefinitionScript.new(&"link_oc", &"ring_orange", &"ring_cyan",   CUFF_ORANGE, 0.0, 200.0),
		LinkDefinitionScript.new(&"link_op", &"ring_orange", &"ring_purple", CUFF_PURPLE, 0.0, 200.0),
	]
	return def

