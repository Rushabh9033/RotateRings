extends RefCounted

# JSON loader for `data/user_levels/<n>.json` files. Round-trips losslessly with
# PieceDefinition.to_dict() / apply_dict() and LinkDefinition.to_dict() /
# from_dict(). Each JSON file is one level.
#
# =============================================================================
# SUPPORTED SCHEMAS
# =============================================================================
# 1. MODERN / FULL (default): Pieces and links are explicit RotateRings
#    dictionaries. See PieceDefinition.to_dict() / LinkDefinition.to_dict().
#
# 2. RINGS-CLIPS (compact): Human-readable alternative with a `rings` array
#    and inline `clips` per ring. Designed for rapid level design. The
#    loader auto-translates to the full schema, so the engine doesn't
#    need to know about this format.
#
#    Top-level shape:
#      {
#        "level": 2,
#        "title": "...",
#        "theme_id": "porcelain",
#        "rings": [
#          {
#            "id": "orange_ring",
#            "color": "#F08C3A",            // any hex; auto-snapped to palette
#            "x": -60, "y": -40,             // origin-centered; auto-offset
#                                            //   by (360, 640)
#            "radius": 50,
#            "thickness": 21,                // optional; default 21
#            "gap": { "start": 140, "end": 220 },  // wraps mod 360
#            "rotation": 0,                  // optional; default 0
#            "clips": [                      // optional; default []
#              { "target_id": "blue_ring",
#                "anchor_angle": 0 }         // optional; auto-computed
#                                            //   if missing
#            ]
#          },
#          ...
#        ]
#      }
#
#    If the JSON has a top-level "rings" array, build() routes through
#    _build_from_rings_clips(). Otherwise it routes through the modern
#    path. The two paths produce identical LevelDefinitions.
# =============================================================================

const LevelDefinitionScript = preload("res://data/level_definition.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")
const LinkDefinitionScript = preload("res://data/link_definition.gd")

const SHAPE_CIRCLE := 0
const SHAPE_ROUNDED_SQUARE := 1

# Default canvas offset: rings-clips uses origin (0,0) as puzzle center.
# RotateRings canonical canvas is 720x1280, so add (360, 640).
const CANVAS_OFFSET := Vector2(360.0, 640.0)

# Default thickness when rings-clips JSON omits it.
const DEFAULT_THICKNESS := 21.0

# Default cuff / stem geometry (matches the converted L2.json values).
const DEFAULT_CUFF_WIDTH := 32.0
const DEFAULT_CUFF_DEPTH := 18.0
const DEFAULT_CUFF_ROUND_RADIUS := 5.0
const DEFAULT_STEM_WIDTH := 6.0
const DEFAULT_CLEARANCE_TOLERANCE_DEG := 16.0

# Color name → hex (kept for backwards compat with legacy JSON that didn't store
# both name and hex. New writes store both; new reads prefer hex.)
const COLOR_TABLE := {
	"orange":     Color("#EA7829"),
	"cyan":       Color("#32ADDA"),
	"purple":     Color("#7B61FF"),
	"red":        Color("#E63946"),
	"green":      Color("#3EC6B0"),
	"blue":       Color("#32ADDA"),
	"cuff_blue":  Color("#1F5A82"),
	"yellow":     Color("#F4C95D"),
	"pink":       Color("#F2A6B5"),
	"transparent": Color(0.0, 0.0, 0.0, 0.0),
}

# Palette hex values that the engine recognizes (post-fix for the
# color_name_static "#xxx" vs "xxx" mismatch). When a rings-clips JSON
# specifies an arbitrary color, we snap to the nearest palette entry by
# RGB Euclidean distance.
const PALETTE_HEX := [
	"#EA7829",  # orange
	"#32ADDA",  # cyan
	"#7B61FF",  # purple
	"#E63946",  # red
	"#3EC6B0",  # green
	"#1F5A82",  # cuff_blue
	"#F4C95D",  # yellow
	"#F2A6B5",  # pink
]

const PALETTE_NAMES := {
	"#EA7829": "orange",
	"#32ADDA": "cyan",
	"#7B61FF": "purple",
	"#E63946": "red",
	"#3EC6B0": "green",
	"#1F5A82": "cuff_blue",
	"#F4C95D": "yellow",
	"#F2A6B5": "pink",
}


# =============================================================================
# Entry point
# =============================================================================

static func build(level_id: int):
	var path := "res://data/user_levels/%d.json" % level_id
	if not FileAccess.file_exists(path):
		return null
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return null
	var text := f.get_as_text()
	f.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return null
	var data: Dictionary = parsed

	# Schema routing.
	if data.has("rings") and not data.has("pieces"):
		return _build_from_rings_clips(level_id, data)
	return _build_modern(level_id, data)


# =============================================================================
# Modern schema (unchanged behavior)
# =============================================================================

