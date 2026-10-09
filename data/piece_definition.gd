extends Resource
class_name PieceDefinition

# ----- Shape -----
enum ShapeType {
	CIRCLE = 0,
	ROUNDED_SQUARE = 1,
	ROUNDED_TRIANGLE = 2,
	OVAL = 3,
	STRAIGHT = 4,
	L_SHAPE = 5,
	PATH = 6,
}
@export var shape_type: ShapeType = ShapeType.CIRCLE

# ----- Motion -----
enum MotionModel {
	ROTATE = 0,
	SLIDE_AXIS_BIDIRECTIONAL = 1,
	SLIDE_AXIS_ONE_DIRECTION = 2,
	SLIDE_PATH = 3,
	FIXED = 4,
	SPECIAL = 5,
}
@export var motion_model: MotionModel = MotionModel.ROTATE
@export var motion_axis: Vector2 = Vector2.RIGHT     # axis (for SLIDE_AXIS_*)
@export var slide_min: float = -1000.0             # negative end along axis (units = pixels)
@export var slide_max: float = 1000.0             # positive end along axis (units = pixels)
@export var slide_path: PackedVector2Array = PackedVector2Array()   # for SLIDE_PATH
@export var special_params: Dictionary = {}       # for SPECIAL (engine-defined keys)

# ----- Role -----
enum PieceRole {
	NORMAL,
	ROOT_ANCHOR,
	HUB,
	EXIT,
	SPECIAL,
}
@export var role: PieceRole = PieceRole.NORMAL

# ----- Core authored ID -----
enum PieceType {
	CLOSED_CIRCLE,
	OPEN_CIRCLE,
	DUAL_GAP_CIRCLE,
}
@export var piece_type: PieceType = PieceType.OPEN_CIRCLE

@export var id: StringName = &"ring_0"

# ----- Geometry (canonical, ALL shape-specific fields live here) -----
@export var position: Vector2 = Vector2.ZERO         # center
@export var start_angle_deg: float = 90.0           # body rotation in world
# All-shape authoritative dimensions. Each shape ignores what it doesn't need.
@export var radius: float = 110.0                  # radius / outer extent (CIRCLE / OVAL_X / STRAIGHT_X / ROUNDED_SQUARE)
@export var radius_y: float = 110.0                # OVAL height (and any shape's other-axis)
@export var length: float = 0.0                    # STRAIGHT: length; L_SHAPE: primary arm length
@export var length_b: float = 0.0                  # L_SHAPE: secondary arm length
@export var width: float = 0.0                     # RECT/OPEN_FRAME width (authoring path)
@export var height: float = 0.0                    # RECT/OPEN_FRAME height
@export var corner_radius: float = 0.0             # ROUNDED_SQUARE / OPEN_FRAME corner radius
@export var thickness: float = 28.0               # stroke width on every shape
@export var path_points: PackedVector2Array = PackedVector2Array()  # PATH shape

@export var color: Color = Color("#00B4D8")

# ----- Gaps -----
# Authored OPEN shape: list of {center_angle_deg, width_deg, tolerance_deg}.
# Tolerance is the gameplay legality margin, separate from visible geometry.
@export var gaps: Array = []

# ----- Z-order / authoring flags -----
@export var z_index: int = 1
@export var initially_locked: bool = false
@export var locked: bool = false                          # runtime editor state (saved)
@export var release_direction: Vector2 = Vector2.RIGHT    # gameplay release-axis hint

# ----- Victory target -----
@export var target_exit_angle_deg: float = 0.0    # when relevant (some levels)

# ----- Helper enum kept for backwards compat -----
enum _DeprecatedShapeType { _K = 0 }

func _init(
	p_id: StringName = &"ring_0",
	p_pos: Vector2 = Vector2.ZERO,
	p_radius: float = 110.0,
	p_thickness: float = 28.0,
	p_color: Color = Color("#00B4D8"),
	p_start_angle: float = 90.0,
	p_gaps: Array = [],
	p_target_exit: float = 0.0,
	p_shape: ShapeType = ShapeType.CIRCLE,
	p_piece_type: PieceType = -1
) -> void:
	id = p_id
	position = p_pos
	radius = p_radius
	radius_y = p_radius      # sane default for non-OVAL shapes
	thickness = p_thickness
	color = p_color
	start_angle_deg = p_start_angle
	gaps = p_gaps
	target_exit_angle_deg = p_target_exit
	shape_type = p_shape

	# piece_type is the AUTHORED value. Section 11: never silently derive it
	# from gaps.size(). Callers that want the historical behavior pass an
	# explicit value (or -1 for "leave at the @export default OPEN_CIRCLE").
	# apply_dict() is the canonical JSON loader and sets this explicitly.
	if int(p_piece_type) >= 0:
		piece_type = p_piece_type


