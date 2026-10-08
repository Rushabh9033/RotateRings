extends RefCounted

const LevelDefinitionScript = preload("res://data/level_definition.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")
const LinkDefinitionScript = preload("res://data/link_definition.gd")

const SHAPE_CIRCLE := 0
const SHAPE_ROUNDED_SQUARE := 1

const COLOR_TABLE := {
	"orange":   Color("#EA7829"),
	"cyan":     Color("#32ADDA"),
	"purple":   Color("#7B61FF"),
	"red":      Color("#E63946"),
	"green":    Color("#3EC6B0"),
	"blue":     Color("#32ADDA"),
	"cuff_blue": Color("#1F5A82"),
	"yellow":   Color("#F4C95D"),
	"pink":     Color("#F2A6B5"),
    "transparent": Color("#00000000")
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

static func _build_piece(d: Dictionary):
	var col: Color = _resolve_color(d)
	var rad := float(d.get("radius", 80))
	var thick := float(d.get("thickness", 22))
	var g0 := float(d.get("gap_deg", 270.0))
	var is_closed := bool(d.get("closed", false))
	var shape_str := String(d.get("shape", "CIRCLE"))
	var shape := SHAPE_CIRCLE if shape_str == "CIRCLE" else SHAPE_ROUNDED_SQUARE
	var gaps: Array = []
	if not is_closed:
		gaps.append(GapDefinitionScript.new(0.0, 80.0, 16.0))
	var pos := Vector2(float(d.get("x", 0)), float(d.get("y", 0)))
	var p = PieceDefinitionScript.new(
		StringName(String(d.get("id", "piece"))),
		pos,
		rad, thick, col,
		g0,
		gaps,
		0.0,
		shape
	)
	if d.has("role"):
		p.role = int(d["role"])
	return p

static func _build_link(d: Dictionary):
	var cuff: Color = _resolve_color_dict(d, "cuff_color_name", "cuff_color_hex", "orange")
	var link_id: String = String(d.get("id", "link_"))
	if link_id == "link_":
		link_id = "link_%s_%s" % [d.get("from_id", "x"), d.get("to_id", "y")]
	return LinkDefinitionScript.new(
		StringName(link_id),
		StringName(String(d.get("from_id", "ring_a"))),
		StringName(String(d.get("to_id", "ring_b"))),
		cuff, 0.0, 0.0
	)

static func _resolve_color(d: Dictionary) -> Color:
	return _resolve_color_dict(d, "color_name", "color_hex", "orange")

static func _resolve_color_dict(d: Dictionary, name_key: String, hex_key: String, default_name: String) -> Color:
	var n: String = String(d.get(name_key, default_name))
	if COLOR_TABLE.has(n):
		return COLOR_TABLE[n]
	var hex := String(d.get(hex_key, ""))
	if hex != "":
		if Color.html_is_valid(hex): return Color(hex)
	return COLOR_TABLE[default_name]

static func _estimate_par_moves(piece_count: int) -> int:
	if piece_count <= 0: return 1
	return clamp(piece_count / 2 + 1, 1, 8)