static func _build_modern(level_id: int, data: Dictionary):
	var def = LevelDefinitionScript.new()
	def.level_id = int(data.get("id", level_id))
	def.chapter_id = 1
	def.title = String(data.get("title", "Level %d" % def.level_id))
	def.instruction = String(data.get("instruction", ""))
	def.par_moves = int(data.get("par_moves", _estimate_par_moves(
		int(data.get("pieces", []).size()))))
	def.theme_id = StringName(String(data.get("theme_id", "porcelain")))

	var pieces: Array = []
	for piece_data in data.get("pieces", []):
		pieces.append(_build_piece(piece_data))
	def.pieces = pieces

	var links: Array = []
	for link_data in data.get("links", []):
		links.append(_build_link(link_data))
	def.links = links
	return def


# =============================================================================
# Rings-clips schema: auto-translated to the modern schema
# =============================================================================

static func _build_from_rings_clips(level_id: int, data: Dictionary):
	var def = LevelDefinitionScript.new()
	def.level_id = int(data.get("level", level_id))
	def.chapter_id = 1
	def.title = String(data.get("title", "Level %d" % def.level_id))
	def.instruction = ""
	def.par_moves = int(data.get("par_moves", _estimate_par_moves(
		int(data.get("rings", []).size()))))
	def.theme_id = StringName(String(data.get("theme_id", "porcelain")))

	# Pass 1: build pieces + capture their palette-pinned color metadata.
	var rings: Array = data.get("rings", [])
	var pieces: Array = []
	var ring_by_id: Dictionary = {}  # rings-clips id -> {pos, radius, ...}
	var link_counter: int = 0
	for ring_data in rings:
		var id := StringName(String(ring_data.get("id", "ring_%d" % pieces.size())))
		var pinned_hex := _snap_to_palette_hex(String(ring_data.get("color", "#EA7829")))
		var color_name := String(PALETTE_NAMES.get(pinned_hex, "orange"))
		var pos := _rings_clips_position(ring_data)
		var radius := float(ring_data.get("radius", 50.0))
		var thickness := float(ring_data.get("thickness", DEFAULT_THICKNESS))
		var start_angle := float(ring_data.get("rotation", 0.0))
		var gap := _rings_clips_gap(ring_data)
		var p = PieceDefinitionScript.new()
		p.id = id
		p.color = COLOR_TABLE.get(color_name, Color(pinned_hex))
		p.position = pos
		p.radius = radius
		p.radius_y = radius
		p.thickness = thickness
		p.start_angle_deg = start_angle
		p.shape_type = SHAPE_CIRCLE
		p.piece_type = PieceDefinitionScript.PieceType.OPEN_CIRCLE
		p.gaps = [gap]
		p.release_direction = Vector2(1, 0)
		p.target_exit_angle_deg = 0.0
		p.z_index = 1
		pieces.append(p)
		ring_by_id[String(id)] = {
			"pos": pos,
			"radius": radius,
			"index": pieces.size() - 1,
		}

	# Pass 2: build links with auto-computed geometry.
	var links: Array = []
	for ring_data in rings:
		var from_id := String(ring_data.get("id", ""))
		if from_id == "" or not ring_by_id.has(from_id):
			continue
		var parent: Dictionary = ring_by_id[from_id]
		for clip_data in ring_data.get("clips", []):
			var target_id := String(clip_data.get("target_id", ""))
			if target_id == "" or not ring_by_id.has(target_id):
				continue
			var child: Dictionary = ring_by_id[target_id]
			var link = _rings_clips_link(from_id, target_id,
				parent, child, link_counter, clip_data)
			links.append(link)
			link_counter += 1

	def.pieces = pieces
	def.links = links
	return def


static func _rings_clips_position(ring_data: Dictionary) -> Vector2:
	"""Origin-centered (x, y) -> canvas-centered position."""
	return Vector2(float(ring_data.get("x", 0.0)),
					float(ring_data.get("y", 0.0))) + CANVAS_OFFSET


static func _rings_clips_gap(ring_data: Dictionary) -> Resource:
	"""Translate {start, end} (mod 360) to GapDefinition(center, width)."""
	var gap_data = ring_data.get("gap", null)
	if gap_data == null or typeof(gap_data) != TYPE_DICTIONARY:
		# Closed ring fallback (no gap).
		return null
	var start_deg := float(gap_data.get("start", 0.0))
	var end_deg := float(gap_data.get("end", 0.0))
	# Width = (end - start) mod 360, in [0, 360).
	var width_deg := fmod(end_deg - start_deg, 360.0)
	if width_deg < 0.0:
		width_deg += 360.0
	# Center = (start + width/2) mod 360.
	var center_deg := fmod(start_deg + width_deg * 0.5, 360.0)
	if center_deg < 0.0:
		center_deg += 360.0
	var tol_deg := float(gap_data.get("tolerance_deg", 16.0))
	return GapDefinitionScript.new(center_deg, width_deg, tol_deg)


