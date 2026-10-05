with open("D:/AI secound Brain/RotateRings/data/level_database.gd", "r", encoding="utf-8") as f:
    text = f.read()

import re

level_13 = """		13:
			def.title = "Shape Sandbox"
			def.instruction = "Test the new geometry system!"
			def.par_moves = 4
			# Circle
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(200.0, 300.0), 76.0, 24.0, Color("#32ADDA"), 0.0, [GapDefinitionScript.new(180.0, 56.0, 16.0)], 0.0, 0)
			# Square
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(500.0, 300.0), 76.0, 24.0, Color("#EA7829"), 0.0, [GapDefinitionScript.new(180.0, 56.0, 16.0)], 0.0, 1)
			# Triangle
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(200.0, 600.0), 76.0, 24.0, Color("#8228D9"), 0.0, [GapDefinitionScript.new(0.0, 56.0, 16.0)], 0.0, 2)
			# Oval
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(500.0, 600.0), 76.0, 24.0, Color("#C8202F"), 0.0, [GapDefinitionScript.new(0.0, 56.0, 16.0)], 0.0, 3)
			
			def.pieces = [r0, r1, r2, r3]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_1", &"ring_0", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_1", &"ring_2", &"ring_3", Color("#8228D9"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_0", 180.0, true),
				SolutionStepScript.new(&"ring_3", 180.0, true)
			]
"""

# Replace level 13 block
new_text = re.sub(r'\t\t13:\n.*?(?=\t\t14:)', level_13, text, flags=re.DOTALL)

with open("D:/AI secound Brain/RotateRings/data/level_database.gd", "w", encoding="utf-8") as f:
    f.write(new_text)
