extends Resource
class_name PieceDefinition

enum PieceType {
	OPEN_CIRCLE,
	D_SHAPE,
	U_SHAPE,
	ROUNDED_SQUARE,
	ROUNDED_TRIANGLE,
	DUAL_GAP_CIRCLE
}

@export var id: StringName = &"ring_0"
@export var piece_type: PieceType = PieceType.OPEN_CIRCLE
@export var position: Vector2 = Vector2.ZERO
@export var start_angle_deg: float = 90.0
@export var radius: float = 110.0
@export var thickness: float = 28.0
@export var color: Color = Color("#00B4D8")
@export var gaps: Array = []
@export var z_index: int = 1
@export var initially_locked: bool = false
@export var release_direction: Vector2 = Vector2.RIGHT

@export var target_exit_angle_deg: float = 0.0

func _init(
	p_id: StringName = &"ring_0",
	p_pos: Vector2 = Vector2.ZERO,
	p_radius: float = 110.0,
	p_thickness: float = 28.0,
	p_color: Color = Color("#00B4D8"),
	p_start_angle: float = 90.0,
	p_gaps: Array = [],
	p_target_exit: float = 0.0
) -> void:
	id = p_id
	position = p_pos
	radius = p_radius
	thickness = p_thickness
	color = p_color
	start_angle_deg = p_start_angle
	gaps = p_gaps
	target_exit_angle_deg = p_target_exit
