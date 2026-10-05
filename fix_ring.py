with open("D:/AI secound Brain/RotateRings/gameplay/ring_piece_2d.gd", "r", encoding="utf-8") as f:
    text = f.read()

text = text.replace(
    '@export var thickness: float = 26.0',
    '@export var thickness: float = 26.0\nvar shape_type: int = 0'
)

# And in setup(def)
setup_old = """	thickness = float(def.get("thickness")) if def.get("thickness") != null else 24.0"""
setup_new = """	thickness = float(def.get("thickness")) if def.get("thickness") != null else 24.0
	shape_type = def.shape_type if "shape_type" in def else 0"""
if setup_old in text:
    text = text.replace(setup_old, setup_new)

# Let's check for any 'def.'
import re
text = re.sub(r'\bdef\.shape_type\b', 'shape_type', text)

with open("D:/AI secound Brain/RotateRings/gameplay/ring_piece_2d.gd", "w", encoding="utf-8") as f:
    f.write(text)
