with open("D:/AI secound Brain/RotateRings/data/piece_definition.gd", "r", encoding="utf-8") as f:
    text = f.read()

import re

enum_add = """
enum ShapeType {
	CIRCLE,
	ROUNDED_SQUARE,
	ROUNDED_TRIANGLE,
	OVAL
}

@export var shape_type: ShapeType = ShapeType.CIRCLE
"""

text = text.replace('enum PieceType {', enum_add + 'enum PieceType {')

init_args_old = """func _init(
	p_id: StringName = &"ring_0",
	p_pos: Vector2 = Vector2.ZERO,
	p_radius: float = 110.0,
	p_thickness: float = 28.0,
	p_color: Color = Color("#00B4D8"),
	p_start_angle: float = 90.0,
	p_gaps: Array = [],
	p_target_exit: float = 0.0
) -> void:"""

init_args_new = """func _init(
	p_id: StringName = &"ring_0",
	p_pos: Vector2 = Vector2.ZERO,
	p_radius: float = 110.0,
	p_thickness: float = 28.0,
	p_color: Color = Color("#00B4D8"),
	p_start_angle: float = 90.0,
	p_gaps: Array = [],
	p_target_exit: float = 0.0,
	p_shape: ShapeType = ShapeType.CIRCLE
) -> void:"""

text = text.replace(init_args_old, init_args_new)

init_body_old = "	target_exit_angle_deg = p_target_exit"
init_body_new = "	target_exit_angle_deg = p_target_exit\n	shape_type = p_shape"

text = text.replace(init_body_old, init_body_new)

with open("D:/AI secound Brain/RotateRings/data/piece_definition.gd", "w", encoding="utf-8") as f:
    f.write(text)
