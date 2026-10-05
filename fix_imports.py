import os

files_to_fix = [
    "D:/AI secound Brain/RotateRings/gameplay/puzzle_rules.gd",
    "D:/AI secound Brain/RotateRings/gameplay/puzzle_controller.gd",
    "D:/AI secound Brain/RotateRings/gameplay/ring_piece_2d.gd",
    "D:/AI secound Brain/RotateRings/gameplay/drag_rotation_controller.gd",
    "D:/AI secound Brain/RotateRings/gameplay/hint_controller.gd"
]

for file_path in files_to_fix:
    with open(file_path, "r", encoding="utf-8") as f:
        text = f.read()
    
    if "const PieceGeometry" not in text and "PieceGeometry." in text:
        # Insert after extends
        if text.startswith("extends "):
            lines = text.split("\n")
            # find first line that isn't extends or class_name
            for i, line in enumerate(lines):
                if not line.startswith("extends") and not line.startswith("class_name"):
                    lines.insert(i, 'const PieceGeometry = preload("res://gameplay/piece_geometry.gd")')
                    break
            text = "\n".join(lines)
            
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(text)
