extends Resource
class_name SolutionStep

@export var piece_id: StringName = &"ring_0"
@export var target_angle_deg: float = 0.0
@export var expect_release: bool = true

func _init(p_id: StringName = &"ring_0", p_target_angle: float = 0.0, p_expect_release: bool = true) -> void:
	piece_id = p_id
	target_angle_deg = p_target_angle
	expect_release = p_expect_release