# Serialization helpers (used by editor + user-levels.gd to write JSON losslessly).
func to_dict() -> Dictionary:
	var path_ary := []
	for p in path_points:
		path_ary.append({"x": float(p.x), "y": float(p.y)})
	var slide_path_ary := []
	for sp in slide_path:
		slide_path_ary.append({"x": float(sp.x), "y": float(sp.y)})
	var gap_ary := []
	for g in gaps:
		if g is GapDefinition:
			gap_ary.append({
				"center_angle_deg": float(g.center_angle_deg),
				"width_deg": float(g.width_deg),
				"tolerance_deg": float(g.tolerance_deg),
			})
		elif g is Dictionary:
			gap_ary.append({
				"center_angle_deg": float(g.get("center_angle_deg", 0.0)),
				"width_deg": float(g.get("width_deg", 60.0)),
				"tolerance_deg": float(g.get("tolerance_deg", 16.0)),
			})
	return {
		"id": String(id),
		"color_name": PieceDefinition.color_name_static(color),
		"color_hex": PieceDefinition.color_hex_static(color),
		"shape_type": int(shape_type),
		"shape_name": _shape_name(shape_type),
		"motion_model": int(motion_model),
		"motion_axis": {"x": float(motion_axis.x), "y": float(motion_axis.y)},
		"slide_min": float(slide_min),
		"slide_max": float(slide_max),
		"slide_path": slide_path_ary,
		"special_params": special_params,
		"role": int(role),
		"piece_type": int(piece_type),
		"x": float(position.x),
		"y": float(position.y),
		"start_angle_deg": float(start_angle_deg),
		"radius": float(radius),
		"radius_y": float(radius_y),
		"length": float(length),
		"length_b": float(length_b),
		"width": float(width),
		"height": float(height),
		"corner_radius": float(corner_radius),
		"thickness": float(thickness),
		"path_points": path_ary,
		"z_index": int(z_index),
		"initially_locked": bool(initially_locked),
		"locked": bool(locked),
		"release_direction": {"x": float(release_direction.x), "y": float(release_direction.y)},
		"target_exit_angle_deg": float(target_exit_angle_deg),
		"gaps": gap_ary,
	}

func _shape_name(s: ShapeType) -> String:
	match s:
		ShapeType.CIRCLE: return "CIRCLE"
		ShapeType.ROUNDED_SQUARE: return "ROUNDED_SQUARE"
		ShapeType.ROUNDED_TRIANGLE: return "ROUNDED_TRIANGLE"
		ShapeType.OVAL: return "OVAL"
		ShapeType.STRAIGHT: return "STRAIGHT"
		ShapeType.L_SHAPE: return "L_SHAPE"
		ShapeType.PATH: return "PATH"
	return "CIRCLE"

static func color_name_static(c: Color) -> String:
	var palette := {
		"#ea7829": "orange",
		"#32adda": "cyan",
		"#7b61ff": "purple",
		"#e63946": "red",
		"#3ec6b0": "green",
		"#1f5a82": "cuff_blue",
		"#f4c95d": "yellow",
		"#f2a6b5": "pink",
	}
	var hex := c.to_html(false).to_lower()
	if palette.has(hex): return palette[hex]
	# 8-color name by RGB diff.
	var closest: String = "orange"
	var best_d: float = 9999.0
	for k in palette:
		var hex_clean: String = k.trim_prefix("#")
		var ri: int = int("0x" + hex_clean.substr(0, 2))
		var gi: int = int("0x" + hex_clean.substr(2, 2))
		var bi: int = int("0x" + hex_clean.substr(4, 2))
		var dr: float = absf(float(ri) / 255.0 - c.r)
		var dg: float = absf(float(gi) / 255.0 - c.g)
		var db: float = absf(float(bi) / 255.0 - c.b)
		var d: float = dr + dg + db
		if d < best_d:
			best_d = d
			closest = palette[k]
	return closest

static func color_hex_static(c: Color) -> String:
	var r := int(round(c.r * 255))
	var g := int(round(c.g * 255))
	var b := int(round(c.b * 255))
	return "#%02X%02X%02X" % [r, g, b]

# Convert a hex / palette name into a Godot Color. Used by JSON loaders.
static func color_hex_static_to_color(hex: String, palette_name: String) -> Color:
	if hex != "" and hex != "#00000000":
		if Color.html_is_valid(hex):
			return Color(hex)
	var palette := {
		"orange": Color("#EA7829"),
		"cyan":   Color("#32ADDA"),
		"purple": Color("#7B61FF"),
		"red":    Color("#E63946"),
		"green":  Color("#3EC6B0"),
		"cuff_blue": Color("#1F5A82"),
		"yellow": Color("#F4C95D"),
		"pink":   Color("#F2A6B5"),
		"transparent": Color(0.0, 0.0, 0.0, 0.0),
	}
	if palette.has(palette_name): return palette[palette_name]
	return palette["orange"]

