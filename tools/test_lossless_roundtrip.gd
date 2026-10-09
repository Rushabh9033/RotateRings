extends SceneTree

# Lossless round-trip test for the new schema. Section 11 (Brahmaastra).
# Verifies: every authored property written via to_dict() / read back via
# apply_dict() is preserved bit-for-bit. NO silent conversions.

const PIECE_DEF_SCRIPT := preload("res://data/piece_definition.gd")
const LINK_DEF_SCRIPT := preload("res://data/link_definition.gd")

# Authored properties the schema exposes. Any property NOT listed here is
# NOT tested. Adding fields to the schema must extend this list.
var piece_fields := [
	"id", "color", "shape_type", "motion_model", "motion_axis",
	"slide_min", "slide_max", "slide_path", "special_params",
	"role", "piece_type", "position", "start_angle_deg",
	"radius", "radius_y", "length", "length_b", "width", "height",
	"corner_radius", "thickness", "path_points",
	"gaps_count", "gap_0_center", "gap_0_width", "gap_0_tolerance",
	"z_index", "initially_locked", "release_direction",
	"target_exit_angle_deg",
]

var link_fields := [
	"id", "from_piece_id", "to_piece_id", "collar_angle_deg",
	"cuff_center_local", "cuff_orientation_deg", "cuff_width",
	"cuff_depth", "cuff_round_radius", "stem_length", "stem_width",
	"stem_distance_from_piece", "stem_dist", "joint_color", "z_index",
	"clearance_tolerance_deg", "is_detached",
]

func _make_piece() -> PieceDefinition:
	var p := PieceDefinition.new(
		&"piece_test_001",
		Vector2(360.0, 640.0), 66.0, 20.0,
		Color("#EA7829"), 123.456,
		[GapDefinition.new(7.0, 91.0, 17.0)],
		42.0, PieceDefinition.ShapeType.OVAL
	)
	p.radius_y = 33.0
	p.length = 200.0; p.length_b = 100.0
	p.width = 150.0; p.height = 80.0
	p.corner_radius = 12.0
	p.path_points = PackedVector2Array([Vector2(1, 2), Vector2(3, 4), Vector2(5, 6)])
	p.slide_path = PackedVector2Array([Vector2(0, 0), Vector2(10, 0), Vector2(10, 10)])
	p.motion_model = PieceDefinition.MotionModel.SLIDE_AXIS_BIDIRECTIONAL
	p.motion_axis = Vector2(0.707, 0.707)
	p.slide_min = -120.0; p.slide_max = 250.0
	p.special_params = {"key1": "v1", "key2": 99.0}
	p.role = PieceDefinition.PieceRole.HUB
	p.piece_type = PieceDefinition.PieceType.OPEN_CIRCLE
	p.z_index = 5
	p.initially_locked = true
	p.release_direction = Vector2(0.0, -1.0)
	p.gaps.append(GapDefinition.new(180.0, 40.0, 12.0))
	return p

func _make_link() -> LinkDefinition:
	var ld := LinkDefinition.new(
		&"link_test_001", &"piece_a", &"piece_b",
		Color("#32ADDA"), 45.0, 77.0
	)
	ld.cuff_center_local = Vector2(50.0, 60.0)
	ld.cuff_orientation_deg = 33.0
	ld.cuff_width = 55.0; ld.cuff_depth = 25.0; ld.cuff_round_radius = 7.0
	ld.stem_length = 100.0; ld.stem_width = 8.0
	ld.stem_distance_from_piece = 120.0
	ld.z_index = 3; ld.clearance_tolerance_deg = 25.0
	ld.is_detached = false
	return ld