static func _rings_clips_link(from_id: String, to_id: String,
		parent: Dictionary, child: Dictionary, link_counter: int,
		clip_data: Dictionary = {}) -> Resource:
	"""Build a LinkDefinition with auto-computed geometry from
	parent.pos + child.pos + (optional) anchor_angle.

	Computes:
	  collar_angle_deg = atan2(child.pos - parent.pos)  (default)
	                  or  clip_data.anchor_angle          (if provided)
	  stem_dist = |child.pos - parent.pos| / 2
	  stem_length = stem_dist * 2
	  cuff_center_local = (0, 0)  (auto-placed at runtime via stem_dist)
	"""
	var parent_pos: Vector2 = parent["pos"]
	var child_pos: Vector2 = child["pos"]
	var dx := child_pos.x - parent_pos.x
	var dy := child_pos.y - parent_pos.y
	var distance := sqrt(dx * dx + dy * dy)
	var auto_angle := atan2(dy, dx) * 180.0 / PI
	var collar := auto_angle
	# If clip_data supplies an anchor_angle, prefer it (the rings-clips
	# format lets the designer override the auto angle).
	if clip_data.has("anchor_angle"):
		collar = float(clip_data["anchor_angle"])
	var stem_dist := distance * 0.5
	var stem_length := distance
	# Construct with the 6-arg constructor.
	var ld = LinkDefinitionScript.new(
		StringName("link_rc_%d" % link_counter),
		StringName(from_id),
		StringName(to_id),
		COLOR_TABLE["cuff_blue"],
		collar,        # collar_angle_deg
		stem_dist,     # stem_dist
	)
	ld.cuff_orientation_deg = collar
	ld.cuff_width = DEFAULT_CUFF_WIDTH
	ld.cuff_depth = DEFAULT_CUFF_DEPTH
	ld.cuff_round_radius = DEFAULT_CUFF_ROUND_RADIUS
	ld.stem_length = stem_length
	ld.stem_width = DEFAULT_STEM_WIDTH
	ld.stem_distance_from_piece = stem_dist
	ld.clearance_tolerance_deg = DEFAULT_CLEARANCE_TOLERANCE_DEG
	ld.is_detached = false
	ld.z_index = 0
	return ld


# =============================================================================
# Color palette pinning (bypasses color_name_static #xxx bug)
# =============================================================================

static func _snap_to_palette_hex(input_hex: String) -> String:
	"""Snap an arbitrary hex to the closest supported palette entry.

	The engine's color_name_static has a bug where palette keys are
	"#xxx" but c.to_html(false) returns "xxx", so non-palette colors
	fall back to "orange" silently. We work around by snapping to the
	nearest palette entry via Euclidean distance in RGB.
	"""
	var h := input_hex.strip_edges()
	if h == "":
		return "#EA7829"
	if h[0] != "#":
		h = "#" + h
	if Color.html_is_valid(h):
		return _closest_palette_hex(h)
	return "#EA7829"


static func _closest_palette_hex(input_hex: String) -> String:
	var c := Color(input_hex)
	var best_hex := "#EA7829"
	var best_d := INF
	for ph in PALETTE_HEX:
		var p := Color(ph)
		var dr := c.r - p.r
		var dg := c.g - p.g
		var db := c.b - p.b
		var d := dr * dr + dg * dg + db * db
		if d < best_d:
			best_d = d
			best_hex = ph
	return best_hex


# =============================================================================
# Lossless piece / link builders (modern schema, unchanged)
# =============================================================================

# Lossless piece build. Reads the full schema's keys; falls back to the
# legacy 9-arg constructor only if the JSON predates the schema upgrade.
static func _build_piece(d: Dictionary):
	var p = PieceDefinitionScript.new()
	if d.has("shape_type") or d.has("radius") or d.has("id"):
		# Modern format → apply_dict round-trip.
		(p as PieceDefinitionScript).apply_dict(d)
		return p
	# Legacy fallback (very old saved JSON).
	var is_closed := bool(d.get("closed", false))
	var g0 := float(d.get("gap_deg", 270.0))
	var rad := float(d.get("radius", 80.0))
	var thick := float(d.get("thickness", 22.0))
	var pos := Vector2(float(d.get("x", 0)), float(d.get("y", 0)))
	var col: Color = _resolve_color(d)
	var p2 = PieceDefinitionScript.new(
		StringName(String(d.get("id", "piece"))),
		pos, rad, thick, col, g0,
		[] if is_closed else [GapDefinitionScript.new(0.0, 80.0, 16.0)],
		0.0, PieceDefinitionScript.ShapeType.CIRCLE
	)
	if d.has("role"):
		p2.role = int(d["role"])
	return p2

static func _build_link(d: Dictionary):
	return LinkDefinitionScript.from_dict(d)

static func _resolve_color(d: Dictionary) -> Color:
	return _resolve_color_dict(d, "color_name", "color_hex", "orange")

static func _resolve_color_dict(d: Dictionary, name_key: String, hex_key: String, default_name: String) -> Color:
	var n: String = String(d.get(name_key, default_name))
	if COLOR_TABLE.has(n): return COLOR_TABLE[n]
	var hex := String(d.get(hex_key, ""))
	if hex != "" and hex != "#00000000":
		if Color.html_is_valid(hex): return Color(hex)
	return COLOR_TABLE[default_name]

static func _estimate_par_moves(piece_count: int) -> int:
	if piece_count <= 0: return 1
	return clamp(piece_count / 2 + 1, 1, 8)