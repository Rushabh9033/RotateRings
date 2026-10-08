extends Resource
class_name PieceDefinition


enum ShapeType {
	CIRCLE = 0,
	ROUNDED_SQUARE = 1,
	ROUNDED_TRIANGLE = 2,
	OVAL = 3,
	STRAIGHT = 4,
	L_SHAPE = 5
}

@export var shape_type: ShapeType = ShapeType.CIRCLE

enum MotionModel {
	ROTATE = 0,
	SLIDE_AXIS = 1,
	SLIDE_PATH = 2,
	FIXED = 3
}

@export var motion_model: MotionModel = MotionModel.ROTATE
@export var motion_axis: Vector2 = Vector2.RIGHT
@export var slide_min: float = -1000.0
@export var slide_max: float = 1000.0


enum PieceRole {
	NORMAL,
	ROOT_ANCHOR,
	HUB,
	EXIT,
	SPECIAL
}

@export var role: PieceRole = PieceRole.NORMAL

enum PieceType {
	CLOSED_CIRCLE,
	OPEN_CIRCLE,
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
	p_target_exit: float = 0.0,
	p_shape: ShapeType = ShapeType.CIRCLE
) -> void:
	id = p_id
	position = p_pos
	radius = p_radius
	thickness = p_thickness
	color = p_color
	start_angle_deg = p_start_angle
	gaps = p_gaps
	target_exit_angle_deg = p_target_exit
	shape_type = p_shape
	
	if gaps.is_empty():
		piece_type = PieceType.CLOSED_CIRCLE
	elif gaps.size() == 1:
		piece_type = PieceType.OPEN_CIRCLE
	elif gaps.size() == 2:
		piece_type = PieceType.DUAL_GAP_CIRCLE