# Apply a serialized dictionary (produced by to_dict()) onto this piece.
# Preserves every authored property. This is the canonical JSON load path.
func apply_dict(d: Dictionary) -> void:
	id = StringName(String(d.get("id", "piece")))
	color = color_hex_static_to_color(
		String(d.get("color_hex", "#EA7829")),
		String(d.get("color_name", "orange"))
	)
	shape_type = int(d.get("shape_type", 0))
	motion_model = int(d.get("motion_model", 0))
	if d.has("motion_axis"):
		var ma: Variant = d["motion_axis"]
		if ma is Dictionary:
			motion_axis = Vector2(float(ma.get("x", 1.0)), float(ma.get("y", 0.0)))
	slide_min = float(d.get("slide_min", -1000.0))
	slide_max = float(d.get("slide_max", 1000.0))
	if d.has("slide_path"):
		var spp: Variant = d["slide_path"]
		if spp is Array:
			var new_path: PackedVector2Array = PackedVector2Array()
			for sp in spp:
				if sp is Dictionary:
					new_path.append(Vector2(float(sp.get("x", 0.0)), float(sp.get("y", 0.0))))
			slide_path = new_path
	if d.has("special_params"):
		var sp2: Variant = d["special_params"]
		if sp2 is Dictionary:
			special_params = sp2
	role = int(d.get("role", 0))
	# piece_type: only override if explicitly present in the JSON. Otherwise
	# keep the default (which the constructor set). Section 11 forbids silent
	# conversion between authored and inferred values.
	if d.has("piece_type"):
		piece_type = int(d["piece_type"])
	position = Vector2(float(d.get("x", 0.0)), float(d.get("y", 0.0)))
	start_angle_deg = float(d.get("start_angle_deg", 90.0))
	radius = float(d.get("radius", 110.0))
	radius_y = float(d.get("radius_y", float(d.get("radius", 110.0))))
	length = float(d.get("length", 0.0))
	length_b = float(d.get("length_b", 0.0))
	width = float(d.get("width", 0.0))
	height = float(d.get("height", 0.0))
	corner_radius = float(d.get("corner_radius", 0.0))
	thickness = float(d.get("thickness", 28.0))
	if d.has("path_points"):
		var pp: Variant = d["path_points"]
		if pp is Array:
			var new_path2: PackedVector2Array = PackedVector2Array()
			for pp_i in pp:
				if pp_i is Dictionary:
					new_path2.append(Vector2(float(pp_i.get("x", 0.0)), float(pp_i.get("y", 0.0))))
			path_points = new_path2
	z_index = int(d.get("z_index", d.get("z", 1)))
	initially_locked = bool(d.get("initially_locked", false))
	locked = bool(d.get("locked", false))
	if d.has("release_direction"):
		var rd: Variant = d["release_direction"]
		if rd is Dictionary:
			release_direction = Vector2(float(rd.get("x", 1.0)), float(rd.get("y", 0.0)))
	target_exit_angle_deg = float(d.get("target_exit_angle_deg", 0.0))
	# Gaps: read the "gaps" array if present (modern format). Otherwise fall back
	# to legacy single-gap keys ("closed"/"gap_deg"/"gap_center_deg").
	var gaps_in = d.get("gaps", null)
	var new_gaps: Array = []
	if gaps_in is Array and gaps_in.size() > 0:
		for g in gaps_in:
			if g is Dictionary:
				new_gaps.append(GapDefinition.from_dict(g))
		gaps = new_gaps
	elif gaps_in == null:
		# Legacy: either closed, or has a single global gap_deg.
		var is_closed := bool(d.get("closed", false))
		if not is_closed:
			var gd := GapDefinition.from_dict({
				"center_angle_deg": float(d.get("gap_center_deg", float(d.get("gap_deg", 270.0)))),
				"width_deg": float(d.get("gap_width_deg", 80.0)),
				"tolerance_deg": float(d.get("gap_tolerance_deg", 16.0)),
			})
			gaps = [gd]
		else:
			gaps = []
	# Sanity check: flag (without rewriting) the common authoring slip of
	# DUAL_GAP_CIRCLE with one gap, OPEN_CIRCLE with zero, etc. Silent
	# downstream failures cost more than a one-line warning at load time.
	if d.has("piece_type"):
		var gap_count_now := gaps.size()
		if int(piece_type) == int(PieceType.DUAL_GAP_CIRCLE) and gap_count_now != 2:
			push_warning("PieceDefinition.load: id=%s claims DUAL_GAP_CIRCLE but has %d gap(s)" % [String(id), gap_count_now])
		elif int(piece_type) == int(PieceType.OPEN_CIRCLE) and gap_count_now != 1:
			push_warning("PieceDefinition.load: id=%s claims OPEN_CIRCLE but has %d gap(s)" % [String(id), gap_count_now])
		elif int(piece_type) == int(PieceType.CLOSED_CIRCLE) and gap_count_now != 0:
			push_warning("PieceDefinition.load: id=%s claims CLOSED_CIRCLE but has %d gap(s)" % [String(id), gap_count_now])
	# piece_type was already set from d.piece_type if present. No mirroring
	# to preserve authored values per Section 11.