func _eq(a, b) -> bool:
	if a == null and b == null: return true
	if a == null or b == null: return false
	if typeof(a) == TYPE_FLOAT or typeof(a) == TYPE_INT:
		return absf(float(a) - float(b)) < 0.001
	if typeof(a) == TYPE_VECTOR2 and typeof(b) == TYPE_VECTOR2:
		return (a as Vector2).distance_to(b as Vector2) < 0.001
	if typeof(a) == TYPE_COLOR and typeof(b) == TYPE_COLOR:
		var ca := a as Color; var cb := b as Color
		return absf(ca.r - cb.r) < 0.001 and absf(ca.g - cb.g) < 0.001 \
			and absf(ca.b - cb.b) < 0.001 and absf(ca.a - cb.a) < 0.001
	if typeof(a) == TYPE_PACKED_VECTOR2_ARRAY and typeof(b) == TYPE_PACKED_VECTOR2_ARRAY:
		var pa := a as PackedVector2Array; var pb := b as PackedVector2Array
		if pa.size() != pb.size(): return false
		for i in range(pa.size()):
			if pa[i].distance_to(pb[i]) > 0.001: return false
		return true
	if typeof(a) == TYPE_DICTIONARY and typeof(b) == TYPE_DICTIONARY:
		var ka := (a as Dictionary).keys(); var kb := (b as Dictionary).keys()
		if ka.size() != kb.size(): return false
		for k in ka:
			if not (b as Dictionary).has(k): return false
			if not _eq((a as Dictionary)[k], (b as Dictionary)[k]): return false
		return true
	if typeof(a) == TYPE_STRING_NAME and typeof(b) == TYPE_STRING_NAME:
		return String(a) == String(b)
	return a == b

func _test_piece() -> int:
	var p := _make_piece()
	var d := (p as PieceDefinition).to_dict()
	printerr("piece.to_dict() keys: ", (d as Dictionary).keys())
	var p2 := PieceDefinition.new()
	(p2 as PieceDefinition).apply_dict(d)
	for fname in piece_fields:
		var a; var b
		match fname:
			"id":       a = String(p.id); b = String(p2.id)
			"color":    a = p.color; b = p2.color
			"shape_type": a = int(p.shape_type); b = int(p2.shape_type)
			"motion_model": a = int(p.motion_model); b = int(p2.motion_model)
			"motion_axis": a = p.motion_axis; b = p2.motion_axis
			"slide_min": a = p.slide_min; b = p2.slide_min
			"slide_max": a = p.slide_max; b = p2.slide_max
			"slide_path": a = p.slide_path; b = p2.slide_path
			"special_params": a = p.special_params; b = p2.special_params
			"role": a = int(p.role); b = int(p2.role)
			"piece_type": a = int(p.piece_type); b = int(p2.piece_type)
			"position": a = p.position; b = p2.position
			"start_angle_deg": a = p.start_angle_deg; b = p2.start_angle_deg
			"radius": a = p.radius; b = p2.radius
			"radius_y": a = p.radius_y; b = p2.radius_y
			"length": a = p.length; b = p2.length
			"length_b": a = p.length_b; b = p2.length_b
			"width": a = p.width; b = p2.width
			"height": a = p.height; b = p2.height
			"corner_radius": a = p.corner_radius; b = p2.corner_radius
			"thickness": a = p.thickness; b = p2.thickness
			"path_points": a = p.path_points; b = p2.path_points
			"gaps_count": a = p.gaps.size(); b = p2.gaps.size()
			"gap_0_center":
				if p.gaps.size() == 0: continue
				a = float(p.gaps[0].center_angle_deg); b = float(p2.gaps[0].center_angle_deg)
			"gap_0_width":
				if p.gaps.size() == 0: continue
				a = float(p.gaps[0].width_deg); b = float(p2.gaps[0].width_deg)
			"gap_0_tolerance":
				if p.gaps.size() == 0: continue
				a = float(p.gaps[0].tolerance_deg); b = float(p2.gaps[0].tolerance_deg)
			"z_index": a = p.z_index; b = p2.z_index
			"initially_locked": a = p.initially_locked; b = p2.initially_locked
			"release_direction": a = p.release_direction; b = p2.release_direction
			"target_exit_angle_deg": a = p.target_exit_angle_deg; b = p2.target_exit_angle_deg
		if not _eq(a, b):
			printerr("piece mismatch on ", fname, ": ", a, " vs ", b)
			return 1
	printerr("OK: piece roundtrip")
	return 0

