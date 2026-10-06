extends RefCounted
class_name PuzzleAction

var piece_id: StringName = &""
var start_orientation: float = 0.0
var target_orientation: float = 0.0
var direction: int = 1 # 1 = Clockwise (CW), -1 = Counter-Clockwise (CCW)

func _init(p_id: StringName = &"", p_start: float = 0.0, p_target: float = 0.0, p_dir: int = 1) -> void:
	piece_id = p_id
	start_orientation = fposmod(p_start, 360.0)
	target_orientation = fposmod(p_target, 360.0)
	direction = p_dir

func to_dict() -> Dictionary:
	return {
		"piece_id": piece_id,
		"start_orientation": start_orientation,
		"target_orientation": target_orientation,
		"direction": direction
	}

static func create(p_id: StringName, p_start: float, p_target: float, p_dir: int = 1):
	var instance = load("res://gameplay/puzzle_action.gd").new()
	instance.piece_id = p_id
	instance.start_orientation = fposmod(p_start, 360.0)
	instance.target_orientation = fposmod(p_target, 360.0)
	instance.direction = p_dir
	return instance

static func from_dict(d: Dictionary):
	return create(
		StringName(d.get("piece_id", &"")),
		float(d.get("start_orientation", 0.0)),
		float(d.get("target_orientation", 0.0)),
		int(d.get("direction", 1))
	)
