extends RefCounted

# JSON loader for `data/user_levels/<n>.json` files. Round-trips losslessly with
# PieceDefinition.to_dict() / apply_dict() and LinkDefinition.to_dict() /
# from_dict(). Each JSON file is one level.

const LevelDefinitionScript = preload("res://data/level_definition.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")
const LinkDefinitionScript = preload("res://data/link_definition.gd")

const SHAPE_CIRCLE := 0
const SHAPE_ROUNDED_SQUARE := 1

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
	var def = LevelDefinitionScript.new()
	def.level_id = int(data.get("id", level_id))
	def.chapter_id = 1
	def.title = String(data.get("title", "Level %d" % def.level_id))
	def.instruction = ""
	def.par_moves = _estimate_par_moves(int(data.get("pieces", []).size()))
	def.theme_id = &"porcelain"

	var pieces: Array = []
	for piece_data in data.get("pieces", []):
		pieces.append(_build_piece(piece_data))
	def.pieces = pieces

	var links: Array = []
	for link_data in data.get("links", []):
		links.append(_build_link(link_data))
	def.links = links
	return def

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
