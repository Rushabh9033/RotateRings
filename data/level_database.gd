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

		_:
			def = get_level(1)

	return def

static func get_total_levels() -> int:
	return 12