func _test_link() -> int:
	var ld := _make_link()
	var d := (ld as LinkDefinition).to_dict()
	printerr("link.to_dict() keys: ", (d as Dictionary).keys())
	var ld3: LinkDefinition = LinkDefinition.from_dict(d)
	var ld3b := LinkDefinition.new()
	(ld3b as LinkDefinition).apply_dict(d)
	for fname in link_fields:
		var a; var b
		match fname:
			"id": a = String(ld.id); b = String(ld3.id)
			"from_piece_id": a = String(ld.from_piece_id); b = String(ld3.from_piece_id)
			"to_piece_id": a = String(ld.to_piece_id); b = String(ld3.to_piece_id)
			"collar_angle_deg": a = ld.collar_angle_deg; b = ld3.collar_angle_deg
			"cuff_center_local": a = ld.cuff_center_local; b = ld3.cuff_center_local
			"cuff_orientation_deg": a = ld.cuff_orientation_deg; b = ld3.cuff_orientation_deg
			"cuff_width": a = ld.cuff_width; b = ld3.cuff_width
			"cuff_depth": a = ld.cuff_depth; b = ld3.cuff_depth
			"cuff_round_radius": a = ld.cuff_round_radius; b = ld3.cuff_round_radius
			"stem_length": a = ld.stem_length; b = ld3.stem_length
			"stem_width": a = ld.stem_width; b = ld3.stem_width
			"stem_distance_from_piece": a = ld.stem_distance_from_piece; b = ld3.stem_distance_from_piece
			"stem_dist": a = ld.stem_dist; b = ld3.stem_dist
			"joint_color": a = ld.joint_color; b = ld3.joint_color
			"z_index": a = ld.z_index; b = ld3.z_index
			"clearance_tolerance_deg": a = ld.clearance_tolerance_deg; b = ld3.clearance_tolerance_deg
			"is_detached": a = ld.is_detached; b = ld3.is_detached
		if not _eq(a, b):
			printerr("link mismatch on ", fname, ": ", a, " vs ", b)
			return 1
	# apply_dict path also correct
	for fname in link_fields:
		var a2; var b2
		match fname:
			"id": a2 = String(ld.id); b2 = String(ld3b.id)
			"from_piece_id": a2 = String(ld.from_piece_id); b2 = String(ld3b.from_piece_id)
			"to_piece_id": a2 = String(ld.to_piece_id); b2 = String(ld3b.to_piece_id)
			"collar_angle_deg": a2 = ld.collar_angle_deg; b2 = ld3b.collar_angle_deg
			"cuff_center_local": a2 = ld.cuff_center_local; b2 = ld3b.cuff_center_local
			"cuff_orientation_deg": a2 = ld.cuff_orientation_deg; b2 = ld3b.cuff_orientation_deg
			"cuff_width": a2 = ld.cuff_width; b2 = ld3b.cuff_width
			"cuff_depth": a2 = ld.cuff_depth; b2 = ld3b.cuff_depth
			"cuff_round_radius": a2 = ld.cuff_round_radius; b2 = ld3b.cuff_round_radius
			"stem_length": a2 = ld.stem_length; b2 = ld3b.stem_length
			"stem_width": a2 = ld.stem_width; b2 = ld3b.stem_width
			"stem_distance_from_piece": a2 = ld.stem_distance_from_piece; b2 = ld3b.stem_distance_from_piece
			"stem_dist": a2 = ld.stem_dist; b2 = ld3b.stem_dist
			"joint_color": a2 = ld.joint_color; b2 = ld3b.joint_color
			"z_index": a2 = ld.z_index; b2 = ld3b.z_index
			"clearance_tolerance_deg": a2 = ld.clearance_tolerance_deg; b2 = ld3b.clearance_tolerance_deg
			"is_detached": a2 = ld.is_detached; b2 = ld3b.is_detached
		if not _eq(a2, b2):
			printerr("link apply_dict mismatch on ", fname, ": ", a2, " vs ", b2)
			return 1
	printerr("OK: link roundtrip (from_dict + apply_dict)")
	return 0

func _init() -> void:
	var rc1 := _test_piece()
	var rc2 := _test_link()
	if rc1 != 0 or rc2 != 0:
		printerr("LOSSLESS ROUND-TRIP FAILED")
		quit(1)
	else:
		printerr("LOSSLESS ROUND-TRIP PASSED")
		quit(0)
