extends Resource
class_name GapDefinition

@export var center_angle_deg: float = 0.0
@export var width_deg: float = 60.0
@export var tolerance_deg: float = 16.0

func _init(p_center: float = 0.0, p_width: float = 60.0, p_tol: float = 16.0) -> void:
	center_angle_deg = p_center
	width_deg = p_width
	tolerance_deg = p_tol

func to_dict() -> Dictionary:
	return {
		"center_angle_deg": float(center_angle_deg),
		"width_deg": float(width_deg),
		"tolerance_deg": float(tolerance_deg),
	}

static func from_dict(d: Dictionary) -> GapDefinition:
	return GapDefinition.new(
		float(d.get("center_angle_deg", 0.0)),
		float(d.get("width_deg", 60.0)),
		float(d.get("tolerance_deg", 16.0)),
	)
