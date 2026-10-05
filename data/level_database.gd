extends RefCounted
class_name LevelDatabase

const LevelDefinitionScript = preload("res://data/level_definition.gd")
const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")
const LinkDefinitionScript = preload("res://data/link_definition.gd")
const SolutionStepScript = preload("res://data/solution_step.gd")

# Viewport: 720 x 1280
# Safe puzzle area: ~720 x 980 (top 160px HUD + bottom 140px booster bar)
# Puzzle center reference: x=360, y=620

static func get_level(level_id: int):
	var def = LevelDefinitionScript.new()
	def.level_id = level_id
	def.chapter_id = 1

	match level_id:
		1: # Level 1 (Video 00:00 - 00:06): 2 Rings Tutorial
			# Left ring: Blue (#32ADDA) anchor, owns stem/cuff pointing right (0°)
			# Right ring: Orange (#EA7829), clamped inside Blue's cuff at 180°
			# Player rotates Orange gap to face cuff (180°) -> Orange shatters -> 0.5s pause -> Blue anchor shatters
			def.title = "Level 1"
			def.instruction = "Rotate the ring into the correct position to unlock it"
			def.par_moves = 1
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(260, 620), 76.0, 24.0, Color("#32ADDA"), 180.0, [
				GapDefinitionScript.new(0.0, 56.0, 6.0)
			], 0.0)
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(460, 620), 76.0, 24.0, Color("#EA7829"), 0.0, [
				GapDefinitionScript.new(0.0, 56.0, 6.0)
			], 0.0)
			def.pieces = [r0, r1]
			# Blue (r0) is anchor/parent holding Orange (r1)
			def.links = [LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_1", Color("#32ADDA"))]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_1", 180.0, true)
			]

		2: # Level 2 (Video 00:07 - 00:31): 3 Rings
			# Purple (#8228D9) bottom anchor: stem holds Orange (top-left)
			# Orange (#EA7829) top-left: stem holds Blue (top-right)
			# Blue (#32ADDA) top-right: free child, rotates gap to Orange's cuff -> shatters
			# After Blue shatters, Orange rotates gap to Purple's cuff -> Orange and Purple shatter
			def.title = "Level 2"
			def.instruction = "Rotate rings to find the release points!"
			def.par_moves = 2
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(260, 500), 76.0, 24.0, Color("#EA7829"), 180.0, [
				GapDefinitionScript.new(0.0, 56.0, 6.0)
			], 0.0) # Orange
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(460, 500), 76.0, 24.0, Color("#32ADDA"), 0.0, [
				GapDefinitionScript.new(0.0, 56.0, 6.0)
			], 0.0) # Blue child
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(360, 680), 76.0, 24.0, Color("#8228D9"), 90.0, [
				GapDefinitionScript.new(0.0, 56.0, 6.0)
			], 0.0) # Purple anchor
			def.pieces = [r0, r1, r2]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_1", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_1", &"ring_2", &"ring_0", Color("#8228D9"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_1", 180.0, true),
				SolutionStepScript.new(&"ring_0", 61.0, true)
			]

		3: # Level 3 (Video 00:32 - 00:46): 4 Rings in Rhombus formation
			# Blue (#32ADDA) top anchor: owns TWO stems/cuffs holding Orange (left) and Purple (right)
			# Red (#C8202F) bottom: owns stem/cuff holding Orange (left)
			# Purple (#8228D9) right: rotates gap to Blue's right cuff -> shatters
			# Orange (#EA7829) left: held by Blue and Red; rotates gap to Blue's cuff -> Blue shatters
			# Orange then rotates gap to Red's cuff -> Orange & Red shatter!
			def.title = "Level 3"
			def.instruction = "Untangle the 4-ring constellation!"
			def.par_moves = 3
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(360, 420), 76.0, 24.0, Color("#32ADDA"), 270.0, [
				GapDefinitionScript.new(0.0, 56.0, 6.0)
			], 0.0) # Blue top
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(250, 600), 76.0, 24.0, Color("#EA7829"), 180.0, [
				GapDefinitionScript.new(0.0, 56.0, 6.0)
			], 0.0) # Orange left
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(470, 600), 76.0, 24.0, Color("#8228D9"), 0.0, [
				GapDefinitionScript.new(0.0, 56.0, 6.0)
			], 0.0) # Purple right
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(360, 780), 76.0, 24.0, Color("#C8202F"), 90.0, [
				GapDefinitionScript.new(0.0, 56.0, 6.0)
			], 0.0) # Red bottom
			def.pieces = [r0, r1, r2, r3]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_1", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_1", &"ring_0", &"ring_2", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_2", &"ring_3", &"ring_1", Color("#C8202F"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_2", 239.0, true),
				SolutionStepScript.new(&"ring_1", 301.0, true),
				SolutionStepScript.new(&"ring_1", 59.0, true)
			]

		4: # Level 4 (Video 00:54+): 5-Ring Chain
			def.title = "Level 4"
			def.instruction = "Work your way to the anchor!"
			def.par_moves = 8
			var r_center = PieceDefinitionScript.new(&"ring_center", Vector2(360, 600), 72.0, 24.0, Color("#8228D9"), 0.0, []) # Closed Purple O-ring
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(230, 460), 76.0, 24.0, Color("#3EA7C0"), 180.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # Cyan TL
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(490, 460), 76.0, 24.0, Color("#EA7829"), 0.0,   [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # Orange TR
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(230, 740), 76.0, 24.0, Color("#C8202F"), 180.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # Red BL
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(490, 740), 76.0, 24.0, Color("#2CA45C"), 0.0,   [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # Green BR
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(360, 880), 76.0, 24.0, Color("#32ADDA"), 90.0,  [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # Blue bottom
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(360, 320), 76.0, 24.0, Color("#1F7D3A"), 270.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # DarkGreen top
			def.pieces = [r_center, r0, r1, r2, r3, r4, r5]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_center", &"ring_0", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_1", &"ring_center", &"ring_1", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_2", &"ring_center", &"ring_2", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_3", &"ring_center", &"ring_3", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_4", &"ring_5", &"ring_0", Color("#1F7D3A")),
				LinkDefinitionScript.new(&"link_5", &"ring_5", &"ring_1", Color("#1F7D3A")),
				LinkDefinitionScript.new(&"link_6", &"ring_2", &"ring_4", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_7", &"ring_3", &"ring_4", Color("#2CA45C"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_0", 310.0, true),
				SolutionStepScript.new(&"ring_1", 230.0, true),
				SolutionStepScript.new(&"ring_0", 50.0, true),
				SolutionStepScript.new(&"ring_1", 130.0, true),
				SolutionStepScript.new(&"ring_4", 230.0, true),
				SolutionStepScript.new(&"ring_4", 310.0, true),
				SolutionStepScript.new(&"ring_2", 310.0, true),
				SolutionStepScript.new(&"ring_3", 230.0, true)
			]

		5: # Level 5 (Video 01:13+): Asymmetrical 7-Ring Web
			def.title = "Level 5"
			def.instruction = "Untangle the rings in cascade order!"
			def.par_moves = 6
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(250, 340), 76.0, 24.0, Color("#EA7829"), 315.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # Orange top-left
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(440, 370), 76.0, 24.0, Color("#3EA7C0"), 0.0,   [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # Cyan top-right
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(320, 520), 76.0, 24.0, Color("#8228D9"), 270.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # Purple center
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(140, 660), 76.0, 24.0, Color("#C8202F"), 180.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # Red left-root
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(360, 710), 76.0, 24.0, Color("#62C73E"), 180.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # LightGreen
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(280, 890), 76.0, 24.0, Color("#4361CF"), 90.0,  [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # DarkBlue bottom
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(550, 600), 76.0, 24.0, Color("#2CA45C"), 0.0,   [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # DarkGreen right
			def.pieces = [r0, r1, r2, r3, r4, r5, r6]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_3", &"ring_2", Color("#C8202F")), # Red holds Purple
				LinkDefinitionScript.new(&"link_1", &"ring_2", &"ring_1", Color("#8228D9")), # Purple holds Cyan
				LinkDefinitionScript.new(&"link_2", &"ring_2", &"ring_4", Color("#8228D9")), # Purple holds LightGreen
				LinkDefinitionScript.new(&"link_3", &"ring_1", &"ring_0", Color("#3EA7C0")), # Cyan holds Orange
				LinkDefinitionScript.new(&"link_4", &"ring_6", &"ring_4", Color("#2CA45C")), # DarkGreen holds LightGreen
				LinkDefinitionScript.new(&"link_5", &"ring_4", &"ring_5", Color("#62C73E"))  # LightGreen holds DarkBlue
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_0", 9.0, true),
				SolutionStepScript.new(&"ring_5", 294.0, true),
				SolutionStepScript.new(&"ring_1", 128.7, true),
				SolutionStepScript.new(&"ring_4", 330.0, true),
				SolutionStepScript.new(&"ring_4", 258.1, true),
				SolutionStepScript.new(&"ring_2", 142.1, true)
			]

		6: # Level 6 (Video 01:21+): Clover Constellation
			def.title = "Level 6"
			def.instruction = "Release the outer leaves first!"
			def.par_moves = 10
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(220, 360), 72.0, 24.0, Color("#F38224"), 270.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # Orange TL
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(500, 360), 72.0, 24.0, Color("#7D2AD4"), 270.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # Purple TR
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(360, 500), 68.0, 24.0, Color("#29B6F6"), 0.0,   []) # Closed Blue O-ring center
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(140, 540), 72.0, 24.0, Color("#CB2336"), 90.0,  [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # Red left
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(580, 540), 72.0, 24.0, Color("#62C73E"), 90.0,  [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # LightGreen right
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(360, 680), 72.0, 24.0, Color("#4361CF"), 90.0,  [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # DarkBlue center-low
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(220, 840), 72.0, 24.0, Color("#2CA45C"), 270.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # DarkGreen BL
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(500, 840), 72.0, 24.0, Color("#3EA7C0"), 270.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # Cyan BR
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(360, 980), 72.0, 24.0, Color("#F38224"), 90.0,  [GapDefinitionScript.new(0.0, 56.0, 6.0)]) # Orange bottom
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_2", &"ring_0", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_1", &"ring_2", &"ring_1", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_2", &"ring_0", &"ring_3", Color("#F38224")),
				LinkDefinitionScript.new(&"link_3", &"ring_1", &"ring_4", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_4", &"ring_5", &"ring_3", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_5", &"ring_5", &"ring_4", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_6", &"ring_6", &"ring_8", Color("#2CA45C")),
				LinkDefinitionScript.new(&"link_7", &"ring_7", &"ring_8", Color("#3EA7C0")),
				LinkDefinitionScript.new(&"link_8", &"ring_5", &"ring_6", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_9", &"ring_5", &"ring_7", Color("#4361CF"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_8", 45.0, true),
				SolutionStepScript.new(&"ring_8", 135.0, true),
				SolutionStepScript.new(&"ring_6", 45.0, true),
				SolutionStepScript.new(&"ring_7", 135.0, true),
				SolutionStepScript.new(&"ring_3", 32.5, true),
				SolutionStepScript.new(&"ring_3", 294.0, true),
				SolutionStepScript.new(&"ring_4", 147.5, true),
				SolutionStepScript.new(&"ring_4", 246.0, true),
				SolutionStepScript.new(&"ring_0", 45.0, true),
				SolutionStepScript.new(&"ring_1", 135.0, true)
			]

		7: # Level 7 (Video 01:31+): Twin Pillars
			def.title = "Level 7"
			def.instruction = "Two paths, one solution."
			def.par_moves = 6
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(220, 380), 76.0, 24.0, Color("#29B6F6"), 90.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(500, 380), 76.0, 24.0, Color("#62C73E"), 90.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(360, 520), 76.0, 24.0, Color("#7D2AD4"), 90.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(220, 680), 76.0, 24.0, Color("#4361CF"), 90.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(500, 680), 76.0, 24.0, Color("#2CA45C"), 90.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(360, 820), 76.0, 24.0, Color("#F38224"), 90.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_3", &"ring_0", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_1", &"ring_4", &"ring_1", Color("#2CA45C")),
				LinkDefinitionScript.new(&"link_2", &"ring_5", &"ring_3", Color("#F38224")),
				LinkDefinitionScript.new(&"link_3", &"ring_5", &"ring_4", Color("#F38224")),
				LinkDefinitionScript.new(&"link_4", &"ring_3", &"ring_2", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_5", &"ring_4", &"ring_2", Color("#2CA45C"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_0", 180.0, true),
				SolutionStepScript.new(&"ring_1", 180.0, true),
				SolutionStepScript.new(&"ring_2", 135.0, true),
				SolutionStepScript.new(&"ring_2", 225.0, true),
				SolutionStepScript.new(&"ring_3", 135.0, true),
				SolutionStepScript.new(&"ring_4", 225.0, true)
			]

		8: # Level 8: Star Flower — 4 petals + center
			def.title = "Star Flower"
			def.instruction = "Free the 4 petals from the central blossom!"
			def.par_moves = 4
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(360, 600), 84.0, 26.0, Color("#7D2AD4"), 45.0,  [GapDefinitionScript.new(0.0, 60.0, 20.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(360, 400), 84.0, 26.0, Color("#CB2336"), 180.0, [GapDefinitionScript.new(0.0, 60.0, 20.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(560, 600), 84.0, 26.0, Color("#29B6F6"), 45.0,  [GapDefinitionScript.new(0.0, 60.0, 20.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(360, 800), 84.0, 26.0, Color("#62C73E"), 90.0, [GapDefinitionScript.new(0.0, 60.0, 20.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(160, 600), 84.0, 26.0, Color("#F38224"), 135.0, [GapDefinitionScript.new(0.0, 60.0, 20.0)])
			def.pieces = [r0, r1, r2, r3, r4]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_1", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_1", &"ring_0", &"ring_2", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_2", &"ring_0", &"ring_3", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_3", &"ring_0", &"ring_4", Color("#7D2AD4"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_1", 90.0, true),
				SolutionStepScript.new(&"ring_2", 180.0, true),
				SolutionStepScript.new(&"ring_3", 270.0, true),
				SolutionStepScript.new(&"ring_4", 0.0, true)
			]

		9: # Level 9: 5-Ring Zigzag Ribbon
			def.title = "Zigzag Ribbon"
			def.instruction = "Untangle the zigzag chain!"
			def.par_moves = 4
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(140, 520), 76.0, 24.0, Color("#29B6F6"), 90.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(250, 690), 76.0, 24.0, Color("#F38224"), 180.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(360, 520), 76.0, 24.0, Color("#7D2AD4"), 0.0,   [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(470, 690), 76.0, 24.0, Color("#62C73E"), 90.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(580, 520), 76.0, 24.0, Color("#CB2336"), 90.0,  [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			def.pieces = [r0, r1, r2, r3, r4]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_1", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_1", &"ring_2", &"ring_1", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_2", &"ring_2", &"ring_3", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_3", &"ring_4", &"ring_3", Color("#CB2336"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_1", 237.0, true),
				SolutionStepScript.new(&"ring_1", 303.0, true),
				SolutionStepScript.new(&"ring_3", 303.0, true),
				SolutionStepScript.new(&"ring_3", 237.0, true)
			]

		10: # Level 10: Dual-Gap Awakening
			def.title = "Dual-Gap Ring"
			def.instruction = "Center ring has 2 gaps! Align both collars sequentially."
			def.par_moves = 2
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(360, 620), 80.0, 24.0, Color("#7D2AD4"), 45.0, [
				GapDefinitionScript.new(0.0, 56.0, 6.0),
				GapDefinitionScript.new(90.0, 56.0, 6.0)
			])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(160, 620), 76.0, 24.0, Color("#29B6F6"), 180.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(560, 620), 76.0, 24.0, Color("#F38224"), 0.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			def.pieces = [r0, r1, r2]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_1", &"ring_0", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_1", &"ring_2", &"ring_0", Color("#F38224"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_0", 180.0, true),
				SolutionStepScript.new(&"ring_0", 270.0, true)
			]

		11: # Level 11: Hexa Constellation (hex ring)
			def.title = "Hexa Constellation"
			def.instruction = "6 rings form a hexagonal star."
			def.par_moves = 5
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(360, 422), 76.0, 24.0, Color("#29B6F6"), 90.0,  [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(532, 521), 76.0, 24.0, Color("#F38224"), 270.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(532, 719), 76.0, 24.0, Color("#62C73E"), 90.0,  [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(360, 818), 76.0, 24.0, Color("#CB2336"), 90.0,  [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(188, 719), 76.0, 24.0, Color("#7D2AD4"), 90.0,  [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(188, 521), 76.0, 24.0, Color("#4361CF"), 270.0, [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_1", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_1", &"ring_1", &"ring_2", Color("#F38224")),
				LinkDefinitionScript.new(&"link_2", &"ring_2", &"ring_3", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_3", &"ring_3", &"ring_4", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_4", &"ring_4", &"ring_5", Color("#7D2AD4"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_5", 90.0, true),
				SolutionStepScript.new(&"ring_4", 30.0, true),
				SolutionStepScript.new(&"ring_3", 330.0, true),
				SolutionStepScript.new(&"ring_2", 270.0, true),
				SolutionStepScript.new(&"ring_1", 210.0, true)
			]

		12: # Level 12: Chapter 1 Master Knot
			def.title = "Master Knot"
			def.instruction = "The grand finale! Free all rings from the cluster."
			def.par_moves = 5
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(220, 460), 76.0, 24.0, Color("#CB2336"), 90.0,  [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(500, 460), 76.0, 24.0, Color("#29B6F6"), 90.0,  [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(120, 630), 76.0, 24.0, Color("#F38224"), 90.0,  [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(360, 600), 76.0, 24.0, Color("#7D2AD4"), 0.0,   [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(600, 630), 76.0, 24.0, Color("#62C73E"), 90.0,  [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(360, 805), 76.0, 24.0, Color("#4361CF"), 90.0,  [GapDefinitionScript.new(0.0, 56.0, 6.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_2", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_1", &"ring_1", &"ring_4", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_2", &"ring_3", &"ring_0", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_3", &"ring_3", &"ring_1", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_4", &"ring_5", &"ring_3", Color("#4361CF"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_2", 301.0, true),
				SolutionStepScript.new(&"ring_4", 240.0, true),
				SolutionStepScript.new(&"ring_0", 45.0, true),
				SolutionStepScript.new(&"ring_1", 135.0, true),
				SolutionStepScript.new(&"ring_3", 90.0, true)
			]

		13:
			def.title = "Level 13"
			def.instruction = "Clear the rings!"
			def.par_moves = 7
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(387.0, 629.0), 115.0, 24.0, Color("#7D2AD4"), 84.3, [])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(267.0, 351.0), 115.0, 24.0, Color("#C8202F"), 67.2, [GapDefinitionScript.new(34.9, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(267.0, 351.0), 150.0, 24.0, Color("#F38224"), 231.3, [GapDefinitionScript.new(77.4, 56.0, 16.0), GapDefinitionScript.new(285.9, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(267.0, 351.0), 76.0, 24.0, Color("#29B6F6"), 335.8, [GapDefinitionScript.new(273.8, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(257.0, 898.0), 76.0, 24.0, Color("#32ADDA"), 126.9, [GapDefinitionScript.new(292.8, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(267.0, 351.0), 40.0, 24.0, Color("#EA7829"), 293.4, [GapDefinitionScript.new(185.0, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_4", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_1", &"ring_0", &"ring_5", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_2", &"ring_4", &"ring_3", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_3", &"ring_0", &"ring_1", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_4", &"ring_1", &"ring_2", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_5", &"ring_3", &"ring_2", Color("#29B6F6"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_2", 74.1, true),
				SolutionStepScript.new(&"ring_2", 282.6, true),
				SolutionStepScript.new(&"ring_1", 31.8, true),
				SolutionStepScript.new(&"ring_3", 177.3, true),
				SolutionStepScript.new(&"ring_5", 241.6, true),
				SolutionStepScript.new(&"ring_4", 3.0, true)
			]

		14:
			def.title = "Level 14"
			def.instruction = "Clear the rings!"
			def.par_moves = 7
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(299.0, 547.0), 115.0, 24.0, Color("#C8202F"), 277.7, [GapDefinitionScript.new(3.0, 56.0, 16.0), GapDefinitionScript.new(164.0, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(299.0, 547.0), 76.0, 24.0, Color("#7D2AD4"), 181.0, [GapDefinitionScript.new(282.4, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(517.0, 828.0), 76.0, 24.0, Color("#32ADDA"), 81.3, [GapDefinitionScript.new(255.3, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(299.0, 547.0), 40.0, 24.0, Color("#29B6F6"), 36.8, [GapDefinitionScript.new(253.1, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(316.0, 818.0), 40.0, 24.0, Color("#F38224"), 276.7, [GapDefinitionScript.new(311.7, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(316.0, 818.0), 76.0, 24.0, Color("#EA7829"), 180.0, [])
			def.pieces = [r0, r1, r2, r3, r4, r5]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_5", &"ring_4", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_1", &"ring_5", &"ring_0", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_2", &"ring_4", &"ring_0", Color("#F38224")),
				LinkDefinitionScript.new(&"link_3", &"ring_4", &"ring_2", Color("#F38224")),
				LinkDefinitionScript.new(&"link_4", &"ring_2", &"ring_3", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_5", &"ring_0", &"ring_1", Color("#C8202F"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_1", 77.6, true),
				SolutionStepScript.new(&"ring_3", 159.1, true),
				SolutionStepScript.new(&"ring_2", 287.5, true),
				SolutionStepScript.new(&"ring_0", 282.4, true),
				SolutionStepScript.new(&"ring_0", 83.4, true),
				SolutionStepScript.new(&"ring_4", 48.3, true)
			]

		15:
			def.title = "Level 15"
			def.instruction = "Clear the rings!"
			def.par_moves = 7
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(499.0, 771.0), 76.0, 24.0, Color("#7D2AD4"), 261.2, [GapDefinitionScript.new(188.0, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(213.0, 518.0), 150.0, 24.0, Color("#7D2AD4"), 221.3, [GapDefinitionScript.new(3.9, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(213.0, 518.0), 115.0, 24.0, Color("#8228D9"), 30.0, [])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(343.0, 864.0), 40.0, 24.0, Color("#4361CF"), 323.3, [GapDefinitionScript.new(190.8, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(484.0, 561.0), 76.0, 24.0, Color("#29B6F6"), 120.2, [GapDefinitionScript.new(45.6, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(499.0, 771.0), 40.0, 24.0, Color("#F38224"), 73.8, [GapDefinitionScript.new(357.8, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(343.0, 864.0), 76.0, 24.0, Color("#CB2336"), 152.0, [GapDefinitionScript.new(244.7, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_2", &"ring_3", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_1", &"ring_2", &"ring_0", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_2", &"ring_2", &"ring_6", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_3", &"ring_6", &"ring_1", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_4", &"ring_6", &"ring_4", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_5", &"ring_1", &"ring_5", Color("#7D2AD4"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_5", 223.7, true),
				SolutionStepScript.new(&"ring_4", 69.4, true),
				SolutionStepScript.new(&"ring_1", 65.5, true),
				SolutionStepScript.new(&"ring_6", 4.7, true),
				SolutionStepScript.new(&"ring_0", 33.5, true),
				SolutionStepScript.new(&"ring_3", 58.6, true)
			]

		16:
			def.title = "Level 16"
			def.instruction = "Clear the rings!"
			def.par_moves = 11
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(219.0, 819.0), 76.0, 24.0, Color("#8228D9"), 326.7, [GapDefinitionScript.new(25.8, 56.0, 16.0), GapDefinitionScript.new(26.4, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(514.0, 849.0), 40.0, 24.0, Color("#7D2AD4"), 214.1, [GapDefinitionScript.new(17.1, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(392.0, 650.0), 76.0, 24.0, Color("#8228D9"), 267.8, [GapDefinitionScript.new(356.3, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(392.0, 650.0), 40.0, 24.0, Color("#62C73E"), 327.0, [])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(322.0, 414.0), 115.0, 24.0, Color("#62C73E"), 64.1, [GapDefinitionScript.new(121.9, 56.0, 16.0), GapDefinitionScript.new(145.2, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(489.0, 734.0), 40.0, 24.0, Color("#4361CF"), 78.7, [GapDefinitionScript.new(10.6, 56.0, 16.0), GapDefinitionScript.new(245.2, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(219.0, 819.0), 115.0, 24.0, Color("#4361CF"), 193.6, [GapDefinitionScript.new(52.4, 56.0, 16.0), GapDefinitionScript.new(111.3, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_3", &"ring_1", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_1", &"ring_1", &"ring_0", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_2", &"ring_3", &"ring_0", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_3", &"ring_3", &"ring_2", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_4", &"ring_1", &"ring_5", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_5", &"ring_3", &"ring_5", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_6", &"ring_2", &"ring_6", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_7", &"ring_0", &"ring_6", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_8", &"ring_6", &"ring_4", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_9", &"ring_5", &"ring_4", Color("#4361CF"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_4", 277.3, true),
				SolutionStepScript.new(&"ring_4", 342.3, true),
				SolutionStepScript.new(&"ring_6", 248.7, true),
				SolutionStepScript.new(&"ring_6", 263.3, true),
				SolutionStepScript.new(&"ring_5", 335.7, true),
				SolutionStepScript.new(&"ring_5", 67.2, true),
				SolutionStepScript.new(&"ring_2", 3.7, true),
				SolutionStepScript.new(&"ring_0", 289.2, true),
				SolutionStepScript.new(&"ring_0", 340.0, true),
				SolutionStepScript.new(&"ring_1", 221.3, true)
			]

		17:
			def.title = "Level 17"
			def.instruction = "Clear the rings!"
			def.par_moves = 7
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(490.0, 412.0), 150.0, 24.0, Color("#C8202F"), 240.5, [])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(474.0, 695.0), 76.0, 24.0, Color("#F38224"), 42.8, [GapDefinitionScript.new(52.3, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(474.0, 695.0), 115.0, 24.0, Color("#29B6F6"), 322.3, [GapDefinitionScript.new(181.3, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(235.0, 388.0), 76.0, 24.0, Color("#8228D9"), 126.9, [GapDefinitionScript.new(281.7, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(209.0, 801.0), 150.0, 24.0, Color("#7D2AD4"), 185.2, [GapDefinitionScript.new(158.8, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(209.0, 801.0), 76.0, 24.0, Color("#C8202F"), 150.6, [GapDefinitionScript.new(110.2, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(337.0, 573.0), 40.0, 24.0, Color("#62C73E"), 222.6, [GapDefinitionScript.new(151.6, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_2", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_1", &"ring_0", &"ring_5", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_2", &"ring_2", &"ring_6", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_3", &"ring_2", &"ring_1", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_4", &"ring_0", &"ring_3", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_5", &"ring_1", &"ring_4", Color("#F38224"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_4", 179.4, true),
				SolutionStepScript.new(&"ring_3", 83.7, true),
				SolutionStepScript.new(&"ring_1", 307.7, true),
				SolutionStepScript.new(&"ring_6", 250.1, true),
				SolutionStepScript.new(&"ring_5", 195.6, true),
				SolutionStepScript.new(&"ring_2", 91.9, true)
			]

		18:
			def.title = "Level 18"
			def.instruction = "Clear the rings!"
			def.par_moves = 7
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(213.0, 410.0), 115.0, 24.0, Color("#7D2AD4"), 307.6, [GapDefinitionScript.new(174.1, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(213.0, 410.0), 40.0, 24.0, Color("#C8202F"), 167.7, [GapDefinitionScript.new(260.7, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(213.0, 410.0), 76.0, 24.0, Color("#29B6F6"), 222.4, [GapDefinitionScript.new(60.3, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(433.0, 775.0), 150.0, 24.0, Color("#7D2AD4"), 206.1, [GapDefinitionScript.new(248.4, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(433.0, 775.0), 40.0, 24.0, Color("#F38224"), 211.8, [GapDefinitionScript.new(151.2, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(433.0, 775.0), 76.0, 24.0, Color("#7D2AD4"), 298.7, [GapDefinitionScript.new(322.7, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(501.0, 390.0), 76.0, 24.0, Color("#C8202F"), 109.7, [])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_6", &"ring_0", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_1", &"ring_0", &"ring_4", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_2", &"ring_6", &"ring_2", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_3", &"ring_4", &"ring_5", Color("#F38224")),
				LinkDefinitionScript.new(&"link_4", &"ring_2", &"ring_3", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_5", &"ring_2", &"ring_1", Color("#29B6F6"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_1", 99.3, true),
				SolutionStepScript.new(&"ring_3", 350.5, true),
				SolutionStepScript.new(&"ring_5", 37.3, true),
				SolutionStepScript.new(&"ring_2", 295.7, true),
				SolutionStepScript.new(&"ring_4", 87.7, true),
				SolutionStepScript.new(&"ring_0", 181.9, true)
			]

		19:
			def.title = "Level 19"
			def.instruction = "Clear the rings!"
			def.par_moves = 8
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(259.0, 538.0), 115.0, 24.0, Color("#EA7829"), 351.2, [GapDefinitionScript.new(124.9, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(470.0, 758.0), 115.0, 24.0, Color("#62C73E"), 136.2, [])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(259.0, 538.0), 150.0, 24.0, Color("#32ADDA"), 204.9, [GapDefinitionScript.new(143.8, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(470.0, 758.0), 40.0, 24.0, Color("#7D2AD4"), 192.8, [GapDefinitionScript.new(53.6, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(300.0, 780.0), 40.0, 24.0, Color("#4361CF"), 159.7, [GapDefinitionScript.new(118.7, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(504.0, 538.0), 76.0, 24.0, Color("#62C73E"), 160.1, [GapDefinitionScript.new(305.3, 56.0, 16.0), GapDefinitionScript.new(329.5, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(378.0, 355.0), 40.0, 24.0, Color("#62C73E"), 239.4, [GapDefinitionScript.new(120.5, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_1", &"ring_3", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_1", &"ring_1", &"ring_6", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_2", &"ring_1", &"ring_0", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_3", &"ring_6", &"ring_4", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_4", &"ring_6", &"ring_2", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_5", &"ring_0", &"ring_5", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_6", &"ring_2", &"ring_5", Color("#32ADDA"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_5", 210.5, true),
				SolutionStepScript.new(&"ring_5", 234.7, true),
				SolutionStepScript.new(&"ring_2", 159.2, true),
				SolutionStepScript.new(&"ring_4", 161.7, true),
				SolutionStepScript.new(&"ring_0", 281.3, true),
				SolutionStepScript.new(&"ring_6", 316.7, true),
				SolutionStepScript.new(&"ring_3", 306.4, true)
			]

		20:
			def.title = "Level 20"
			def.instruction = "Clear the rings!"
			def.par_moves = 8
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(347.0, 751.0), 76.0, 24.0, Color("#CB2336"), 89.4, [GapDefinitionScript.new(61.6, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(391.0, 589.0), 40.0, 24.0, Color("#7D2AD4"), 279.5, [GapDefinitionScript.new(109.4, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(347.0, 751.0), 115.0, 24.0, Color("#C8202F"), 322.9, [GapDefinitionScript.new(298.1, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(439.0, 399.0), 76.0, 24.0, Color("#7D2AD4"), 206.9, [])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(439.0, 399.0), 115.0, 24.0, Color("#8228D9"), 298.8, [GapDefinitionScript.new(88.3, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(469.0, 872.0), 40.0, 24.0, Color("#32ADDA"), 163.5, [GapDefinitionScript.new(21.2, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(347.0, 751.0), 40.0, 24.0, Color("#7D2AD4"), 29.9, [GapDefinitionScript.new(241.2, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(439.0, 399.0), 40.0, 24.0, Color("#C8202F"), 311.9, [GapDefinitionScript.new(314.1, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_3", &"ring_6", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_1", &"ring_6", &"ring_1", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_2", &"ring_3", &"ring_7", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_3", &"ring_3", &"ring_5", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_4", &"ring_1", &"ring_2", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_5", &"ring_3", &"ring_4", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_6", &"ring_2", &"ring_0", Color("#C8202F"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_0", 298.4, true),
				SolutionStepScript.new(&"ring_4", 271.7, true),
				SolutionStepScript.new(&"ring_2", 347.1, true),
				SolutionStepScript.new(&"ring_5", 245.2, true),
				SolutionStepScript.new(&"ring_7", 45.9, true),
				SolutionStepScript.new(&"ring_1", 355.8, true),
				SolutionStepScript.new(&"ring_6", 43.4, true)
			]

		21:
			def.title = "Level 21"
			def.instruction = "Clear the rings!"
			def.par_moves = 10
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(319.0, 352.0), 150.0, 24.0, Color("#8228D9"), 90.4, [])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(519.0, 614.0), 115.0, 24.0, Color("#8228D9"), 281.4, [GapDefinitionScript.new(194.5, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(224.0, 897.0), 40.0, 24.0, Color("#62C73E"), 37.1, [GapDefinitionScript.new(187.2, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(451.0, 883.0), 150.0, 24.0, Color("#8228D9"), 179.9, [GapDefinitionScript.new(118.1, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(268.0, 660.0), 40.0, 24.0, Color("#EA7829"), 183.6, [GapDefinitionScript.new(152.9, 56.0, 16.0), GapDefinitionScript.new(310.1, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(519.0, 614.0), 76.0, 24.0, Color("#32ADDA"), 302.2, [GapDefinitionScript.new(54.6, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(519.0, 614.0), 40.0, 24.0, Color("#F38224"), 32.3, [GapDefinitionScript.new(41.8, 56.0, 16.0), GapDefinitionScript.new(223.5, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(319.0, 352.0), 76.0, 24.0, Color("#CB2336"), 144.1, [GapDefinitionScript.new(152.7, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_1", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_1", &"ring_1", &"ring_2", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_2", &"ring_1", &"ring_3", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_3", &"ring_1", &"ring_7", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_4", &"ring_3", &"ring_4", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_5", &"ring_0", &"ring_4", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_6", &"ring_7", &"ring_6", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_7", &"ring_2", &"ring_6", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_8", &"ring_4", &"ring_5", Color("#EA7829"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_5", 115.0, true),
				SolutionStepScript.new(&"ring_6", 272.7, true),
				SolutionStepScript.new(&"ring_6", 190.8, true),
				SolutionStepScript.new(&"ring_4", 329.3, true),
				SolutionStepScript.new(&"ring_4", 257.7, true),
				SolutionStepScript.new(&"ring_7", 260.0, true),
				SolutionStepScript.new(&"ring_3", 166.0, true),
				SolutionStepScript.new(&"ring_2", 129.0, true),
				SolutionStepScript.new(&"ring_1", 38.1, true)
			]

		22:
			def.title = "Level 22"
			def.instruction = "Clear the rings!"
			def.par_moves = 10
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(463.0, 367.0), 115.0, 24.0, Color("#32ADDA"), 141.3, [GapDefinitionScript.new(218.5, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(290.0, 760.0), 76.0, 24.0, Color("#8228D9"), 161.6, [GapDefinitionScript.new(38.7, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(290.0, 760.0), 150.0, 24.0, Color("#29B6F6"), 141.7, [GapDefinitionScript.new(272.1, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(290.0, 760.0), 40.0, 24.0, Color("#4361CF"), 125.0, [])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(520.0, 578.0), 76.0, 24.0, Color("#CB2336"), 317.6, [GapDefinitionScript.new(115.9, 56.0, 16.0), GapDefinitionScript.new(247.5, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(290.0, 760.0), 115.0, 24.0, Color("#29B6F6"), 110.7, [GapDefinitionScript.new(143.4, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(297.0, 467.0), 40.0, 24.0, Color("#29B6F6"), 3.8, [GapDefinitionScript.new(122.3, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(472.0, 849.0), 40.0, 24.0, Color("#62C73E"), 168.1, [GapDefinitionScript.new(228.5, 56.0, 16.0), GapDefinitionScript.new(202.5, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_3", &"ring_5", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_1", &"ring_3", &"ring_0", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_2", &"ring_5", &"ring_6", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_3", &"ring_0", &"ring_4", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_4", &"ring_5", &"ring_4", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_5", &"ring_3", &"ring_7", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_6", &"ring_0", &"ring_7", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_7", &"ring_7", &"ring_1", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_8", &"ring_6", &"ring_2", Color("#29B6F6"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_2", 359.3, true),
				SolutionStepScript.new(&"ring_1", 347.4, true),
				SolutionStepScript.new(&"ring_7", 66.4, true),
				SolutionStepScript.new(&"ring_7", 337.6, true),
				SolutionStepScript.new(&"ring_4", 254.1, true),
				SolutionStepScript.new(&"ring_4", 139.0, true),
				SolutionStepScript.new(&"ring_6", 329.1, true),
				SolutionStepScript.new(&"ring_0", 255.3, true),
				SolutionStepScript.new(&"ring_5", 216.6, true)
			]

		23:
			def.title = "Level 23"
			def.instruction = "Clear the rings!"
			def.par_moves = 8
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(307.0, 385.0), 115.0, 24.0, Color("#7D2AD4"), 41.4, [GapDefinitionScript.new(179.4, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(478.0, 643.0), 76.0, 24.0, Color("#7D2AD4"), 277.4, [GapDefinitionScript.new(97.2, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(296.0, 845.0), 150.0, 24.0, Color("#62C73E"), 198.6, [GapDefinitionScript.new(165.7, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(307.0, 385.0), 76.0, 24.0, Color("#62C73E"), 101.1, [GapDefinitionScript.new(237.9, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(307.0, 385.0), 40.0, 24.0, Color("#32ADDA"), 47.8, [GapDefinitionScript.new(146.9, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(203.0, 575.0), 76.0, 24.0, Color("#C8202F"), 246.6, [GapDefinitionScript.new(292.4, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(348.0, 583.0), 40.0, 24.0, Color("#CB2336"), 235.0, [GapDefinitionScript.new(239.1, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(203.0, 575.0), 40.0, 24.0, Color("#EA7829"), 42.7, [])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_7", &"ring_3", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_1", &"ring_7", &"ring_2", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_2", &"ring_3", &"ring_5", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_3", &"ring_7", &"ring_4", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_4", &"ring_5", &"ring_0", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_5", &"ring_3", &"ring_6", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_6", &"ring_0", &"ring_1", Color("#7D2AD4"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_1", 139.2, true),
				SolutionStepScript.new(&"ring_6", 19.2, true),
				SolutionStepScript.new(&"ring_0", 299.3, true),
				SolutionStepScript.new(&"ring_4", 331.8, true),
				SolutionStepScript.new(&"ring_5", 6.3, true),
				SolutionStepScript.new(&"ring_2", 85.3, true),
				SolutionStepScript.new(&"ring_3", 240.8, true)
			]

		24:
			def.title = "Level 24"
			def.instruction = "Clear the rings!"
			def.par_moves = 10
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(252.0, 358.0), 150.0, 24.0, Color("#F38224"), 163.1, [])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(252.0, 358.0), 115.0, 24.0, Color("#EA7829"), 60.9, [GapDefinitionScript.new(306.5, 56.0, 16.0), GapDefinitionScript.new(43.6, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(252.0, 358.0), 76.0, 24.0, Color("#8228D9"), 231.9, [GapDefinitionScript.new(226.6, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(345.0, 614.0), 76.0, 24.0, Color("#7D2AD4"), 57.2, [GapDefinitionScript.new(110.6, 56.0, 16.0), GapDefinitionScript.new(223.3, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(252.0, 358.0), 40.0, 24.0, Color("#4361CF"), 22.4, [GapDefinitionScript.new(329.2, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(345.0, 614.0), 40.0, 24.0, Color("#29B6F6"), 237.6, [GapDefinitionScript.new(342.5, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(344.0, 844.0), 40.0, 24.0, Color("#EA7829"), 55.6, [GapDefinitionScript.new(322.7, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(227.0, 763.0), 40.0, 24.0, Color("#C8202F"), 303.5, [GapDefinitionScript.new(219.8, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_7", Color("#F38224")),
				LinkDefinitionScript.new(&"link_1", &"ring_7", &"ring_3", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_2", &"ring_0", &"ring_3", Color("#F38224")),
				LinkDefinitionScript.new(&"link_3", &"ring_3", &"ring_1", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_4", &"ring_7", &"ring_1", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_5", &"ring_7", &"ring_5", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_6", &"ring_7", &"ring_4", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_7", &"ring_3", &"ring_2", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_8", &"ring_7", &"ring_6", Color("#C8202F"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_6", 252.0, true),
				SolutionStepScript.new(&"ring_2", 203.5, true),
				SolutionStepScript.new(&"ring_4", 124.4, true),
				SolutionStepScript.new(&"ring_5", 145.9, true),
				SolutionStepScript.new(&"ring_1", 50.0, true),
				SolutionStepScript.new(&"ring_1", 123.6, true),
				SolutionStepScript.new(&"ring_3", 26.8, true),
				SolutionStepScript.new(&"ring_3", 17.7, true),
				SolutionStepScript.new(&"ring_7", 53.8, true)
			]

		25:
			def.title = "Level 25"
			def.instruction = "Clear the rings!"
			def.par_moves = 11
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(415.0, 355.0), 40.0, 24.0, Color("#F38224"), 54.1, [GapDefinitionScript.new(202.8, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(226.0, 382.0), 76.0, 24.0, Color("#4361CF"), 13.0, [])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(280.0, 568.0), 76.0, 24.0, Color("#CB2336"), 246.0, [GapDefinitionScript.new(188.3, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(247.0, 715.0), 40.0, 24.0, Color("#EA7829"), 195.7, [GapDefinitionScript.new(226.0, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(466.0, 640.0), 76.0, 24.0, Color("#CB2336"), 212.3, [GapDefinitionScript.new(293.5, 56.0, 16.0), GapDefinitionScript.new(138.5, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(201.0, 878.0), 40.0, 24.0, Color("#EA7829"), 234.2, [GapDefinitionScript.new(195.8, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(466.0, 640.0), 40.0, 24.0, Color("#8228D9"), 141.0, [GapDefinitionScript.new(79.5, 56.0, 16.0), GapDefinitionScript.new(103.7, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(493.0, 469.0), 40.0, 24.0, Color("#EA7829"), 82.1, [GapDefinitionScript.new(3.8, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(497.0, 772.0), 40.0, 24.0, Color("#F38224"), 152.3, [GapDefinitionScript.new(67.1, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_1", &"ring_0", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_1", &"ring_0", &"ring_2", Color("#F38224")),
				LinkDefinitionScript.new(&"link_2", &"ring_1", &"ring_6", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_3", &"ring_0", &"ring_6", Color("#F38224")),
				LinkDefinitionScript.new(&"link_4", &"ring_2", &"ring_7", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_5", &"ring_6", &"ring_8", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_6", &"ring_0", &"ring_4", Color("#F38224")),
				LinkDefinitionScript.new(&"link_7", &"ring_2", &"ring_4", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_8", &"ring_2", &"ring_3", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_9", &"ring_2", &"ring_5", Color("#CB2336"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_5", 88.5, true),
				SolutionStepScript.new(&"ring_3", 56.7, true),
				SolutionStepScript.new(&"ring_4", 62.6, true),
				SolutionStepScript.new(&"ring_4", 326.3, true),
				SolutionStepScript.new(&"ring_8", 189.7, true),
				SolutionStepScript.new(&"ring_7", 151.3, true),
				SolutionStepScript.new(&"ring_6", 156.2, true),
				SolutionStepScript.new(&"ring_6", 147.5, true),
				SolutionStepScript.new(&"ring_2", 114.1, true),
				SolutionStepScript.new(&"ring_0", 329.0, true)
			]

		26:
			def.title = "Level 26"
			def.instruction = "Clear the rings!"
			def.par_moves = 10
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(226.0, 770.0), 150.0, 24.0, Color("#8228D9"), 196.5, [GapDefinitionScript.new(115.4, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(226.0, 770.0), 115.0, 24.0, Color("#4361CF"), 271.1, [GapDefinitionScript.new(83.3, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(485.0, 640.0), 115.0, 24.0, Color("#32ADDA"), 229.3, [GapDefinitionScript.new(105.1, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(485.0, 640.0), 76.0, 24.0, Color("#62C73E"), 170.8, [GapDefinitionScript.new(243.6, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(338.0, 460.0), 40.0, 24.0, Color("#7D2AD4"), 320.4, [GapDefinitionScript.new(203.3, 56.0, 16.0), GapDefinitionScript.new(20.4, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(226.0, 770.0), 76.0, 24.0, Color("#CB2336"), 230.3, [GapDefinitionScript.new(143.2, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(248.0, 503.0), 40.0, 24.0, Color("#F38224"), 103.4, [GapDefinitionScript.new(74.7, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(226.0, 770.0), 40.0, 24.0, Color("#8228D9"), 194.5, [GapDefinitionScript.new(329.3, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(440.0, 879.0), 40.0, 24.0, Color("#CB2336"), 315.0, [])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_8", &"ring_1", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_1", &"ring_8", &"ring_4", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_2", &"ring_1", &"ring_4", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_3", &"ring_1", &"ring_3", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_4", &"ring_8", &"ring_6", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_5", &"ring_3", &"ring_0", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_6", &"ring_0", &"ring_7", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_7", &"ring_7", &"ring_2", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_8", &"ring_1", &"ring_5", Color("#4361CF"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_5", 216.8, true),
				SolutionStepScript.new(&"ring_2", 48.3, true),
				SolutionStepScript.new(&"ring_7", 30.7, true),
				SolutionStepScript.new(&"ring_0", 218.0, true),
				SolutionStepScript.new(&"ring_6", 348.3, true),
				SolutionStepScript.new(&"ring_3", 269.8, true),
				SolutionStepScript.new(&"ring_4", 89.4, true),
				SolutionStepScript.new(&"ring_4", 233.0, true),
				SolutionStepScript.new(&"ring_1", 303.6, true)
			]

		27:
			def.title = "Level 27"
			def.instruction = "Clear the rings!"
			def.par_moves = 10
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(471.0, 640.0), 115.0, 24.0, Color("#29B6F6"), 78.1, [GapDefinitionScript.new(32.9, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(246.0, 625.0), 40.0, 24.0, Color("#C8202F"), 230.1, [GapDefinitionScript.new(87.1, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(277.0, 363.0), 115.0, 24.0, Color("#62C73E"), 234.9, [])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(285.0, 885.0), 76.0, 24.0, Color("#7D2AD4"), 73.6, [GapDefinitionScript.new(2.2, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(491.0, 392.0), 76.0, 24.0, Color("#EA7829"), 296.9, [GapDefinitionScript.new(37.5, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(246.0, 625.0), 76.0, 24.0, Color("#29B6F6"), 348.3, [GapDefinitionScript.new(291.5, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(277.0, 363.0), 76.0, 24.0, Color("#EA7829"), 15.7, [GapDefinitionScript.new(105.2, 56.0, 16.0), GapDefinitionScript.new(301.6, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(277.0, 363.0), 40.0, 24.0, Color("#32ADDA"), 182.8, [GapDefinitionScript.new(143.3, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(471.0, 640.0), 76.0, 24.0, Color("#EA7829"), 245.2, [GapDefinitionScript.new(162.1, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_2", &"ring_7", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_1", &"ring_7", &"ring_5", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_2", &"ring_7", &"ring_8", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_3", &"ring_8", &"ring_0", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_4", &"ring_5", &"ring_6", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_5", &"ring_8", &"ring_6", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_6", &"ring_0", &"ring_1", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_7", &"ring_7", &"ring_3", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_8", &"ring_0", &"ring_4", Color("#29B6F6"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_4", 57.1, true),
				SolutionStepScript.new(&"ring_3", 266.9, true),
				SolutionStepScript.new(&"ring_1", 276.7, true),
				SolutionStepScript.new(&"ring_6", 113.4, true),
				SolutionStepScript.new(&"ring_6", 351.5, true),
				SolutionStepScript.new(&"ring_0", 327.1, true),
				SolutionStepScript.new(&"ring_8", 72.9, true),
				SolutionStepScript.new(&"ring_5", 345.3, true),
				SolutionStepScript.new(&"ring_7", 216.7, true)
			]

		28:
			def.title = "Level 28"
			def.instruction = "Clear the rings!"
			def.par_moves = 11
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(413.0, 686.0), 150.0, 24.0, Color("#62C73E"), 258.8, [])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(219.0, 764.0), 40.0, 24.0, Color("#62C73E"), 263.7, [GapDefinitionScript.new(239.3, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(272.0, 882.0), 40.0, 24.0, Color("#C8202F"), 118.8, [GapDefinitionScript.new(29.5, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(272.0, 882.0), 76.0, 24.0, Color("#62C73E"), 69.4, [GapDefinitionScript.new(156.3, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(337.0, 462.0), 40.0, 24.0, Color("#8228D9"), 99.9, [GapDefinitionScript.new(325.4, 56.0, 16.0), GapDefinitionScript.new(44.3, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(241.0, 475.0), 40.0, 24.0, Color("#62C73E"), 50.2, [GapDefinitionScript.new(256.6, 56.0, 16.0), GapDefinitionScript.new(219.9, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(417.0, 413.0), 40.0, 24.0, Color("#CB2336"), 213.9, [GapDefinitionScript.new(335.4, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(413.0, 686.0), 76.0, 24.0, Color("#CB2336"), 237.3, [GapDefinitionScript.new(260.0, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(413.0, 686.0), 40.0, 24.0, Color("#CB2336"), 67.4, [GapDefinitionScript.new(173.3, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_7", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_1", &"ring_0", &"ring_8", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_2", &"ring_7", &"ring_2", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_3", &"ring_2", &"ring_1", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_4", &"ring_2", &"ring_5", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_5", &"ring_0", &"ring_5", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_6", &"ring_8", &"ring_4", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_7", &"ring_1", &"ring_4", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_8", &"ring_4", &"ring_3", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_9", &"ring_2", &"ring_6", Color("#C8202F"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_6", 131.7, true),
				SolutionStepScript.new(&"ring_3", 122.5, true),
				SolutionStepScript.new(&"ring_4", 67.0, true),
				SolutionStepScript.new(&"ring_4", 105.8, true),
				SolutionStepScript.new(&"ring_5", 190.9, true),
				SolutionStepScript.new(&"ring_5", 189.1, true),
				SolutionStepScript.new(&"ring_1", 186.5, true),
				SolutionStepScript.new(&"ring_2", 276.3, true),
				SolutionStepScript.new(&"ring_8", 186.7, true),
				SolutionStepScript.new(&"ring_7", 100.0, true)
			]

		29:
			def.title = "Level 29"
			def.instruction = "Clear the rings!"
			def.par_moves = 10
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(490.0, 788.0), 40.0, 24.0, Color("#CB2336"), 234.2, [GapDefinitionScript.new(194.0, 56.0, 16.0), GapDefinitionScript.new(145.6, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(284.0, 763.0), 40.0, 24.0, Color("#F38224"), 182.5, [GapDefinitionScript.new(237.2, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(490.0, 788.0), 115.0, 24.0, Color("#8228D9"), 194.3, [GapDefinitionScript.new(322.5, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(284.0, 763.0), 76.0, 24.0, Color("#7D2AD4"), 294.9, [GapDefinitionScript.new(171.7, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(445.0, 563.0), 76.0, 24.0, Color("#F38224"), 165.3, [GapDefinitionScript.new(8.5, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(200.0, 467.0), 150.0, 24.0, Color("#7D2AD4"), 141.1, [GapDefinitionScript.new(235.4, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(403.0, 434.0), 40.0, 24.0, Color("#62C73E"), 77.0, [GapDefinitionScript.new(94.0, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(276.0, 899.0), 40.0, 24.0, Color("#F38224"), 252.0, [GapDefinitionScript.new(359.2, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(515.0, 411.0), 40.0, 24.0, Color("#CB2336"), 126.0, [])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_8", &"ring_5", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_1", &"ring_5", &"ring_2", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_2", &"ring_5", &"ring_4", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_3", &"ring_8", &"ring_3", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_4", &"ring_4", &"ring_7", Color("#F38224")),
				LinkDefinitionScript.new(&"link_5", &"ring_2", &"ring_6", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_6", &"ring_3", &"ring_1", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_7", &"ring_5", &"ring_0", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_8", &"ring_4", &"ring_0", Color("#F38224"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_0", 113.0, true),
				SolutionStepScript.new(&"ring_0", 33.9, true),
				SolutionStepScript.new(&"ring_1", 122.8, true),
				SolutionStepScript.new(&"ring_6", 342.2, true),
				SolutionStepScript.new(&"ring_7", 297.5, true),
				SolutionStepScript.new(&"ring_3", 131.6, true),
				SolutionStepScript.new(&"ring_4", 192.9, true),
				SolutionStepScript.new(&"ring_2", 265.4, true),
				SolutionStepScript.new(&"ring_5", 114.5, true)
			]

		30:
			def.title = "Level 30"
			def.instruction = "Clear the rings!"
			def.par_moves = 14
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(447.0, 452.0), 76.0, 24.0, Color("#32ADDA"), 293.9, [GapDefinitionScript.new(69.5, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(447.0, 452.0), 150.0, 24.0, Color("#62C73E"), 25.9, [])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(229.0, 730.0), 115.0, 24.0, Color("#F38224"), 130.6, [GapDefinitionScript.new(271.4, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(201.0, 461.0), 76.0, 24.0, Color("#F38224"), 210.9, [GapDefinitionScript.new(281.4, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(503.0, 769.0), 76.0, 24.0, Color("#29B6F6"), 242.2, [GapDefinitionScript.new(263.3, 56.0, 16.0), GapDefinitionScript.new(161.8, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(367.0, 882.0), 40.0, 24.0, Color("#7D2AD4"), 210.1, [GapDefinitionScript.new(339.6, 56.0, 16.0), GapDefinitionScript.new(125.2, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(447.0, 452.0), 115.0, 24.0, Color("#32ADDA"), 297.2, [GapDefinitionScript.new(109.1, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(229.0, 730.0), 40.0, 24.0, Color("#F38224"), 138.9, [GapDefinitionScript.new(178.9, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(503.0, 769.0), 40.0, 24.0, Color("#4361CF"), 26.0, [GapDefinitionScript.new(303.6, 56.0, 16.0), GapDefinitionScript.new(5.9, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(503.0, 769.0), 115.0, 24.0, Color("#29B6F6"), 342.2, [GapDefinitionScript.new(34.8, 56.0, 16.0), GapDefinitionScript.new(332.9, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_1", &"ring_7", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_1", &"ring_1", &"ring_2", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_2", &"ring_1", &"ring_0", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_3", &"ring_1", &"ring_3", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_4", &"ring_3", &"ring_6", Color("#F38224")),
				LinkDefinitionScript.new(&"link_5", &"ring_3", &"ring_8", Color("#F38224")),
				LinkDefinitionScript.new(&"link_6", &"ring_2", &"ring_8", Color("#F38224")),
				LinkDefinitionScript.new(&"link_7", &"ring_8", &"ring_5", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_8", &"ring_3", &"ring_5", Color("#F38224")),
				LinkDefinitionScript.new(&"link_9", &"ring_1", &"ring_9", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_10", &"ring_7", &"ring_9", Color("#F38224")),
				LinkDefinitionScript.new(&"link_11", &"ring_6", &"ring_4", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_12", &"ring_9", &"ring_4", Color("#29B6F6"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_4", 198.2, true),
				SolutionStepScript.new(&"ring_4", 356.7, true),
				SolutionStepScript.new(&"ring_9", 215.2, true),
				SolutionStepScript.new(&"ring_9", 225.1, true),
				SolutionStepScript.new(&"ring_5", 123.3, true),
				SolutionStepScript.new(&"ring_5", 340.7, true),
				SolutionStepScript.new(&"ring_8", 182.2, true),
				SolutionStepScript.new(&"ring_8", 282.0, true),
				SolutionStepScript.new(&"ring_6", 68.8, true),
				SolutionStepScript.new(&"ring_3", 76.5, true),
				SolutionStepScript.new(&"ring_0", 290.5, true),
				SolutionStepScript.new(&"ring_2", 36.7, true),
				SolutionStepScript.new(&"ring_7", 129.2, true)
			]

		31:
			def.title = "Level 31"
			def.instruction = "Clear the rings!"
			def.par_moves = 12
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(498.0, 656.0), 115.0, 24.0, Color("#CB2336"), 70.4, [GapDefinitionScript.new(84.8, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(269.0, 627.0), 76.0, 24.0, Color("#F38224"), 233.7, [GapDefinitionScript.new(102.6, 56.0, 16.0), GapDefinitionScript.new(34.3, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(407.0, 376.0), 150.0, 24.0, Color("#C8202F"), 230.6, [GapDefinitionScript.new(308.2, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(498.0, 656.0), 40.0, 24.0, Color("#62C73E"), 119.5, [GapDefinitionScript.new(118.9, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(201.0, 749.0), 40.0, 24.0, Color("#62C73E"), 85.8, [GapDefinitionScript.new(323.9, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(373.0, 846.0), 40.0, 24.0, Color("#EA7829"), 306.6, [GapDefinitionScript.new(205.4, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(407.0, 376.0), 115.0, 24.0, Color("#32ADDA"), 322.5, [])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(373.0, 846.0), 76.0, 24.0, Color("#7D2AD4"), 174.1, [GapDefinitionScript.new(297.3, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(407.0, 376.0), 40.0, 24.0, Color("#8228D9"), 354.1, [GapDefinitionScript.new(337.6, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(407.0, 376.0), 76.0, 24.0, Color("#62C73E"), 29.1, [GapDefinitionScript.new(249.6, 56.0, 16.0), GapDefinitionScript.new(38.3, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_6", &"ring_0", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_1", &"ring_6", &"ring_1", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_2", &"ring_0", &"ring_1", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_3", &"ring_6", &"ring_8", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_4", &"ring_8", &"ring_3", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_5", &"ring_6", &"ring_2", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_6", &"ring_6", &"ring_5", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_7", &"ring_1", &"ring_4", Color("#F38224")),
				LinkDefinitionScript.new(&"link_8", &"ring_8", &"ring_7", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_9", &"ring_2", &"ring_9", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_10", &"ring_0", &"ring_9", Color("#CB2336"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_9", 33.7, true),
				SolutionStepScript.new(&"ring_9", 110.4, true),
				SolutionStepScript.new(&"ring_7", 336.9, true),
				SolutionStepScript.new(&"ring_4", 335.2, true),
				SolutionStepScript.new(&"ring_5", 68.8, true),
				SolutionStepScript.new(&"ring_2", 51.8, true),
				SolutionStepScript.new(&"ring_3", 133.1, true),
				SolutionStepScript.new(&"ring_8", 22.4, true),
				SolutionStepScript.new(&"ring_1", 332.9, true),
				SolutionStepScript.new(&"ring_1", 196.2, true),
				SolutionStepScript.new(&"ring_0", 167.2, true)
			]

		32:
			def.title = "Level 32"
			def.instruction = "Clear the rings!"
			def.par_moves = 13
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(217.0, 836.0), 40.0, 24.0, Color("#4361CF"), 219.9, [])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(325.0, 591.0), 40.0, 24.0, Color("#F38224"), 11.4, [GapDefinitionScript.new(40.3, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(291.0, 700.0), 40.0, 24.0, Color("#CB2336"), 291.4, [GapDefinitionScript.new(85.4, 56.0, 16.0), GapDefinitionScript.new(146.9, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(217.0, 836.0), 76.0, 24.0, Color("#32ADDA"), 17.9, [GapDefinitionScript.new(343.8, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(386.0, 842.0), 40.0, 24.0, Color("#62C73E"), 248.4, [GapDefinitionScript.new(158.6, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(314.0, 375.0), 115.0, 24.0, Color("#EA7829"), 208.5, [GapDefinitionScript.new(243.6, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(314.0, 375.0), 76.0, 24.0, Color("#CB2336"), 165.3, [GapDefinitionScript.new(284.4, 56.0, 16.0), GapDefinitionScript.new(126.7, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(477.0, 833.0), 40.0, 24.0, Color("#C8202F"), 193.3, [GapDefinitionScript.new(209.1, 56.0, 16.0), GapDefinitionScript.new(204.4, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(503.0, 576.0), 76.0, 24.0, Color("#C8202F"), 343.8, [GapDefinitionScript.new(324.5, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(503.0, 576.0), 40.0, 24.0, Color("#32ADDA"), 218.1, [GapDefinitionScript.new(160.8, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_9", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_1", &"ring_0", &"ring_5", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_2", &"ring_9", &"ring_1", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_3", &"ring_0", &"ring_6", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_4", &"ring_9", &"ring_6", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_5", &"ring_5", &"ring_4", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_6", &"ring_1", &"ring_8", Color("#F38224")),
				LinkDefinitionScript.new(&"link_7", &"ring_8", &"ring_2", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_8", &"ring_9", &"ring_2", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_9", &"ring_5", &"ring_3", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_10", &"ring_9", &"ring_7", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_11", &"ring_2", &"ring_7", Color("#CB2336"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_7", 11.1, true),
				SolutionStepScript.new(&"ring_7", 66.7, true),
				SolutionStepScript.new(&"ring_3", 298.1, true),
				SolutionStepScript.new(&"ring_2", 182.8, true),
				SolutionStepScript.new(&"ring_2", 244.3, true),
				SolutionStepScript.new(&"ring_8", 210.7, true),
				SolutionStepScript.new(&"ring_4", 102.6, true),
				SolutionStepScript.new(&"ring_6", 280.1, true),
				SolutionStepScript.new(&"ring_6", 177.5, true),
				SolutionStepScript.new(&"ring_1", 314.9, true),
				SolutionStepScript.new(&"ring_5", 218.3, true),
				SolutionStepScript.new(&"ring_9", 337.0, true)
			]

		33:
			def.title = "Level 33"
			def.instruction = "Clear the rings!"
			def.par_moves = 13
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(441.0, 444.0), 40.0, 24.0, Color("#29B6F6"), 51.4, [GapDefinitionScript.new(256.3, 56.0, 16.0), GapDefinitionScript.new(258.9, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(493.0, 804.0), 76.0, 24.0, Color("#32ADDA"), 59.9, [GapDefinitionScript.new(154.9, 56.0, 16.0), GapDefinitionScript.new(109.0, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(493.0, 804.0), 40.0, 24.0, Color("#C8202F"), 220.2, [GapDefinitionScript.new(212.9, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(298.0, 833.0), 76.0, 24.0, Color("#F38224"), 4.9, [])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(441.0, 444.0), 76.0, 24.0, Color("#7D2AD4"), 245.8, [GapDefinitionScript.new(239.3, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(295.0, 595.0), 76.0, 24.0, Color("#62C73E"), 217.3, [GapDefinitionScript.new(232.1, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(470.0, 636.0), 40.0, 24.0, Color("#62C73E"), 226.1, [GapDefinitionScript.new(310.3, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(224.0, 391.0), 76.0, 24.0, Color("#C8202F"), 301.0, [GapDefinitionScript.new(154.8, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(298.0, 833.0), 40.0, 24.0, Color("#29B6F6"), 338.6, [GapDefinitionScript.new(179.0, 56.0, 16.0), GapDefinitionScript.new(287.1, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(295.0, 595.0), 115.0, 24.0, Color("#C8202F"), 195.4, [GapDefinitionScript.new(353.6, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_3", &"ring_7", Color("#F38224")),
				LinkDefinitionScript.new(&"link_1", &"ring_3", &"ring_4", Color("#F38224")),
				LinkDefinitionScript.new(&"link_2", &"ring_7", &"ring_0", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_3", &"ring_3", &"ring_0", Color("#F38224")),
				LinkDefinitionScript.new(&"link_4", &"ring_7", &"ring_5", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_5", &"ring_3", &"ring_1", Color("#F38224")),
				LinkDefinitionScript.new(&"link_6", &"ring_4", &"ring_1", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_7", &"ring_0", &"ring_6", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_8", &"ring_4", &"ring_9", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_9", &"ring_6", &"ring_8", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_10", &"ring_0", &"ring_8", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_11", &"ring_1", &"ring_2", Color("#32ADDA"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_2", 147.1, true),
				SolutionStepScript.new(&"ring_8", 3.1, true),
				SolutionStepScript.new(&"ring_8", 132.1, true),
				SolutionStepScript.new(&"ring_9", 320.4, true),
				SolutionStepScript.new(&"ring_6", 311.1, true),
				SolutionStepScript.new(&"ring_1", 152.8, true),
				SolutionStepScript.new(&"ring_1", 16.7, true),
				SolutionStepScript.new(&"ring_5", 18.7, true),
				SolutionStepScript.new(&"ring_0", 211.3, true),
				SolutionStepScript.new(&"ring_0", 297.4, true),
				SolutionStepScript.new(&"ring_4", 230.9, true),
				SolutionStepScript.new(&"ring_7", 285.7, true)
			]

		34:
			def.title = "Level 34"
			def.instruction = "Clear the rings!"
			def.par_moves = 12
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(508.0, 517.0), 76.0, 24.0, Color("#62C73E"), 161.8, [GapDefinitionScript.new(333.7, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(508.0, 517.0), 150.0, 24.0, Color("#62C73E"), 240.7, [GapDefinitionScript.new(81.6, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(508.0, 517.0), 115.0, 24.0, Color("#4361CF"), 214.1, [GapDefinitionScript.new(41.6, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(333.0, 839.0), 150.0, 24.0, Color("#32ADDA"), 219.7, [GapDefinitionScript.new(50.6, 56.0, 16.0), GapDefinitionScript.new(113.6, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(333.0, 839.0), 76.0, 24.0, Color("#C8202F"), 287.9, [GapDefinitionScript.new(83.0, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(508.0, 517.0), 40.0, 24.0, Color("#C8202F"), 189.6, [GapDefinitionScript.new(12.3, 56.0, 16.0), GapDefinitionScript.new(305.4, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(333.0, 839.0), 115.0, 24.0, Color("#CB2336"), 345.3, [GapDefinitionScript.new(290.5, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(333.0, 839.0), 40.0, 24.0, Color("#29B6F6"), 10.1, [GapDefinitionScript.new(70.7, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(277.0, 420.0), 76.0, 24.0, Color("#62C73E"), 125.6, [GapDefinitionScript.new(290.0, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(204.0, 590.0), 40.0, 24.0, Color("#32ADDA"), 58.2, [])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_9", &"ring_0", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_1", &"ring_9", &"ring_2", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_2", &"ring_2", &"ring_1", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_3", &"ring_1", &"ring_6", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_4", &"ring_6", &"ring_7", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_5", &"ring_0", &"ring_4", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_6", &"ring_7", &"ring_3", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_7", &"ring_1", &"ring_3", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_8", &"ring_0", &"ring_8", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_9", &"ring_2", &"ring_5", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_10", &"ring_9", &"ring_5", Color("#32ADDA"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_5", 221.1, true),
				SolutionStepScript.new(&"ring_5", 347.7, true),
				SolutionStepScript.new(&"ring_8", 92.7, true),
				SolutionStepScript.new(&"ring_3", 184.9, true),
				SolutionStepScript.new(&"ring_3", 309.4, true),
				SolutionStepScript.new(&"ring_4", 215.6, true),
				SolutionStepScript.new(&"ring_7", 289.3, true),
				SolutionStepScript.new(&"ring_6", 8.0, true),
				SolutionStepScript.new(&"ring_1", 278.4, true),
				SolutionStepScript.new(&"ring_2", 124.9, true),
				SolutionStepScript.new(&"ring_0", 192.8, true)
			]

		35:
			def.title = "Level 35"
			def.instruction = "Clear the rings!"
			def.par_moves = 12
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(341.0, 358.0), 40.0, 24.0, Color("#8228D9"), 208.7, [GapDefinitionScript.new(186.2, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(493.0, 595.0), 115.0, 24.0, Color("#4361CF"), 137.9, [GapDefinitionScript.new(14.0, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(341.0, 358.0), 76.0, 24.0, Color("#CB2336"), 97.7, [GapDefinitionScript.new(92.8, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(350.0, 356.0), 150.0, 24.0, Color("#29B6F6"), 93.3, [GapDefinitionScript.new(316.6, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(341.0, 358.0), 115.0, 24.0, Color("#C8202F"), 89.8, [GapDefinitionScript.new(79.1, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(493.0, 595.0), 76.0, 24.0, Color("#29B6F6"), 80.2, [GapDefinitionScript.new(240.2, 56.0, 16.0), GapDefinitionScript.new(90.0, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(372.0, 862.0), 76.0, 24.0, Color("#62C73E"), 164.4, [GapDefinitionScript.new(191.6, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(356.0, 700.0), 40.0, 24.0, Color("#62C73E"), 159.1, [GapDefinitionScript.new(87.4, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(305.0, 563.0), 40.0, 24.0, Color("#C8202F"), 211.3, [])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(204.0, 584.0), 40.0, 24.0, Color("#EA7829"), 62.9, [GapDefinitionScript.new(213.0, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(239.0, 893.0), 40.0, 24.0, Color("#C8202F"), 109.3, [GapDefinitionScript.new(161.1, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_8", &"ring_2", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_1", &"ring_2", &"ring_7", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_2", &"ring_2", &"ring_0", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_3", &"ring_2", &"ring_10", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_4", &"ring_7", &"ring_5", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_5", &"ring_8", &"ring_5", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_6", &"ring_2", &"ring_6", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_7", &"ring_7", &"ring_3", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_8", &"ring_7", &"ring_9", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_9", &"ring_0", &"ring_4", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_10", &"ring_7", &"ring_1", Color("#62C73E"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_1", 128.5, true),
				SolutionStepScript.new(&"ring_4", 280.9, true),
				SolutionStepScript.new(&"ring_9", 184.4, true),
				SolutionStepScript.new(&"ring_3", 132.4, true),
				SolutionStepScript.new(&"ring_6", 74.9, true),
				SolutionStepScript.new(&"ring_5", 99.6, true),
				SolutionStepScript.new(&"ring_5", 262.4, true),
				SolutionStepScript.new(&"ring_10", 119.7, true),
				SolutionStepScript.new(&"ring_0", 173.8, true),
				SolutionStepScript.new(&"ring_7", 180.1, true),
				SolutionStepScript.new(&"ring_2", 7.2, true)
			]

		36:
			def.title = "Level 36"
			def.instruction = "Clear the rings!"
			def.par_moves = 12
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(373.0, 482.0), 76.0, 24.0, Color("#29B6F6"), 48.5, [GapDefinitionScript.new(76.6, 56.0, 16.0), GapDefinitionScript.new(233.3, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(423.0, 841.0), 115.0, 24.0, Color("#62C73E"), 53.7, [GapDefinitionScript.new(107.0, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(373.0, 482.0), 150.0, 24.0, Color("#EA7829"), 359.9, [])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(373.0, 482.0), 115.0, 24.0, Color("#32ADDA"), 39.0, [GapDefinitionScript.new(24.1, 56.0, 16.0), GapDefinitionScript.new(19.5, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(423.0, 841.0), 150.0, 24.0, Color("#C8202F"), 224.5, [GapDefinitionScript.new(38.1, 56.0, 16.0), GapDefinitionScript.new(214.6, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(373.0, 482.0), 40.0, 24.0, Color("#F38224"), 21.6, [GapDefinitionScript.new(13.8, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(423.0, 841.0), 76.0, 24.0, Color("#C8202F"), 199.1, [GapDefinitionScript.new(40.4, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(212.0, 675.0), 40.0, 24.0, Color("#29B6F6"), 63.4, [GapDefinitionScript.new(189.4, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(423.0, 841.0), 40.0, 24.0, Color("#CB2336"), 163.0, [GapDefinitionScript.new(139.8, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_2", &"ring_1", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_1", &"ring_2", &"ring_0", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_2", &"ring_1", &"ring_0", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_3", &"ring_2", &"ring_4", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_4", &"ring_0", &"ring_4", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_5", &"ring_0", &"ring_7", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_6", &"ring_0", &"ring_8", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_7", &"ring_1", &"ring_5", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_8", &"ring_5", &"ring_6", Color("#F38224")),
				LinkDefinitionScript.new(&"link_9", &"ring_4", &"ring_3", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_10", &"ring_7", &"ring_3", Color("#29B6F6"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_3", 110.3, true),
				SolutionStepScript.new(&"ring_3", 57.9, true),
				SolutionStepScript.new(&"ring_6", 221.7, true),
				SolutionStepScript.new(&"ring_5", 68.2, true),
				SolutionStepScript.new(&"ring_8", 122.2, true),
				SolutionStepScript.new(&"ring_7", 120.4, true),
				SolutionStepScript.new(&"ring_4", 47.4, true),
				SolutionStepScript.new(&"ring_4", 223.9, true),
				SolutionStepScript.new(&"ring_0", 208.7, true),
				SolutionStepScript.new(&"ring_0", 283.4, true),
				SolutionStepScript.new(&"ring_1", 155.1, true)
			]

		37:
			def.title = "Level 37"
			def.instruction = "Clear the rings!"
			def.par_moves = 12
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(480.0, 612.0), 76.0, 24.0, Color("#32ADDA"), 94.0, [])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(366.0, 387.0), 40.0, 24.0, Color("#32ADDA"), 136.3, [GapDefinitionScript.new(336.4, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(366.0, 387.0), 115.0, 24.0, Color("#32ADDA"), 328.3, [GapDefinitionScript.new(166.3, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(281.0, 550.0), 40.0, 24.0, Color("#7D2AD4"), 253.4, [GapDefinitionScript.new(160.0, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(267.0, 804.0), 40.0, 24.0, Color("#29B6F6"), 100.7, [GapDefinitionScript.new(345.7, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(480.0, 612.0), 115.0, 24.0, Color("#32ADDA"), 225.0, [GapDefinitionScript.new(172.3, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(480.0, 612.0), 40.0, 24.0, Color("#32ADDA"), 63.2, [GapDefinitionScript.new(65.0, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(288.0, 666.0), 40.0, 24.0, Color("#F38224"), 254.2, [GapDefinitionScript.new(186.9, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(467.0, 813.0), 40.0, 24.0, Color("#8228D9"), 294.7, [GapDefinitionScript.new(171.0, 56.0, 16.0), GapDefinitionScript.new(174.1, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(366.0, 387.0), 76.0, 24.0, Color("#7D2AD4"), 268.7, [GapDefinitionScript.new(269.7, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(267.0, 804.0), 76.0, 24.0, Color("#62C73E"), 99.9, [GapDefinitionScript.new(295.3, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_2", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_1", &"ring_2", &"ring_4", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_2", &"ring_2", &"ring_3", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_3", &"ring_4", &"ring_6", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_4", &"ring_2", &"ring_10", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_5", &"ring_2", &"ring_5", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_6", &"ring_10", &"ring_7", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_7", &"ring_5", &"ring_9", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_8", &"ring_6", &"ring_1", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_9", &"ring_5", &"ring_8", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_10", &"ring_1", &"ring_8", Color("#32ADDA"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_8", 82.5, true),
				SolutionStepScript.new(&"ring_8", 102.7, true),
				SolutionStepScript.new(&"ring_1", 86.7, true),
				SolutionStepScript.new(&"ring_9", 153.4, true),
				SolutionStepScript.new(&"ring_7", 271.8, true),
				SolutionStepScript.new(&"ring_5", 70.8, true),
				SolutionStepScript.new(&"ring_10", 348.0, true),
				SolutionStepScript.new(&"ring_6", 73.0, true),
				SolutionStepScript.new(&"ring_3", 137.5, true),
				SolutionStepScript.new(&"ring_4", 297.7, true),
				SolutionStepScript.new(&"ring_2", 256.8, true)
			]

		38:
			def.title = "Level 38"
			def.instruction = "Clear the rings!"
			def.par_moves = 12
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(431.0, 612.0), 115.0, 24.0, Color("#29B6F6"), 230.9, [GapDefinitionScript.new(193.6, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(238.0, 354.0), 76.0, 24.0, Color("#4361CF"), 143.4, [GapDefinitionScript.new(93.1, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(211.0, 859.0), 150.0, 24.0, Color("#7D2AD4"), 328.4, [GapDefinitionScript.new(148.0, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(211.0, 859.0), 115.0, 24.0, Color("#4361CF"), 67.2, [GapDefinitionScript.new(247.6, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(238.0, 354.0), 40.0, 24.0, Color("#EA7829"), 96.1, [GapDefinitionScript.new(356.7, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(476.0, 841.0), 76.0, 24.0, Color("#7D2AD4"), 294.2, [GapDefinitionScript.new(182.8, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(504.0, 358.0), 76.0, 24.0, Color("#32ADDA"), 234.9, [])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(238.0, 354.0), 150.0, 24.0, Color("#62C73E"), 64.0, [GapDefinitionScript.new(17.2, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(238.0, 354.0), 115.0, 24.0, Color("#C8202F"), 1.9, [GapDefinitionScript.new(128.3, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(211.0, 859.0), 76.0, 24.0, Color("#4361CF"), 96.6, [GapDefinitionScript.new(223.4, 56.0, 16.0), GapDefinitionScript.new(164.1, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(476.0, 841.0), 40.0, 24.0, Color("#8228D9"), 53.8, [GapDefinitionScript.new(135.2, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_6", &"ring_10", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_1", &"ring_10", &"ring_7", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_2", &"ring_10", &"ring_5", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_3", &"ring_10", &"ring_2", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_4", &"ring_6", &"ring_8", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_5", &"ring_8", &"ring_3", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_6", &"ring_8", &"ring_4", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_7", &"ring_3", &"ring_0", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_8", &"ring_4", &"ring_9", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_9", &"ring_0", &"ring_9", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_10", &"ring_10", &"ring_1", Color("#8228D9"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_1", 330.9, true),
				SolutionStepScript.new(&"ring_9", 147.6, true),
				SolutionStepScript.new(&"ring_9", 49.7, true),
				SolutionStepScript.new(&"ring_0", 298.0, true),
				SolutionStepScript.new(&"ring_4", 3.3, true),
				SolutionStepScript.new(&"ring_3", 25.5, true),
				SolutionStepScript.new(&"ring_8", 232.6, true),
				SolutionStepScript.new(&"ring_2", 208.1, true),
				SolutionStepScript.new(&"ring_5", 177.2, true),
				SolutionStepScript.new(&"ring_7", 46.7, true),
				SolutionStepScript.new(&"ring_10", 138.1, true)
			]

		39:
			def.title = "Level 39"
			def.instruction = "Clear the rings!"
			def.par_moves = 13
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(203.0, 706.0), 115.0, 24.0, Color("#4361CF"), 211.5, [GapDefinitionScript.new(202.5, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(278.0, 505.0), 40.0, 24.0, Color("#29B6F6"), 222.6, [GapDefinitionScript.new(0.6, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(407.0, 661.0), 76.0, 24.0, Color("#EA7829"), 5.3, [GapDefinitionScript.new(29.1, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(503.0, 428.0), 115.0, 24.0, Color("#F38224"), 201.5, [GapDefinitionScript.new(281.3, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(203.0, 706.0), 40.0, 24.0, Color("#F38224"), 356.2, [GapDefinitionScript.new(274.8, 56.0, 16.0), GapDefinitionScript.new(190.0, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(203.0, 706.0), 76.0, 24.0, Color("#62C73E"), 106.2, [GapDefinitionScript.new(115.5, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(503.0, 428.0), 40.0, 24.0, Color("#EA7829"), 312.8, [])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(503.0, 428.0), 76.0, 24.0, Color("#32ADDA"), 138.8, [GapDefinitionScript.new(254.7, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(515.0, 747.0), 40.0, 24.0, Color("#62C73E"), 46.2, [GapDefinitionScript.new(239.0, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(411.0, 876.0), 115.0, 24.0, Color("#EA7829"), 314.7, [GapDefinitionScript.new(254.3, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(278.0, 505.0), 76.0, 24.0, Color("#EA7829"), 282.2, [GapDefinitionScript.new(177.0, 56.0, 16.0), GapDefinitionScript.new(50.8, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_6", &"ring_2", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_1", &"ring_2", &"ring_1", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_2", &"ring_1", &"ring_3", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_3", &"ring_6", &"ring_8", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_4", &"ring_1", &"ring_5", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_5", &"ring_3", &"ring_7", Color("#F38224")),
				LinkDefinitionScript.new(&"link_6", &"ring_2", &"ring_10", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_7", &"ring_6", &"ring_10", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_8", &"ring_7", &"ring_0", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_9", &"ring_2", &"ring_9", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_10", &"ring_1", &"ring_4", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_11", &"ring_10", &"ring_4", Color("#EA7829"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_4", 100.5, true),
				SolutionStepScript.new(&"ring_4", 15.7, true),
				SolutionStepScript.new(&"ring_9", 14.6, true),
				SolutionStepScript.new(&"ring_0", 114.7, true),
				SolutionStepScript.new(&"ring_10", 290.3, true),
				SolutionStepScript.new(&"ring_10", 233.4, true),
				SolutionStepScript.new(&"ring_7", 105.3, true),
				SolutionStepScript.new(&"ring_5", 174.9, true),
				SolutionStepScript.new(&"ring_8", 28.8, true),
				SolutionStepScript.new(&"ring_3", 239.8, true),
				SolutionStepScript.new(&"ring_1", 49.8, true),
				SolutionStepScript.new(&"ring_2", 263.3, true)
			]

		40:
			def.title = "Level 40"
			def.instruction = "Clear the rings!"
			def.par_moves = 16
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(292.0, 636.0), 40.0, 24.0, Color("#29B6F6"), 165.0, [GapDefinitionScript.new(220.4, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(292.0, 636.0), 150.0, 24.0, Color("#EA7829"), 302.6, [])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(460.0, 432.0), 40.0, 24.0, Color("#F38224"), 218.0, [GapDefinitionScript.new(291.4, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(292.0, 636.0), 76.0, 24.0, Color("#CB2336"), 343.9, [GapDefinitionScript.new(71.7, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(292.0, 636.0), 115.0, 24.0, Color("#4361CF"), 319.4, [GapDefinitionScript.new(124.1, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(514.0, 528.0), 40.0, 24.0, Color("#CB2336"), 117.9, [GapDefinitionScript.new(5.8, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(487.0, 705.0), 40.0, 24.0, Color("#32ADDA"), 32.3, [GapDefinitionScript.new(38.4, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(330.0, 872.0), 40.0, 24.0, Color("#8228D9"), 66.5, [GapDefinitionScript.new(68.9, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(290.0, 433.0), 40.0, 24.0, Color("#62C73E"), 261.5, [GapDefinitionScript.new(100.6, 56.0, 16.0), GapDefinitionScript.new(203.6, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(480.0, 896.0), 76.0, 24.0, Color("#32ADDA"), 89.8, [GapDefinitionScript.new(46.0, 56.0, 16.0), GapDefinitionScript.new(153.2, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(232.0, 829.0), 40.0, 24.0, Color("#EA7829"), 305.4, [GapDefinitionScript.new(173.7, 56.0, 16.0), GapDefinitionScript.new(181.3, 56.0, 16.0)])
			var r11 = PieceDefinitionScript.new(&"ring_11", Vector2(480.0, 896.0), 40.0, 24.0, Color("#CB2336"), 272.2, [GapDefinitionScript.new(349.5, 56.0, 16.0), GapDefinitionScript.new(283.7, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_1", &"ring_2", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_1", &"ring_1", &"ring_6", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_2", &"ring_2", &"ring_3", Color("#F38224")),
				LinkDefinitionScript.new(&"link_3", &"ring_1", &"ring_0", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_4", &"ring_0", &"ring_5", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_5", &"ring_2", &"ring_11", Color("#F38224")),
				LinkDefinitionScript.new(&"link_6", &"ring_0", &"ring_11", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_7", &"ring_6", &"ring_7", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_8", &"ring_7", &"ring_10", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_9", &"ring_2", &"ring_10", Color("#F38224")),
				LinkDefinitionScript.new(&"link_10", &"ring_11", &"ring_4", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_11", &"ring_10", &"ring_9", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_12", &"ring_6", &"ring_9", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_13", &"ring_7", &"ring_8", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_14", &"ring_4", &"ring_8", Color("#4361CF"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_8", 245.8, true),
				SolutionStepScript.new(&"ring_8", 344.2, true),
				SolutionStepScript.new(&"ring_9", 118.9, true),
				SolutionStepScript.new(&"ring_9", 149.1, true),
				SolutionStepScript.new(&"ring_4", 290.0, true),
				SolutionStepScript.new(&"ring_10", 118.5, true),
				SolutionStepScript.new(&"ring_10", 210.0, true),
				SolutionStepScript.new(&"ring_7", 244.3, true),
				SolutionStepScript.new(&"ring_11", 310.4, true),
				SolutionStepScript.new(&"ring_11", 278.1, true),
				SolutionStepScript.new(&"ring_5", 148.2, true),
				SolutionStepScript.new(&"ring_0", 139.6, true),
				SolutionStepScript.new(&"ring_3", 237.7, true),
				SolutionStepScript.new(&"ring_6", 161.1, true),
				SolutionStepScript.new(&"ring_2", 198.1, true)
			]

		41:
			def.title = "Level 41"
			def.instruction = "Clear the rings!"
			def.par_moves = 12
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(339.0, 620.0), 150.0, 24.0, Color("#F38224"), 242.1, [GapDefinitionScript.new(322.7, 56.0, 16.0), GapDefinitionScript.new(8.3, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(339.0, 620.0), 40.0, 24.0, Color("#62C73E"), 251.0, [GapDefinitionScript.new(268.2, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(220.0, 354.0), 40.0, 24.0, Color("#8228D9"), 160.2, [GapDefinitionScript.new(244.2, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(339.0, 620.0), 115.0, 24.0, Color("#32ADDA"), 265.3, [GapDefinitionScript.new(199.9, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(491.0, 813.0), 40.0, 24.0, Color("#F38224"), 190.9, [])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(491.0, 813.0), 76.0, 24.0, Color("#EA7829"), 308.7, [GapDefinitionScript.new(180.9, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(316.0, 384.0), 40.0, 24.0, Color("#7D2AD4"), 229.5, [GapDefinitionScript.new(342.1, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(335.0, 843.0), 40.0, 24.0, Color("#CB2336"), 214.5, [GapDefinitionScript.new(68.4, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(339.0, 620.0), 76.0, 24.0, Color("#7D2AD4"), 87.2, [GapDefinitionScript.new(173.1, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(495.0, 351.0), 76.0, 24.0, Color("#62C73E"), 140.7, [GapDefinitionScript.new(224.0, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(248.0, 803.0), 40.0, 24.0, Color("#4361CF"), 205.3, [GapDefinitionScript.new(88.7, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_4", &"ring_7", Color("#F38224")),
				LinkDefinitionScript.new(&"link_1", &"ring_7", &"ring_5", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_2", &"ring_7", &"ring_1", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_3", &"ring_4", &"ring_3", Color("#F38224")),
				LinkDefinitionScript.new(&"link_4", &"ring_3", &"ring_2", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_5", &"ring_7", &"ring_8", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_6", &"ring_8", &"ring_9", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_7", &"ring_8", &"ring_0", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_8", &"ring_2", &"ring_0", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_9", &"ring_9", &"ring_6", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_10", &"ring_0", &"ring_10", Color("#F38224"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_10", 207.7, true),
				SolutionStepScript.new(&"ring_6", 7.5, true),
				SolutionStepScript.new(&"ring_0", 237.6, true),
				SolutionStepScript.new(&"ring_0", 37.3, true),
				SolutionStepScript.new(&"ring_9", 256.1, true),
				SolutionStepScript.new(&"ring_8", 277.9, true),
				SolutionStepScript.new(&"ring_2", 181.7, true),
				SolutionStepScript.new(&"ring_3", 211.9, true),
				SolutionStepScript.new(&"ring_1", 182.8, true),
				SolutionStepScript.new(&"ring_5", 348.2, true),
				SolutionStepScript.new(&"ring_7", 280.7, true)
			]

		42:
			def.title = "Level 42"
			def.instruction = "Clear the rings!"
			def.par_moves = 14
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(484.0, 820.0), 150.0, 24.0, Color("#C8202F"), 274.0, [GapDefinitionScript.new(195.6, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(216.0, 439.0), 150.0, 24.0, Color("#CB2336"), 142.3, [GapDefinitionScript.new(268.4, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(484.0, 820.0), 115.0, 24.0, Color("#C8202F"), 224.0, [GapDefinitionScript.new(15.8, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(439.0, 572.0), 40.0, 24.0, Color("#EA7829"), 161.5, [])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(216.0, 439.0), 115.0, 24.0, Color("#8228D9"), 121.1, [GapDefinitionScript.new(0.4, 56.0, 16.0), GapDefinitionScript.new(167.8, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(211.0, 681.0), 76.0, 24.0, Color("#62C73E"), 326.2, [GapDefinitionScript.new(81.0, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(216.0, 439.0), 76.0, 24.0, Color("#32ADDA"), 99.7, [GapDefinitionScript.new(355.3, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(216.0, 439.0), 40.0, 24.0, Color("#F38224"), 125.5, [GapDefinitionScript.new(9.6, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(484.0, 820.0), 40.0, 24.0, Color("#7D2AD4"), 52.0, [GapDefinitionScript.new(355.5, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(274.0, 811.0), 40.0, 24.0, Color("#EA7829"), 142.7, [GapDefinitionScript.new(150.9, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(484.0, 820.0), 76.0, 24.0, Color("#F38224"), 31.9, [GapDefinitionScript.new(14.0, 56.0, 16.0), GapDefinitionScript.new(222.8, 56.0, 16.0)])
			var r11 = PieceDefinitionScript.new(&"ring_11", Vector2(500.0, 405.0), 76.0, 24.0, Color("#29B6F6"), 7.2, [GapDefinitionScript.new(24.3, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_3", &"ring_6", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_1", &"ring_6", &"ring_9", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_2", &"ring_9", &"ring_4", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_3", &"ring_3", &"ring_4", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_4", &"ring_6", &"ring_0", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_5", &"ring_0", &"ring_7", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_6", &"ring_6", &"ring_5", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_7", &"ring_6", &"ring_11", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_8", &"ring_11", &"ring_1", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_9", &"ring_7", &"ring_2", Color("#F38224")),
				LinkDefinitionScript.new(&"link_10", &"ring_1", &"ring_8", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_11", &"ring_11", &"ring_10", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_12", &"ring_6", &"ring_10", Color("#32ADDA"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_10", 12.1, true),
				SolutionStepScript.new(&"ring_10", 258.2, true),
				SolutionStepScript.new(&"ring_8", 239.3, true),
				SolutionStepScript.new(&"ring_2", 219.1, true),
				SolutionStepScript.new(&"ring_1", 84.8, true),
				SolutionStepScript.new(&"ring_11", 148.9, true),
				SolutionStepScript.new(&"ring_5", 190.1, true),
				SolutionStepScript.new(&"ring_7", 45.2, true),
				SolutionStepScript.new(&"ring_0", 39.3, true),
				SolutionStepScript.new(&"ring_4", 223.0, true),
				SolutionStepScript.new(&"ring_4", 80.7, true),
				SolutionStepScript.new(&"ring_9", 110.2, true),
				SolutionStepScript.new(&"ring_6", 35.6, true)
			]

		43:
			def.title = "Level 43"
			def.instruction = "Clear the rings!"
			def.par_moves = 11
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(306.0, 459.0), 115.0, 24.0, Color("#29B6F6"), 192.3, [GapDefinitionScript.new(54.4, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(368.0, 790.0), 150.0, 24.0, Color("#62C73E"), 346.8, [GapDefinitionScript.new(131.0, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(368.0, 790.0), 115.0, 24.0, Color("#4361CF"), 112.6, [])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(306.0, 459.0), 150.0, 24.0, Color("#8228D9"), 17.0, [GapDefinitionScript.new(41.9, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(368.0, 790.0), 76.0, 24.0, Color("#32ADDA"), 145.2, [GapDefinitionScript.new(283.0, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(306.0, 459.0), 76.0, 24.0, Color("#4361CF"), 109.6, [GapDefinitionScript.new(335.4, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(306.0, 459.0), 40.0, 24.0, Color("#32ADDA"), 287.2, [GapDefinitionScript.new(147.1, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(504.0, 618.0), 40.0, 24.0, Color("#C8202F"), 312.5, [GapDefinitionScript.new(68.5, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(490.0, 373.0), 40.0, 24.0, Color("#62C73E"), 274.7, [GapDefinitionScript.new(289.3, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(368.0, 790.0), 40.0, 24.0, Color("#62C73E"), 14.7, [GapDefinitionScript.new(129.9, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(509.0, 480.0), 40.0, 24.0, Color("#CB2336"), 26.9, [GapDefinitionScript.new(253.5, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_2", &"ring_8", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_1", &"ring_2", &"ring_7", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_2", &"ring_2", &"ring_4", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_3", &"ring_2", &"ring_10", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_4", &"ring_10", &"ring_0", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_5", &"ring_10", &"ring_1", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_6", &"ring_7", &"ring_9", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_7", &"ring_1", &"ring_6", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_8", &"ring_4", &"ring_3", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_9", &"ring_2", &"ring_5", Color("#4361CF"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_5", 104.0, true),
				SolutionStepScript.new(&"ring_3", 37.5, true),
				SolutionStepScript.new(&"ring_6", 292.3, true),
				SolutionStepScript.new(&"ring_9", 178.4, true),
				SolutionStepScript.new(&"ring_1", 163.4, true),
				SolutionStepScript.new(&"ring_0", 311.5, true),
				SolutionStepScript.new(&"ring_10", 221.0, true),
				SolutionStepScript.new(&"ring_4", 77.0, true),
				SolutionStepScript.new(&"ring_7", 59.8, true),
				SolutionStepScript.new(&"ring_8", 177.0, true)
			]

		44:
			def.title = "Level 44"
			def.instruction = "Clear the rings!"
			def.par_moves = 13
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(393.0, 367.0), 40.0, 24.0, Color("#32ADDA"), 258.7, [GapDefinitionScript.new(28.2, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(393.0, 367.0), 115.0, 24.0, Color("#8228D9"), 10.6, [GapDefinitionScript.new(219.8, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(283.0, 746.0), 40.0, 24.0, Color("#CB2336"), 304.4, [GapDefinitionScript.new(85.9, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(393.0, 367.0), 76.0, 24.0, Color("#29B6F6"), 321.5, [GapDefinitionScript.new(90.5, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(488.0, 514.0), 40.0, 24.0, Color("#F38224"), 61.3, [])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(335.0, 604.0), 40.0, 24.0, Color("#F38224"), 133.4, [GapDefinitionScript.new(46.2, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(209.0, 868.0), 40.0, 24.0, Color("#F38224"), 197.6, [GapDefinitionScript.new(298.8, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(204.0, 494.0), 76.0, 24.0, Color("#C8202F"), 344.3, [GapDefinitionScript.new(66.7, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(480.0, 874.0), 115.0, 24.0, Color("#29B6F6"), 69.1, [GapDefinitionScript.new(190.5, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(335.0, 604.0), 76.0, 24.0, Color("#C8202F"), 224.6, [GapDefinitionScript.new(222.9, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(480.0, 874.0), 76.0, 24.0, Color("#8228D9"), 254.1, [GapDefinitionScript.new(141.1, 56.0, 16.0)])
			var r11 = PieceDefinitionScript.new(&"ring_11", Vector2(501.0, 643.0), 76.0, 24.0, Color("#7D2AD4"), 149.0, [GapDefinitionScript.new(165.0, 56.0, 16.0), GapDefinitionScript.new(215.2, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_4", &"ring_5", Color("#F38224")),
				LinkDefinitionScript.new(&"link_1", &"ring_5", &"ring_6", Color("#F38224")),
				LinkDefinitionScript.new(&"link_2", &"ring_4", &"ring_0", Color("#F38224")),
				LinkDefinitionScript.new(&"link_3", &"ring_0", &"ring_2", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_4", &"ring_2", &"ring_10", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_5", &"ring_5", &"ring_9", Color("#F38224")),
				LinkDefinitionScript.new(&"link_6", &"ring_10", &"ring_11", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_7", &"ring_9", &"ring_11", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_8", &"ring_10", &"ring_7", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_9", &"ring_2", &"ring_3", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_10", &"ring_3", &"ring_1", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_11", &"ring_10", &"ring_8", Color("#8228D9"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_8", 169.5, true),
				SolutionStepScript.new(&"ring_1", 140.2, true),
				SolutionStepScript.new(&"ring_3", 15.7, true),
				SolutionStepScript.new(&"ring_7", 347.3, true),
				SolutionStepScript.new(&"ring_11", 338.0, true),
				SolutionStepScript.new(&"ring_11", 290.2, true),
				SolutionStepScript.new(&"ring_9", 137.1, true),
				SolutionStepScript.new(&"ring_10", 71.9, true),
				SolutionStepScript.new(&"ring_2", 200.3, true),
				SolutionStepScript.new(&"ring_0", 29.0, true),
				SolutionStepScript.new(&"ring_6", 356.7, true),
				SolutionStepScript.new(&"ring_5", 283.3, true)
			]

		45:
			def.title = "Level 45"
			def.instruction = "Clear the rings!"
			def.par_moves = 15
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(215.0, 357.0), 76.0, 24.0, Color("#C8202F"), 180.3, [GapDefinitionScript.new(127.7, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(519.0, 691.0), 76.0, 24.0, Color("#32ADDA"), 166.7, [GapDefinitionScript.new(12.6, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(215.0, 357.0), 150.0, 24.0, Color("#32ADDA"), 138.6, [])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(215.0, 357.0), 40.0, 24.0, Color("#62C73E"), 224.2, [GapDefinitionScript.new(101.3, 56.0, 16.0), GapDefinitionScript.new(183.1, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(254.0, 744.0), 76.0, 24.0, Color("#8228D9"), 30.6, [GapDefinitionScript.new(50.2, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(519.0, 691.0), 150.0, 24.0, Color("#EA7829"), 9.2, [GapDefinitionScript.new(305.8, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(215.0, 357.0), 115.0, 24.0, Color("#C8202F"), 74.5, [GapDefinitionScript.new(302.8, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(519.0, 691.0), 115.0, 24.0, Color("#4361CF"), 167.3, [GapDefinitionScript.new(246.7, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(258.0, 595.0), 40.0, 24.0, Color("#C8202F"), 130.3, [GapDefinitionScript.new(32.5, 56.0, 16.0), GapDefinitionScript.new(216.9, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(490.0, 352.0), 76.0, 24.0, Color("#32ADDA"), 27.4, [GapDefinitionScript.new(324.9, 56.0, 16.0), GapDefinitionScript.new(165.3, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(335.0, 526.0), 40.0, 24.0, Color("#32ADDA"), 136.0, [GapDefinitionScript.new(30.1, 56.0, 16.0)])
			var r11 = PieceDefinitionScript.new(&"ring_11", Vector2(519.0, 691.0), 40.0, 24.0, Color("#4361CF"), 285.0, [GapDefinitionScript.new(181.3, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_2", &"ring_6", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_1", &"ring_2", &"ring_3", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_2", &"ring_6", &"ring_3", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_3", &"ring_6", &"ring_4", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_4", &"ring_3", &"ring_10", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_5", &"ring_10", &"ring_8", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_6", &"ring_3", &"ring_8", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_7", &"ring_6", &"ring_9", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_8", &"ring_2", &"ring_9", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_9", &"ring_3", &"ring_11", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_10", &"ring_8", &"ring_5", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_11", &"ring_10", &"ring_7", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_12", &"ring_5", &"ring_1", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_13", &"ring_10", &"ring_0", Color("#32ADDA"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_0", 286.9, true),
				SolutionStepScript.new(&"ring_1", 347.4, true),
				SolutionStepScript.new(&"ring_7", 335.2, true),
				SolutionStepScript.new(&"ring_5", 254.4, true),
				SolutionStepScript.new(&"ring_11", 46.4, true),
				SolutionStepScript.new(&"ring_9", 13.6, true),
				SolutionStepScript.new(&"ring_9", 214.0, true),
				SolutionStepScript.new(&"ring_8", 42.8, true),
				SolutionStepScript.new(&"ring_8", 285.6, true),
				SolutionStepScript.new(&"ring_10", 204.5, true),
				SolutionStepScript.new(&"ring_4", 214.0, true),
				SolutionStepScript.new(&"ring_3", 176.9, true),
				SolutionStepScript.new(&"ring_3", 258.7, true),
				SolutionStepScript.new(&"ring_6", 57.2, true)
			]

		46:
			def.title = "Level 46"
			def.instruction = "Clear the rings!"
			def.par_moves = 13
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(450.0, 725.0), 76.0, 24.0, Color("#8228D9"), 158.5, [GapDefinitionScript.new(167.4, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(450.0, 725.0), 40.0, 24.0, Color("#CB2336"), 343.3, [GapDefinitionScript.new(186.5, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(414.0, 488.0), 76.0, 24.0, Color("#CB2336"), 19.5, [GapDefinitionScript.new(260.8, 56.0, 16.0), GapDefinitionScript.new(109.2, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(414.0, 488.0), 150.0, 24.0, Color("#F38224"), 20.4, [GapDefinitionScript.new(262.6, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(218.0, 829.0), 76.0, 24.0, Color("#29B6F6"), 329.3, [GapDefinitionScript.new(348.0, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(414.0, 488.0), 40.0, 24.0, Color("#C8202F"), 69.9, [GapDefinitionScript.new(151.4, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(218.0, 829.0), 40.0, 24.0, Color("#8228D9"), 213.6, [GapDefinitionScript.new(303.4, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(340.0, 875.0), 40.0, 24.0, Color("#F38224"), 70.6, [GapDefinitionScript.new(242.2, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(210.0, 627.0), 40.0, 24.0, Color("#F38224"), 212.1, [GapDefinitionScript.new(241.2, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(414.0, 488.0), 115.0, 24.0, Color("#32ADDA"), 214.3, [])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(209.0, 390.0), 40.0, 24.0, Color("#8228D9"), 39.2, [GapDefinitionScript.new(356.9, 56.0, 16.0)])
			var r11 = PieceDefinitionScript.new(&"ring_11", Vector2(210.0, 627.0), 76.0, 24.0, Color("#F38224"), 194.7, [GapDefinitionScript.new(333.9, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_9", &"ring_1", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_1", &"ring_1", &"ring_8", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_2", &"ring_1", &"ring_5", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_3", &"ring_1", &"ring_11", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_4", &"ring_5", &"ring_4", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_5", &"ring_9", &"ring_10", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_6", &"ring_8", &"ring_2", Color("#F38224")),
				LinkDefinitionScript.new(&"link_7", &"ring_1", &"ring_2", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_8", &"ring_9", &"ring_3", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_9", &"ring_1", &"ring_0", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_10", &"ring_0", &"ring_6", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_11", &"ring_9", &"ring_7", Color("#32ADDA"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_7", 38.7, true),
				SolutionStepScript.new(&"ring_6", 32.4, true),
				SolutionStepScript.new(&"ring_0", 192.6, true),
				SolutionStepScript.new(&"ring_3", 97.4, true),
				SolutionStepScript.new(&"ring_2", 332.2, true),
				SolutionStepScript.new(&"ring_2", 245.0, true),
				SolutionStepScript.new(&"ring_10", 28.6, true),
				SolutionStepScript.new(&"ring_4", 311.9, true),
				SolutionStepScript.new(&"ring_11", 48.3, true),
				SolutionStepScript.new(&"ring_5", 290.0, true),
				SolutionStepScript.new(&"ring_8", 141.1, true),
				SolutionStepScript.new(&"ring_1", 74.8, true)
			]

		47:
			def.title = "Level 47"
			def.instruction = "Clear the rings!"
			def.par_moves = 12
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(278.0, 737.0), 76.0, 24.0, Color("#4361CF"), 332.5, [])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(349.0, 432.0), 115.0, 24.0, Color("#4361CF"), 181.3, [GapDefinitionScript.new(45.5, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(499.0, 889.0), 150.0, 24.0, Color("#C8202F"), 41.0, [GapDefinitionScript.new(58.6, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(499.0, 889.0), 76.0, 24.0, Color("#C8202F"), 286.0, [GapDefinitionScript.new(266.3, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(462.0, 553.0), 40.0, 24.0, Color("#4361CF"), 233.6, [GapDefinitionScript.new(214.5, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(499.0, 889.0), 40.0, 24.0, Color("#CB2336"), 231.1, [GapDefinitionScript.new(185.6, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(349.0, 432.0), 76.0, 24.0, Color("#C8202F"), 124.6, [GapDefinitionScript.new(152.5, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(499.0, 889.0), 115.0, 24.0, Color("#CB2336"), 220.8, [GapDefinitionScript.new(79.6, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(481.0, 665.0), 40.0, 24.0, Color("#7D2AD4"), 78.9, [GapDefinitionScript.new(238.1, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(347.0, 429.0), 40.0, 24.0, Color("#32ADDA"), 118.4, [GapDefinitionScript.new(273.8, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(386.0, 650.0), 40.0, 24.0, Color("#29B6F6"), 259.8, [GapDefinitionScript.new(269.8, 56.0, 16.0)])
			var r11 = PieceDefinitionScript.new(&"ring_11", Vector2(278.0, 737.0), 40.0, 24.0, Color("#EA7829"), 297.8, [GapDefinitionScript.new(137.2, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_5", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_1", &"ring_5", &"ring_8", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_2", &"ring_5", &"ring_2", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_3", &"ring_8", &"ring_11", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_4", &"ring_0", &"ring_1", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_5", &"ring_1", &"ring_4", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_6", &"ring_4", &"ring_9", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_7", &"ring_1", &"ring_6", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_8", &"ring_6", &"ring_7", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_9", &"ring_11", &"ring_3", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_10", &"ring_4", &"ring_10", Color("#4361CF"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_10", 38.3, true),
				SolutionStepScript.new(&"ring_3", 308.2, true),
				SolutionStepScript.new(&"ring_7", 172.2, true),
				SolutionStepScript.new(&"ring_6", 207.5, true),
				SolutionStepScript.new(&"ring_9", 133.4, true),
				SolutionStepScript.new(&"ring_4", 12.5, true),
				SolutionStepScript.new(&"ring_1", 57.6, true),
				SolutionStepScript.new(&"ring_11", 203.3, true),
				SolutionStepScript.new(&"ring_2", 301.4, true),
				SolutionStepScript.new(&"ring_8", 207.3, true),
				SolutionStepScript.new(&"ring_5", 28.9, true)
			]

		48:
			def.title = "Level 48"
			def.instruction = "Clear the rings!"
			def.par_moves = 13
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(273.0, 797.0), 150.0, 24.0, Color("#29B6F6"), 31.9, [GapDefinitionScript.new(241.1, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(273.0, 797.0), 115.0, 24.0, Color("#C8202F"), 312.2, [GapDefinitionScript.new(122.1, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(395.0, 548.0), 115.0, 24.0, Color("#F38224"), 300.9, [GapDefinitionScript.new(162.2, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(225.0, 422.0), 40.0, 24.0, Color("#C8202F"), 94.5, [GapDefinitionScript.new(31.2, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(495.0, 406.0), 40.0, 24.0, Color("#CB2336"), 187.5, [GapDefinitionScript.new(225.8, 56.0, 16.0), GapDefinitionScript.new(100.4, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(273.0, 797.0), 40.0, 24.0, Color("#F38224"), 147.7, [GapDefinitionScript.new(38.8, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(395.0, 548.0), 76.0, 24.0, Color("#62C73E"), 298.1, [GapDefinitionScript.new(260.3, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(395.0, 548.0), 40.0, 24.0, Color("#62C73E"), 128.0, [GapDefinitionScript.new(189.5, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(518.0, 826.0), 76.0, 24.0, Color("#62C73E"), 223.0, [GapDefinitionScript.new(45.5, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(225.0, 422.0), 76.0, 24.0, Color("#7D2AD4"), 198.0, [GapDefinitionScript.new(172.7, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(273.0, 797.0), 76.0, 24.0, Color("#32ADDA"), 167.5, [])
			var r11 = PieceDefinitionScript.new(&"ring_11", Vector2(518.0, 826.0), 40.0, 24.0, Color("#62C73E"), 337.5, [GapDefinitionScript.new(331.1, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_10", &"ring_5", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_1", &"ring_10", &"ring_0", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_2", &"ring_10", &"ring_7", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_3", &"ring_5", &"ring_8", Color("#F38224")),
				LinkDefinitionScript.new(&"link_4", &"ring_5", &"ring_11", Color("#F38224")),
				LinkDefinitionScript.new(&"link_5", &"ring_11", &"ring_9", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_6", &"ring_7", &"ring_2", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_7", &"ring_10", &"ring_6", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_8", &"ring_11", &"ring_1", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_9", &"ring_11", &"ring_3", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_10", &"ring_7", &"ring_4", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_11", &"ring_10", &"ring_4", Color("#32ADDA"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_4", 19.2, true),
				SolutionStepScript.new(&"ring_4", 259.3, true),
				SolutionStepScript.new(&"ring_3", 22.9, true),
				SolutionStepScript.new(&"ring_1", 244.6, true),
				SolutionStepScript.new(&"ring_6", 215.9, true),
				SolutionStepScript.new(&"ring_2", 197.8, true),
				SolutionStepScript.new(&"ring_9", 241.4, true),
				SolutionStepScript.new(&"ring_11", 215.6, true),
				SolutionStepScript.new(&"ring_8", 141.2, true),
				SolutionStepScript.new(&"ring_7", 286.6, true),
				SolutionStepScript.new(&"ring_0", 118.9, true),
				SolutionStepScript.new(&"ring_5", 321.2, true)
			]

		49:
			def.title = "Level 49"
			def.instruction = "Clear the rings!"
			def.par_moves = 15
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(490.0, 624.0), 150.0, 24.0, Color("#32ADDA"), 288.6, [GapDefinitionScript.new(321.1, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(358.0, 830.0), 76.0, 24.0, Color("#32ADDA"), 227.9, [GapDefinitionScript.new(139.4, 56.0, 16.0), GapDefinitionScript.new(197.7, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(436.0, 375.0), 40.0, 24.0, Color("#62C73E"), 332.2, [GapDefinitionScript.new(158.6, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(436.0, 375.0), 76.0, 24.0, Color("#4361CF"), 310.6, [GapDefinitionScript.new(128.5, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(490.0, 624.0), 40.0, 24.0, Color("#F38224"), 293.3, [GapDefinitionScript.new(252.5, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(237.0, 627.0), 76.0, 24.0, Color("#8228D9"), 93.8, [GapDefinitionScript.new(176.5, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(237.0, 627.0), 40.0, 24.0, Color("#8228D9"), 298.1, [GapDefinitionScript.new(117.1, 56.0, 16.0), GapDefinitionScript.new(319.3, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(490.0, 624.0), 76.0, 24.0, Color("#EA7829"), 99.9, [GapDefinitionScript.new(196.5, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(263.0, 374.0), 40.0, 24.0, Color("#29B6F6"), 266.5, [])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(490.0, 624.0), 115.0, 24.0, Color("#C8202F"), 273.5, [GapDefinitionScript.new(177.2, 56.0, 16.0), GapDefinitionScript.new(244.8, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(236.0, 881.0), 40.0, 24.0, Color("#CB2336"), 4.4, [GapDefinitionScript.new(298.1, 56.0, 16.0)])
			var r11 = PieceDefinitionScript.new(&"ring_11", Vector2(342.0, 479.0), 40.0, 24.0, Color("#C8202F"), 181.7, [GapDefinitionScript.new(97.5, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_8", &"ring_2", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_1", &"ring_8", &"ring_1", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_2", &"ring_2", &"ring_1", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_3", &"ring_2", &"ring_6", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_4", &"ring_1", &"ring_6", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_5", &"ring_6", &"ring_0", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_6", &"ring_1", &"ring_3", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_7", &"ring_1", &"ring_9", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_8", &"ring_6", &"ring_9", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_9", &"ring_8", &"ring_5", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_10", &"ring_3", &"ring_10", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_11", &"ring_3", &"ring_11", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_12", &"ring_8", &"ring_7", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_13", &"ring_1", &"ring_4", Color("#32ADDA"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_4", 230.1, true),
				SolutionStepScript.new(&"ring_7", 31.3, true),
				SolutionStepScript.new(&"ring_11", 214.6, true),
				SolutionStepScript.new(&"ring_10", 353.4, true),
				SolutionStepScript.new(&"ring_5", 99.3, true),
				SolutionStepScript.new(&"ring_9", 294.5, true),
				SolutionStepScript.new(&"ring_9", 305.4, true),
				SolutionStepScript.new(&"ring_3", 331.2, true),
				SolutionStepScript.new(&"ring_0", 218.3, true),
				SolutionStepScript.new(&"ring_6", 99.9, true),
				SolutionStepScript.new(&"ring_6", 191.2, true),
				SolutionStepScript.new(&"ring_1", 82.0, true),
				SolutionStepScript.new(&"ring_1", 118.8, true),
				SolutionStepScript.new(&"ring_2", 21.8, true)
			]

		50:
			def.title = "Level 50"
			def.instruction = "Clear the rings!"
			def.par_moves = 12
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(293.0, 773.0), 115.0, 24.0, Color("#4361CF"), 222.6, [GapDefinitionScript.new(78.1, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(293.0, 773.0), 150.0, 24.0, Color("#4361CF"), 168.4, [])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(346.0, 498.0), 76.0, 24.0, Color("#CB2336"), 231.1, [GapDefinitionScript.new(16.1, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(346.0, 498.0), 115.0, 24.0, Color("#7D2AD4"), 246.5, [GapDefinitionScript.new(267.1, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(520.0, 499.0), 40.0, 24.0, Color("#CB2336"), 92.6, [GapDefinitionScript.new(129.5, 56.0, 16.0), GapDefinitionScript.new(12.6, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(227.0, 370.0), 40.0, 24.0, Color("#7D2AD4"), 203.2, [GapDefinitionScript.new(163.4, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(485.0, 595.0), 40.0, 24.0, Color("#EA7829"), 263.4, [GapDefinitionScript.new(176.8, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(293.0, 773.0), 40.0, 24.0, Color("#C8202F"), 115.4, [GapDefinitionScript.new(354.0, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(346.0, 498.0), 40.0, 24.0, Color("#C8202F"), 81.1, [GapDefinitionScript.new(250.5, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(293.0, 773.0), 76.0, 24.0, Color("#29B6F6"), 244.3, [GapDefinitionScript.new(118.2, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(520.0, 876.0), 40.0, 24.0, Color("#C8202F"), 359.3, [GapDefinitionScript.new(71.8, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_1", &"ring_2", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_1", &"ring_2", &"ring_3", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_2", &"ring_3", &"ring_5", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_3", &"ring_5", &"ring_9", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_4", &"ring_9", &"ring_10", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_5", &"ring_1", &"ring_8", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_6", &"ring_3", &"ring_4", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_7", &"ring_1", &"ring_4", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_8", &"ring_10", &"ring_0", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_9", &"ring_10", &"ring_6", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_10", &"ring_10", &"ring_7", Color("#C8202F"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_7", 30.4, true),
				SolutionStepScript.new(&"ring_6", 266.1, true),
				SolutionStepScript.new(&"ring_0", 306.3, true),
				SolutionStepScript.new(&"ring_4", 117.0, true),
				SolutionStepScript.new(&"ring_4", 50.8, true),
				SolutionStepScript.new(&"ring_8", 210.4, true),
				SolutionStepScript.new(&"ring_10", 132.6, true),
				SolutionStepScript.new(&"ring_9", 142.5, true),
				SolutionStepScript.new(&"ring_5", 243.7, true),
				SolutionStepScript.new(&"ring_3", 92.9, true),
				SolutionStepScript.new(&"ring_2", 84.8, true)
			]


		_:
			def = get_level(1)

	return def

static func get_total_levels() -> int:
	return 50
