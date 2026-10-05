with open("D:/AI secound Brain/RotateRings/gameplay/puzzle_controller.gd", "r", encoding="utf-8") as f:
    text = f.read()

text = text.replace(
    'var r_outer: float = from_p.radius + (from_p.thickness * 0.5)',
    'var r_outer: float = PieceGeometry.get_boundary_distance(parent_shape, from_p.radius, deg_to_rad(link.def.collar_angle_deg)) + (from_p.thickness * 0.5)'
)

with open("D:/AI secound Brain/RotateRings/gameplay/puzzle_controller.gd", "w", encoding="utf-8") as f:
    f.write(text)
