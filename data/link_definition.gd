extends Resource
class_name LinkDefinition

@export var id: StringName = &"link_0"
@export var from_piece_id: StringName = &"ring_0" # Parent piece owning the stem
@export var to_piece_id: StringName = &"ring_1"   # Child piece held inside the cuff
@export var collar_angle_deg: float = -999.0      # Local angle on from_piece where stem connects
@export var stem_dist: float = 0.0                # Distance from from_piece center to cuff center
@export var joint_color: Color = Color.TRANSPARENT
@export var clearance_tolerance_deg: float = 20.0
@export var is_detached: bool = false             # True when child piece slipped out of this cuff

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
	is_detached = false
