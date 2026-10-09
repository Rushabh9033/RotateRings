extends Resource
class_name LinkDefinition

# Authored binding (independent of any layout calculation):
@export var id: StringName = &"link_0"
@export var from_piece_id: StringName = &"ring_0"        # Parent ring that owns this connector
@export var to_piece_id: StringName   = &"ring_1"        # Child piece held in cuff (or constraint target)

# Where on the from-piece the connector stems out, in the from-piece's LOCAL angle.
# (Run-time may re-read positions of the connected pieces, but this captured attachment
# point is the authored reference truth.)
@export var collar_angle_deg: float = -999.0

# Explicit cuff-block geometry (Section 8): authored, not inferred.
@export var cuff_center_local: Vector2 = Vector2.ZERO  # Position of cuff center, in from-piece local space, before rotation.
@export var cuff_orientation_deg: float = 0.0        # Rotation of the cuff rectangle in world-space at start.
@export var cuff_width: float = 32.0                  # Tangential span of cuff rect.
@export var cuff_depth: float = 18.0                  # Radial depth of cuff rect.
@export var cuff_round_radius: float = 5.0            # Corner radius of cuff rect.

# Stem geometry (from from-piece outer edge to cuff center).
@export var stem_length: float = 0.0                  # 0 = runtime-derived from piece-to-cuff distance.
@export var stem_width: float = 6.0                   # Stem stroke width.
@export var stem_distance_from_piece: float = 0.0     # Authored override. 0 = runtime-derived from collar + radius.

# Visual + z-order.
@export var joint_color: Color = Color.TRANSPARENT
@export var z_index: int = 0

# Gameplay semantics.
@export var clearance_tolerance_deg: float = 20.0
@export var is_detached: bool = false                  # True when child slipped out of this cuff

# Storage alias for backward-compat with existing code that reads `stem_dist`.
# `stem_distance_from_piece` is the Section-8 canonical value; this legacy
# mirror exists only so older saved JSON (where only `stem_dist` was written)
# can still load without silently dropping the field. New code should always
# read/write `stem_distance_from_piece`; `stem_dist` is emitted to_dict() for
# round-trip compatibility and ignored by apply_dict()/from_dict() otherwise.
@export var stem_dist: float = 0.0

func _init(
	p_id: StringName = &"link_0",
	p_from: StringName = &"ring_0",
	p_to: StringName = &"ring_1",
	p_color: Color = Color.TRANSPARENT,
	p_collar_angle: float = -999.0,
	p_stem_dist: float = 0.0
) -> void:
	id = p_id
	from_piece_id = p_from
	to_piece_id = p_to
	joint_color = p_color
	collar_angle_deg = p_collar_angle
	stem_dist = p_stem_dist
	if stem_distance_from_piece <= 0.0:
		stem_distance_from_piece = p_stem_dist
	is_detached = false

func to_dict() -> Dictionary:
	return {
		"id": String(id),
		"from_id": String(from_piece_id),
		"to_id": String(to_piece_id),
		"collar_angle_deg": float(collar_angle_deg),
		"cuff_center_local": {"x": float(cuff_center_local.x), "y": float(cuff_center_local.y)},
		"cuff_orientation_deg": float(cuff_orientation_deg),
		"cuff_width": float(cuff_width),
		"cuff_depth": float(cuff_depth),
		"cuff_round_radius": float(cuff_round_radius),
		"stem_length": float(stem_length),
		"stem_width": float(stem_width),
		"stem_distance_from_piece": float(stem_distance_from_piece),
		"stem_dist": float(stem_dist),
		"joint_color_name": PieceDefinition.color_name_static(joint_color),
		"joint_color_hex": PieceDefinition.color_hex_static(joint_color),
		"z_index": int(z_index),
		"clearance_tolerance_deg": float(clearance_tolerance_deg),
		"is_detached": bool(is_detached),
	}

func apply_dict(d: Dictionary) -> void:
	id = StringName(String(d.get("id", "link_")))
	from_piece_id = StringName(String(d.get("from_id", "ring_a")))
	to_piece_id = StringName(String(d.get("to_id", "ring_b")))
	joint_color = PieceDefinition.color_hex_static_to_color(
		String(d.get("joint_color_hex", "#EA7829")),
		String(d.get("joint_color_name", "orange")),
	)
	collar_angle_deg = float(d.get("collar_angle_deg", -999.0))
	if d.has("cuff_center_local"):
		var ccv: Variant = d["cuff_center_local"]
		if ccv is Dictionary:
			cuff_center_local = Vector2(float(ccv.get("x", 0.0)), float(ccv.get("y", 0.0)))
	cuff_orientation_deg = float(d.get("cuff_orientation_deg", 0.0))
	cuff_width = float(d.get("cuff_width", 32.0))
	cuff_depth = float(d.get("cuff_depth", 18.0))
	cuff_round_radius = float(d.get("cuff_round_radius", 5.0))
	stem_length = float(d.get("stem_length", 0.0))
	stem_width = float(d.get("stem_width", 6.0))
	stem_distance_from_piece = float(d.get("stem_distance_from_piece", 0.0))
	stem_dist = float(d.get("stem_dist", stem_distance_from_piece))
	z_index = int(d.get("z_index", 0))
	clearance_tolerance_deg = float(d.get("clearance_tolerance_deg", 20.0))
	is_detached = bool(d.get("is_detached", false))

static func from_dict(d: Dictionary) -> LinkDefinition:
	var ld := LinkDefinition.new(
		StringName(String(d.get("id", "link_"))),
		StringName(String(d.get("from_id", "ring_a"))),
		StringName(String(d.get("to_id", "ring_b"))),
		PieceDefinition.color_hex_static_to_color(
			String(d.get("joint_color_hex", "#EA7829")),
			String(d.get("joint_color_name", "orange")),
		),
		float(d.get("collar_angle_deg", -999.0)),
		float(d.get("stem_dist", 0.0)),
	)
	if d.has("cuff_center_local"):
		var cc_var: Variant = d["cuff_center_local"]
		if cc_var is Dictionary:
			ld.cuff_center_local = Vector2(float(cc_var.get("x", 0.0)), float(cc_var.get("y", 0.0)))
	ld.cuff_orientation_deg = float(d.get("cuff_orientation_deg", 0.0))
	ld.cuff_width = float(d.get("cuff_width", 32.0))
	ld.cuff_depth = float(d.get("cuff_depth", 18.0))
	ld.cuff_round_radius = float(d.get("cuff_round_radius", 5.0))
	ld.stem_length = float(d.get("stem_length", 0.0))
	ld.stem_width = float(d.get("stem_width", 6.0))
	ld.stem_distance_from_piece = float(d.get("stem_distance_from_piece", 0.0))
	ld.z_index = int(d.get("z_index", 0))
	ld.clearance_tolerance_deg = float(d.get("clearance_tolerance_deg", 20.0))
	ld.is_detached = bool(d.get("is_detached", false))
	return ld
