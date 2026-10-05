		13:
			def.title = "Level 13"
			def.instruction = "Clear the rings!"
			def.par_moves = 7
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(387.0, 629.0), 115.0, 24.0, Color("#7D2AD4"), 84.3, [])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(267.0, 351.0), 115.0, 24.0, Color("#C8202F"), 67.2, [GapDefinitionScript.new(34.9, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(267.0, 351.0), 150.0, 24.0, Color("#F38224"), 231.3, [GapDefinitionScript.new(17.0, 56.0, 16.0), GapDefinitionScript.new(176.2, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(267.0, 351.0), 76.0, 24.0, Color("#29B6F6"), 335.8, [GapDefinitionScript.new(273.8, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(257.0, 898.0), 76.0, 24.0, Color("#32ADDA"), 126.9, [GapDefinitionScript.new(292.8, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(267.0, 351.0), 40.0, 24.0, Color("#EA7829"), 293.4, [GapDefinitionScript.new(185.0, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_4", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_1", &"ring_0", &"ring_5", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_2", &"ring_4", &"ring_3", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_3", &"ring_0", &"ring_1", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_4", &"ring_4", &"ring_2", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_5", &"ring_0", &"ring_2", Color("#7D2AD4"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_2", 250.4, true),
				SolutionStepScript.new(&"ring_2", 74.1, true),
				SolutionStepScript.new(&"ring_1", 31.8, true),
				SolutionStepScript.new(&"ring_3", 177.3, true),
				SolutionStepScript.new(&"ring_5", 241.6, true),
				SolutionStepScript.new(&"ring_4", 3.0, true)
			]

		14:
			def.title = "Level 14"
			def.instruction = "Clear the rings!"
			def.par_moves = 7
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(299.0, 547.0), 115.0, 24.0, Color("#C8202F"), 277.7, [GapDefinitionScript.new(71.9, 56.0, 16.0), GapDefinitionScript.new(3.0, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(299.0, 547.0), 76.0, 24.0, Color("#7D2AD4"), 181.0, [GapDefinitionScript.new(212.9, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(517.0, 828.0), 76.0, 24.0, Color("#32ADDA"), 81.3, [GapDefinitionScript.new(322.9, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(299.0, 547.0), 40.0, 24.0, Color("#29B6F6"), 36.8, [GapDefinitionScript.new(253.1, 56.0, 16.0), GapDefinitionScript.new(329.2, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(316.0, 818.0), 40.0, 24.0, Color("#F38224"), 276.7, [])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(316.0, 818.0), 76.0, 24.0, Color("#EA7829"), 180.0, [])
			def.pieces = [r0, r1, r2, r3, r4, r5]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_5", &"ring_0", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_1", &"ring_4", &"ring_0", Color("#F38224")),
				LinkDefinitionScript.new(&"link_2", &"ring_5", &"ring_2", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_3", &"ring_2", &"ring_3", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_4", &"ring_4", &"ring_3", Color("#F38224")),
				LinkDefinitionScript.new(&"link_5", &"ring_5", &"ring_1", Color("#EA7829"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_1", 233.5, true),
				SolutionStepScript.new(&"ring_3", 117.2, true),
				SolutionStepScript.new(&"ring_3", 159.1, true),
				SolutionStepScript.new(&"ring_2", 219.9, true),
				SolutionStepScript.new(&"ring_0", 83.4, true),
				SolutionStepScript.new(&"ring_0", 14.5, true)
			]

		15:
			def.title = "Level 15"
			def.instruction = "Clear the rings!"
			def.par_moves = 7
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(499.0, 771.0), 76.0, 24.0, Color("#7D2AD4"), 261.2, [GapDefinitionScript.new(188.0, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(213.0, 518.0), 150.0, 24.0, Color("#7D2AD4"), 221.3, [GapDefinitionScript.new(101.4, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(213.0, 518.0), 115.0, 24.0, Color("#8228D9"), 30.0, [])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(343.0, 864.0), 40.0, 24.0, Color("#4361CF"), 323.3, [GapDefinitionScript.new(190.8, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(484.0, 561.0), 76.0, 24.0, Color("#29B6F6"), 120.2, [GapDefinitionScript.new(51.1, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(499.0, 771.0), 40.0, 24.0, Color("#F38224"), 73.8, [GapDefinitionScript.new(152.1, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(343.0, 864.0), 76.0, 24.0, Color("#CB2336"), 152.0, [GapDefinitionScript.new(244.7, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_2", &"ring_3", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_1", &"ring_2", &"ring_0", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_2", &"ring_2", &"ring_6", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_3", &"ring_6", &"ring_1", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_4", &"ring_3", &"ring_4", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_5", &"ring_1", &"ring_5", Color("#7D2AD4"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_5", 69.4, true),
				SolutionStepScript.new(&"ring_4", 63.8, true),
				SolutionStepScript.new(&"ring_1", 328.1, true),
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
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(392.0, 650.0), 76.0, 24.0, Color("#8228D9"), 267.8, [GapDefinitionScript.new(54.8, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(392.0, 650.0), 40.0, 24.0, Color("#62C73E"), 327.0, [])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(322.0, 414.0), 115.0, 24.0, Color("#62C73E"), 64.1, [GapDefinitionScript.new(121.9, 56.0, 16.0), GapDefinitionScript.new(145.2, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(489.0, 734.0), 40.0, 24.0, Color("#4361CF"), 78.7, [GapDefinitionScript.new(10.6, 56.0, 16.0), GapDefinitionScript.new(245.2, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(219.0, 819.0), 115.0, 24.0, Color("#4361CF"), 193.6, [GapDefinitionScript.new(79.2, 56.0, 16.0), GapDefinitionScript.new(117.1, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_3", &"ring_1", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_1", &"ring_1", &"ring_0", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_2", &"ring_3", &"ring_0", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_3", &"ring_1", &"ring_2", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_4", &"ring_1", &"ring_5", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_5", &"ring_3", &"ring_5", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_6", &"ring_5", &"ring_6", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_7", &"ring_1", &"ring_6", Color("#7D2AD4")),
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
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(474.0, 695.0), 76.0, 24.0, Color("#F38224"), 42.8, [GapDefinitionScript.new(325.5, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(474.0, 695.0), 115.0, 24.0, Color("#29B6F6"), 322.3, [GapDefinitionScript.new(181.3, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(235.0, 388.0), 76.0, 24.0, Color("#8228D9"), 126.9, [GapDefinitionScript.new(281.7, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(209.0, 801.0), 150.0, 24.0, Color("#7D2AD4"), 185.2, [GapDefinitionScript.new(94.2, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(209.0, 801.0), 76.0, 24.0, Color("#C8202F"), 150.6, [GapDefinitionScript.new(110.2, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(337.0, 573.0), 40.0, 24.0, Color("#62C73E"), 222.6, [GapDefinitionScript.new(151.6, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_2", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_1", &"ring_0", &"ring_5", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_2", &"ring_2", &"ring_6", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_3", &"ring_0", &"ring_1", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_4", &"ring_0", &"ring_3", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_5", &"ring_3", &"ring_4", Color("#8228D9"))
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
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(213.0, 410.0), 40.0, 24.0, Color("#C8202F"), 167.7, [GapDefinitionScript.new(284.5, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(213.0, 410.0), 76.0, 24.0, Color("#29B6F6"), 222.4, [GapDefinitionScript.new(60.3, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(433.0, 775.0), 150.0, 24.0, Color("#7D2AD4"), 206.1, [GapDefinitionScript.new(353.8, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(433.0, 775.0), 40.0, 24.0, Color("#F38224"), 211.8, [GapDefinitionScript.new(151.2, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(433.0, 775.0), 76.0, 24.0, Color("#7D2AD4"), 298.7, [GapDefinitionScript.new(49.6, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(501.0, 390.0), 76.0, 24.0, Color("#C8202F"), 109.7, [])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_6", &"ring_0", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_1", &"ring_0", &"ring_4", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_2", &"ring_6", &"ring_2", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_3", &"ring_2", &"ring_5", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_4", &"ring_2", &"ring_3", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_5", &"ring_5", &"ring_1", Color("#7D2AD4"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_1", 134.4, true),
				SolutionStepScript.new(&"ring_3", 245.1, true),
				SolutionStepScript.new(&"ring_5", 189.3, true),
				SolutionStepScript.new(&"ring_2", 295.7, true),
				SolutionStepScript.new(&"ring_4", 87.7, true),
				SolutionStepScript.new(&"ring_0", 181.9, true)
			]

		19:
			def.title = "Level 19"
			def.instruction = "Clear the rings!"
			def.par_moves = 6
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(259.0, 538.0), 115.0, 24.0, Color("#EA7829"), 351.2, [GapDefinitionScript.new(183.8, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(470.0, 758.0), 115.0, 24.0, Color("#62C73E"), 136.2, [])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(259.0, 538.0), 150.0, 24.0, Color("#32ADDA"), 204.9, [GapDefinitionScript.new(157.8, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(470.0, 758.0), 40.0, 24.0, Color("#7D2AD4"), 192.8, [])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(300.0, 780.0), 40.0, 24.0, Color("#4361CF"), 159.7, [GapDefinitionScript.new(315.5, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(504.0, 538.0), 76.0, 24.0, Color("#62C73E"), 160.1, [GapDefinitionScript.new(239.4, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(378.0, 355.0), 40.0, 24.0, Color("#62C73E"), 239.4, [GapDefinitionScript.new(177.5, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_1", &"ring_6", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_1", &"ring_1", &"ring_0", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_2", &"ring_3", &"ring_4", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_3", &"ring_4", &"ring_2", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_4", &"ring_0", &"ring_5", Color("#EA7829"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_5", 300.6, true),
				SolutionStepScript.new(&"ring_2", 282.5, true),
				SolutionStepScript.new(&"ring_4", 37.1, true),
				SolutionStepScript.new(&"ring_0", 222.4, true),
				SolutionStepScript.new(&"ring_6", 259.6, true)
			]

		20:
			def.title = "Level 20"
			def.instruction = "Clear the rings!"
			def.par_moves = 8
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(347.0, 751.0), 76.0, 24.0, Color("#CB2336"), 89.4, [GapDefinitionScript.new(143.0, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(391.0, 589.0), 40.0, 24.0, Color("#7D2AD4"), 279.5, [GapDefinitionScript.new(109.4, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(347.0, 751.0), 115.0, 24.0, Color("#C8202F"), 322.9, [GapDefinitionScript.new(297.5, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(439.0, 399.0), 76.0, 24.0, Color("#7D2AD4"), 206.9, [])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(439.0, 399.0), 115.0, 24.0, Color("#8228D9"), 298.8, [GapDefinitionScript.new(192.9, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(469.0, 872.0), 40.0, 24.0, Color("#32ADDA"), 163.5, [GapDefinitionScript.new(21.2, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(347.0, 751.0), 40.0, 24.0, Color("#7D2AD4"), 29.9, [GapDefinitionScript.new(241.2, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(439.0, 399.0), 40.0, 24.0, Color("#C8202F"), 311.9, [GapDefinitionScript.new(58.8, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_3", &"ring_6", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_1", &"ring_6", &"ring_1", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_2", &"ring_6", &"ring_7", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_3", &"ring_3", &"ring_5", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_4", &"ring_7", &"ring_2", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_5", &"ring_6", &"ring_4", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_6", &"ring_5", &"ring_0", Color("#32ADDA"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_0", 261.8, true),
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
			def.par_moves = 9
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(319.0, 352.0), 150.0, 24.0, Color("#8228D9"), 90.4, [])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(519.0, 614.0), 115.0, 24.0, Color("#8228D9"), 281.4, [GapDefinitionScript.new(194.5, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(224.0, 897.0), 40.0, 24.0, Color("#62C73E"), 37.1, [GapDefinitionScript.new(187.2, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(451.0, 883.0), 150.0, 24.0, Color("#8228D9"), 179.9, [GapDefinitionScript.new(118.1, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(268.0, 660.0), 40.0, 24.0, Color("#EA7829"), 183.6, [GapDefinitionScript.new(201.6, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(519.0, 614.0), 76.0, 24.0, Color("#32ADDA"), 302.2, [GapDefinitionScript.new(338.8, 56.0, 16.0), GapDefinitionScript.new(191.5, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(519.0, 614.0), 40.0, 24.0, Color("#F38224"), 32.3, [GapDefinitionScript.new(263.4, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(319.0, 352.0), 76.0, 24.0, Color("#CB2336"), 144.1, [GapDefinitionScript.new(20.6, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_1", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_1", &"ring_1", &"ring_2", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_2", &"ring_1", &"ring_3", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_3", &"ring_3", &"ring_7", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_4", &"ring_1", &"ring_4", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_5", &"ring_0", &"ring_6", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_6", &"ring_4", &"ring_5", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_7", &"ring_3", &"ring_5", Color("#8228D9"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_5", 272.7, true),
				SolutionStepScript.new(&"ring_5", 190.8, true),
				SolutionStepScript.new(&"ring_6", 329.3, true),
				SolutionStepScript.new(&"ring_4", 148.0, true),
				SolutionStepScript.new(&"ring_7", 55.5, true),
				SolutionStepScript.new(&"ring_3", 166.0, true),
				SolutionStepScript.new(&"ring_2", 129.0, true),
				SolutionStepScript.new(&"ring_1", 38.1, true)
			]

		22:
			def.title = "Level 22"
			def.instruction = "Clear the rings!"
			def.par_moves = 8
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(463.0, 367.0), 115.0, 24.0, Color("#32ADDA"), 141.3, [GapDefinitionScript.new(257.1, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(290.0, 760.0), 76.0, 24.0, Color("#8228D9"), 161.6, [GapDefinitionScript.new(323.2, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(290.0, 760.0), 150.0, 24.0, Color("#29B6F6"), 141.7, [GapDefinitionScript.new(204.9, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(290.0, 760.0), 40.0, 24.0, Color("#4361CF"), 125.0, [])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(520.0, 578.0), 76.0, 24.0, Color("#CB2336"), 317.6, [GapDefinitionScript.new(237.4, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(290.0, 760.0), 115.0, 24.0, Color("#29B6F6"), 110.7, [])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(297.0, 467.0), 40.0, 24.0, Color("#29B6F6"), 3.8, [GapDefinitionScript.new(196.1, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(472.0, 849.0), 40.0, 24.0, Color("#62C73E"), 168.1, [GapDefinitionScript.new(358.9, 56.0, 16.0), GapDefinitionScript.new(130.0, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_3", &"ring_0", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_1", &"ring_3", &"ring_6", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_2", &"ring_6", &"ring_4", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_3", &"ring_4", &"ring_7", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_4", &"ring_0", &"ring_7", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_5", &"ring_0", &"ring_1", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_6", &"ring_6", &"ring_2", Color("#29B6F6"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_2", 66.4, true),
				SolutionStepScript.new(&"ring_1", 330.5, true),
				SolutionStepScript.new(&"ring_7", 139.0, true),
				SolutionStepScript.new(&"ring_7", 281.1, true),
				SolutionStepScript.new(&"ring_4", 329.1, true),
				SolutionStepScript.new(&"ring_6", 255.3, true),
				SolutionStepScript.new(&"ring_0", 216.6, true)
			]

		23:
			def.title = "Level 23"
			def.instruction = "Clear the rings!"
			def.par_moves = 9
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(307.0, 385.0), 115.0, 24.0, Color("#7D2AD4"), 41.4, [GapDefinitionScript.new(311.8, 56.0, 16.0), GapDefinitionScript.new(175.3, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(478.0, 643.0), 76.0, 24.0, Color("#7D2AD4"), 277.4, [GapDefinitionScript.new(149.3, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(296.0, 845.0), 150.0, 24.0, Color("#62C73E"), 198.6, [GapDefinitionScript.new(165.7, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(307.0, 385.0), 76.0, 24.0, Color("#62C73E"), 101.1, [GapDefinitionScript.new(237.9, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(307.0, 385.0), 40.0, 24.0, Color("#32ADDA"), 47.8, [GapDefinitionScript.new(120.3, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(203.0, 575.0), 76.0, 24.0, Color("#C8202F"), 246.6, [GapDefinitionScript.new(64.7, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(348.0, 583.0), 40.0, 24.0, Color("#CB2336"), 235.0, [GapDefinitionScript.new(215.0, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(203.0, 575.0), 40.0, 24.0, Color("#EA7829"), 42.7, [])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_7", &"ring_3", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_1", &"ring_7", &"ring_2", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_2", &"ring_2", &"ring_5", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_3", &"ring_5", &"ring_4", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_4", &"ring_7", &"ring_0", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_5", &"ring_2", &"ring_0", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_6", &"ring_7", &"ring_6", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_7", &"ring_5", &"ring_1", Color("#C8202F"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_1", 44.6, true),
				SolutionStepScript.new(&"ring_6", 328.2, true),
				SolutionStepScript.new(&"ring_0", 276.1, true),
				SolutionStepScript.new(&"ring_0", 166.9, true),
				SolutionStepScript.new(&"ring_4", 358.4, true),
				SolutionStepScript.new(&"ring_5", 6.3, true),
				SolutionStepScript.new(&"ring_2", 85.3, true),
				SolutionStepScript.new(&"ring_3", 240.8, true)
			]

		24:
			def.title = "Level 24"
			def.instruction = "Clear the rings!"
			def.par_moves = 13
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(252.0, 358.0), 150.0, 24.0, Color("#F38224"), 163.1, [])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(252.0, 358.0), 115.0, 24.0, Color("#EA7829"), 60.9, [GapDefinitionScript.new(102.3, 56.0, 16.0), GapDefinitionScript.new(265.2, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(252.0, 358.0), 76.0, 24.0, Color("#8228D9"), 231.9, [GapDefinitionScript.new(330.3, 56.0, 16.0), GapDefinitionScript.new(316.1, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(345.0, 614.0), 76.0, 24.0, Color("#7D2AD4"), 57.2, [GapDefinitionScript.new(110.6, 56.0, 16.0), GapDefinitionScript.new(223.3, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(252.0, 358.0), 40.0, 24.0, Color("#4361CF"), 22.4, [GapDefinitionScript.new(325.3, 56.0, 16.0), GapDefinitionScript.new(355.0, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(345.0, 614.0), 40.0, 24.0, Color("#29B6F6"), 237.6, [GapDefinitionScript.new(4.0, 56.0, 16.0), GapDefinitionScript.new(146.8, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(344.0, 844.0), 40.0, 24.0, Color("#EA7829"), 55.6, [GapDefinitionScript.new(290.5, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(227.0, 763.0), 40.0, 24.0, Color("#C8202F"), 303.5, [GapDefinitionScript.new(219.8, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_7", Color("#F38224")),
				LinkDefinitionScript.new(&"link_1", &"ring_7", &"ring_3", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_2", &"ring_0", &"ring_3", Color("#F38224")),
				LinkDefinitionScript.new(&"link_3", &"ring_3", &"ring_1", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_4", &"ring_7", &"ring_1", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_5", &"ring_7", &"ring_5", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_6", &"ring_0", &"ring_5", Color("#F38224")),
				LinkDefinitionScript.new(&"link_7", &"ring_3", &"ring_4", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_8", &"ring_5", &"ring_4", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_9", &"ring_5", &"ring_2", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_10", &"ring_7", &"ring_2", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_11", &"ring_5", &"ring_6", Color("#29B6F6"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_6", 339.8, true),
				SolutionStepScript.new(&"ring_2", 137.4, true),
				SolutionStepScript.new(&"ring_2", 99.7, true),
				SolutionStepScript.new(&"ring_4", 75.0, true),
				SolutionStepScript.new(&"ring_4", 104.7, true),
				SolutionStepScript.new(&"ring_5", 103.2, true),
				SolutionStepScript.new(&"ring_5", 124.4, true),
				SolutionStepScript.new(&"ring_1", 188.3, true),
				SolutionStepScript.new(&"ring_1", 327.8, true),
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
			def.par_moves = 11
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(226.0, 770.0), 150.0, 24.0, Color("#8228D9"), 196.5, [GapDefinitionScript.new(56.7, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(226.0, 770.0), 115.0, 24.0, Color("#4361CF"), 271.1, [GapDefinitionScript.new(83.3, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(485.0, 640.0), 115.0, 24.0, Color("#32ADDA"), 229.3, [GapDefinitionScript.new(158.7, 56.0, 16.0), GapDefinitionScript.new(337.0, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(485.0, 640.0), 76.0, 24.0, Color("#62C73E"), 170.8, [GapDefinitionScript.new(243.6, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(338.0, 460.0), 40.0, 24.0, Color("#7D2AD4"), 320.4, [GapDefinitionScript.new(203.3, 56.0, 16.0), GapDefinitionScript.new(20.4, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(226.0, 770.0), 76.0, 24.0, Color("#CB2336"), 230.3, [GapDefinitionScript.new(30.5, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(248.0, 503.0), 40.0, 24.0, Color("#F38224"), 103.4, [GapDefinitionScript.new(74.7, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(226.0, 770.0), 40.0, 24.0, Color("#8228D9"), 194.5, [GapDefinitionScript.new(116.4, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(440.0, 879.0), 40.0, 24.0, Color("#CB2336"), 315.0, [])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_8", &"ring_1", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_1", &"ring_8", &"ring_4", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_2", &"ring_1", &"ring_4", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_3", &"ring_1", &"ring_3", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_4", &"ring_8", &"ring_6", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_5", &"ring_6", &"ring_0", Color("#F38224")),
				LinkDefinitionScript.new(&"link_6", &"ring_8", &"ring_7", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_7", &"ring_1", &"ring_2", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_8", &"ring_4", &"ring_2", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_9", &"ring_8", &"ring_5", Color("#CB2336"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_5", 356.4, true),
				SolutionStepScript.new(&"ring_2", 253.8, true),
				SolutionStepScript.new(&"ring_2", 354.7, true),
				SolutionStepScript.new(&"ring_7", 270.6, true),
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
			def.par_moves = 8
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(471.0, 640.0), 115.0, 24.0, Color("#29B6F6"), 78.1, [GapDefinitionScript.new(82.2, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(246.0, 625.0), 40.0, 24.0, Color("#C8202F"), 230.1, [GapDefinitionScript.new(324.0, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(277.0, 363.0), 115.0, 24.0, Color("#62C73E"), 234.9, [])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(285.0, 885.0), 76.0, 24.0, Color("#7D2AD4"), 73.6, [GapDefinitionScript.new(148.1, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(491.0, 392.0), 76.0, 24.0, Color("#EA7829"), 296.9, [GapDefinitionScript.new(21.1, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(246.0, 625.0), 76.0, 24.0, Color("#29B6F6"), 348.3, [GapDefinitionScript.new(261.2, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(277.0, 363.0), 76.0, 24.0, Color("#EA7829"), 15.7, [GapDefinitionScript.new(175.2, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(277.0, 363.0), 40.0, 24.0, Color("#32ADDA"), 182.8, [])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(471.0, 640.0), 76.0, 24.0, Color("#EA7829"), 245.2, [GapDefinitionScript.new(14.9, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_2", &"ring_5", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_1", &"ring_5", &"ring_8", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_2", &"ring_7", &"ring_0", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_3", &"ring_0", &"ring_6", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_4", &"ring_7", &"ring_1", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_5", &"ring_1", &"ring_3", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_6", &"ring_6", &"ring_4", Color("#EA7829"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_4", 166.6, true),
				SolutionStepScript.new(&"ring_3", 113.4, true),
				SolutionStepScript.new(&"ring_1", 312.8, true),
				SolutionStepScript.new(&"ring_6", 239.8, true),
				SolutionStepScript.new(&"ring_0", 152.8, true),
				SolutionStepScript.new(&"ring_8", 168.9, true),
				SolutionStepScript.new(&"ring_5", 15.5, true)
			]

		28:
			def.title = "Level 28"
			def.instruction = "Clear the rings!"
			def.par_moves = 7
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(413.0, 686.0), 150.0, 24.0, Color("#62C73E"), 258.8, [])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(219.0, 764.0), 40.0, 24.0, Color("#62C73E"), 263.7, [GapDefinitionScript.new(40.5, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(272.0, 882.0), 40.0, 24.0, Color("#C8202F"), 118.8, [GapDefinitionScript.new(298.1, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(272.0, 882.0), 76.0, 24.0, Color("#62C73E"), 69.4, [GapDefinitionScript.new(204.5, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(337.0, 462.0), 40.0, 24.0, Color("#8228D9"), 99.9, [GapDefinitionScript.new(281.6, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(241.0, 475.0), 40.0, 24.0, Color("#62C73E"), 50.2, [GapDefinitionScript.new(299.6, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(417.0, 413.0), 40.0, 24.0, Color("#CB2336"), 213.9, [GapDefinitionScript.new(226.0, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(413.0, 686.0), 76.0, 24.0, Color("#CB2336"), 237.3, [])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(413.0, 686.0), 40.0, 24.0, Color("#CB2336"), 67.4, [])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_8", &"ring_2", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_1", &"ring_0", &"ring_1", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_2", &"ring_1", &"ring_5", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_3", &"ring_8", &"ring_4", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_4", &"ring_5", &"ring_3", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_5", &"ring_1", &"ring_6", Color("#62C73E"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_6", 253.5, true),
				SolutionStepScript.new(&"ring_3", 61.2, true),
				SolutionStepScript.new(&"ring_4", 149.6, true),
				SolutionStepScript.new(&"ring_5", 154.7, true),
				SolutionStepScript.new(&"ring_1", 297.5, true),
				SolutionStepScript.new(&"ring_2", 7.6, true)
			]

		29:
			def.title = "Level 29"
			def.instruction = "Clear the rings!"
			def.par_moves = 10
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(490.0, 788.0), 40.0, 24.0, Color("#CB2336"), 234.2, [GapDefinitionScript.new(163.4, 56.0, 16.0), GapDefinitionScript.new(118.7, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(284.0, 763.0), 40.0, 24.0, Color("#F38224"), 182.5, [GapDefinitionScript.new(330.5, 56.0, 16.0)])
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
				LinkDefinitionScript.new(&"link_6", &"ring_7", &"ring_1", Color("#F38224")),
				LinkDefinitionScript.new(&"link_7", &"ring_1", &"ring_0", Color("#F38224")),
				LinkDefinitionScript.new(&"link_8", &"ring_7", &"ring_0", Color("#F38224"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_0", 33.9, true),
				SolutionStepScript.new(&"ring_0", 23.5, true),
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
			def.par_moves = 11
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(447.0, 452.0), 76.0, 24.0, Color("#32ADDA"), 293.9, [GapDefinitionScript.new(197.6, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(447.0, 452.0), 150.0, 24.0, Color("#62C73E"), 25.9, [])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(229.0, 730.0), 115.0, 24.0, Color("#F38224"), 130.6, [GapDefinitionScript.new(271.4, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(201.0, 461.0), 76.0, 24.0, Color("#F38224"), 210.9, [GapDefinitionScript.new(281.4, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(503.0, 769.0), 76.0, 24.0, Color("#29B6F6"), 242.2, [GapDefinitionScript.new(235.8, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(367.0, 882.0), 40.0, 24.0, Color("#7D2AD4"), 210.1, [GapDefinitionScript.new(307.8, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(447.0, 452.0), 115.0, 24.0, Color("#32ADDA"), 297.2, [GapDefinitionScript.new(195.4, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(229.0, 730.0), 40.0, 24.0, Color("#F38224"), 138.9, [GapDefinitionScript.new(178.9, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(503.0, 769.0), 40.0, 24.0, Color("#4361CF"), 26.0, [GapDefinitionScript.new(91.5, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(503.0, 769.0), 115.0, 24.0, Color("#29B6F6"), 342.2, [GapDefinitionScript.new(196.7, 56.0, 16.0), GapDefinitionScript.new(338.9, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_1", &"ring_7", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_1", &"ring_1", &"ring_2", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_2", &"ring_7", &"ring_0", Color("#F38224")),
				LinkDefinitionScript.new(&"link_3", &"ring_1", &"ring_3", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_4", &"ring_3", &"ring_6", Color("#F38224")),
				LinkDefinitionScript.new(&"link_5", &"ring_3", &"ring_8", Color("#F38224")),
				LinkDefinitionScript.new(&"link_6", &"ring_0", &"ring_5", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_7", &"ring_2", &"ring_9", Color("#F38224")),
				LinkDefinitionScript.new(&"link_8", &"ring_7", &"ring_9", Color("#F38224")),
				LinkDefinitionScript.new(&"link_9", &"ring_3", &"ring_4", Color("#F38224"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_4", 349.7, true),
				SolutionStepScript.new(&"ring_9", 209.2, true),
				SolutionStepScript.new(&"ring_9", 351.4, true),
				SolutionStepScript.new(&"ring_5", 332.7, true),
				SolutionStepScript.new(&"ring_8", 134.1, true),
				SolutionStepScript.new(&"ring_6", 342.5, true),
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
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(407.0, 376.0), 150.0, 24.0, Color("#C8202F"), 230.6, [GapDefinitionScript.new(39.1, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(498.0, 656.0), 40.0, 24.0, Color("#62C73E"), 119.5, [GapDefinitionScript.new(74.2, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(201.0, 749.0), 40.0, 24.0, Color("#62C73E"), 85.8, [GapDefinitionScript.new(258.5, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(373.0, 846.0), 40.0, 24.0, Color("#EA7829"), 306.6, [GapDefinitionScript.new(207.5, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(407.0, 376.0), 115.0, 24.0, Color("#32ADDA"), 322.5, [])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(373.0, 846.0), 76.0, 24.0, Color("#7D2AD4"), 174.1, [GapDefinitionScript.new(0.6, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(407.0, 376.0), 40.0, 24.0, Color("#8228D9"), 354.1, [GapDefinitionScript.new(49.6, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(407.0, 376.0), 76.0, 24.0, Color("#62C73E"), 29.1, [GapDefinitionScript.new(126.1, 56.0, 16.0), GapDefinitionScript.new(321.6, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_6", &"ring_0", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_1", &"ring_6", &"ring_1", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_2", &"ring_0", &"ring_1", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_3", &"ring_0", &"ring_8", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_4", &"ring_8", &"ring_3", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_5", &"ring_3", &"ring_2", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_6", &"ring_1", &"ring_5", Color("#F38224")),
				LinkDefinitionScript.new(&"link_7", &"ring_5", &"ring_4", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_8", &"ring_4", &"ring_7", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_9", &"ring_0", &"ring_9", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_10", &"ring_3", &"ring_9", Color("#62C73E"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_9", 110.4, true),
				SolutionStepScript.new(&"ring_9", 305.8, true),
				SolutionStepScript.new(&"ring_7", 208.8, true),
				SolutionStepScript.new(&"ring_4", 130.9, true),
				SolutionStepScript.new(&"ring_5", 37.1, true),
				SolutionStepScript.new(&"ring_2", 32.9, true),
				SolutionStepScript.new(&"ring_3", 177.8, true),
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
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(503.0, 576.0), 76.0, 24.0, Color("#C8202F"), 343.8, [GapDefinitionScript.new(16.1, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(503.0, 576.0), 40.0, 24.0, Color("#32ADDA"), 218.1, [GapDefinitionScript.new(160.8, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_9", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_1", &"ring_0", &"ring_5", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_2", &"ring_9", &"ring_1", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_3", &"ring_0", &"ring_6", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_4", &"ring_9", &"ring_6", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_5", &"ring_5", &"ring_4", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_6", &"ring_6", &"ring_8", Color("#CB2336")),
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
			def.par_moves = 14
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(441.0, 444.0), 40.0, 24.0, Color("#29B6F6"), 51.4, [GapDefinitionScript.new(256.3, 56.0, 16.0), GapDefinitionScript.new(258.9, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(493.0, 804.0), 76.0, 24.0, Color("#32ADDA"), 59.9, [GapDefinitionScript.new(154.9, 56.0, 16.0), GapDefinitionScript.new(109.0, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(493.0, 804.0), 40.0, 24.0, Color("#C8202F"), 220.2, [GapDefinitionScript.new(127.1, 56.0, 16.0), GapDefinitionScript.new(96.2, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(298.0, 833.0), 76.0, 24.0, Color("#F38224"), 4.9, [])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(441.0, 444.0), 76.0, 24.0, Color("#7D2AD4"), 245.8, [GapDefinitionScript.new(239.3, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(295.0, 595.0), 76.0, 24.0, Color("#62C73E"), 217.3, [GapDefinitionScript.new(232.1, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(470.0, 636.0), 40.0, 24.0, Color("#62C73E"), 226.1, [GapDefinitionScript.new(310.3, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(224.0, 391.0), 76.0, 24.0, Color("#C8202F"), 301.0, [GapDefinitionScript.new(154.8, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(298.0, 833.0), 40.0, 24.0, Color("#29B6F6"), 338.6, [GapDefinitionScript.new(210.8, 56.0, 16.0), GapDefinitionScript.new(46.6, 56.0, 16.0)])
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
				LinkDefinitionScript.new(&"link_9", &"ring_1", &"ring_8", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_10", &"ring_5", &"ring_8", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_11", &"ring_6", &"ring_2", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_12", &"ring_0", &"ring_2", Color("#29B6F6"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_2", 165.5, true),
				SolutionStepScript.new(&"ring_2", 135.1, true),
				SolutionStepScript.new(&"ring_8", 222.7, true),
				SolutionStepScript.new(&"ring_8", 140.7, true),
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
			def.par_moves = 10
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(508.0, 517.0), 76.0, 24.0, Color("#62C73E"), 161.8, [GapDefinitionScript.new(333.7, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(508.0, 517.0), 150.0, 24.0, Color("#62C73E"), 240.7, [GapDefinitionScript.new(42.0, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(508.0, 517.0), 115.0, 24.0, Color("#4361CF"), 214.1, [GapDefinitionScript.new(41.6, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(333.0, 839.0), 150.0, 24.0, Color("#32ADDA"), 219.7, [GapDefinitionScript.new(19.4, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(333.0, 839.0), 76.0, 24.0, Color("#C8202F"), 287.9, [GapDefinitionScript.new(349.2, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(508.0, 517.0), 40.0, 24.0, Color("#C8202F"), 189.6, [GapDefinitionScript.new(178.8, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(333.0, 839.0), 115.0, 24.0, Color("#CB2336"), 345.3, [GapDefinitionScript.new(314.3, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(333.0, 839.0), 40.0, 24.0, Color("#29B6F6"), 10.1, [GapDefinitionScript.new(137.6, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(277.0, 420.0), 76.0, 24.0, Color("#62C73E"), 125.6, [GapDefinitionScript.new(194.5, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(204.0, 590.0), 40.0, 24.0, Color("#32ADDA"), 58.2, [])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_9", &"ring_0", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_1", &"ring_9", &"ring_2", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_2", &"ring_9", &"ring_1", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_3", &"ring_2", &"ring_6", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_4", &"ring_2", &"ring_7", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_5", &"ring_1", &"ring_4", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_6", &"ring_2", &"ring_3", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_7", &"ring_6", &"ring_8", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_8", &"ring_9", &"ring_5", Color("#32ADDA"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_5", 347.7, true),
				SolutionStepScript.new(&"ring_8", 247.9, true),
				SolutionStepScript.new(&"ring_3", 279.1, true),
				SolutionStepScript.new(&"ring_4", 309.4, true),
				SolutionStepScript.new(&"ring_7", 161.0, true),
				SolutionStepScript.new(&"ring_6", 344.2, true),
				SolutionStepScript.new(&"ring_1", 124.5, true),
				SolutionStepScript.new(&"ring_2", 124.9, true),
				SolutionStepScript.new(&"ring_0", 192.8, true)
			]

		35:
			def.title = "Level 35"
			def.instruction = "Clear the rings!"
			def.par_moves = 12
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(341.0, 358.0), 40.0, 24.0, Color("#8228D9"), 208.7, [GapDefinitionScript.new(273.6, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(493.0, 595.0), 115.0, 24.0, Color("#4361CF"), 137.9, [GapDefinitionScript.new(289.4, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(341.0, 358.0), 76.0, 24.0, Color("#CB2336"), 97.7, [GapDefinitionScript.new(92.8, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(350.0, 356.0), 150.0, 24.0, Color("#29B6F6"), 93.3, [GapDefinitionScript.new(329.3, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(341.0, 358.0), 115.0, 24.0, Color("#C8202F"), 89.8, [GapDefinitionScript.new(157.1, 56.0, 16.0)])
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
				LinkDefinitionScript.new(&"link_2", &"ring_7", &"ring_0", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_3", &"ring_2", &"ring_10", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_4", &"ring_7", &"ring_5", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_5", &"ring_8", &"ring_5", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_6", &"ring_2", &"ring_6", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_7", &"ring_10", &"ring_3", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_8", &"ring_7", &"ring_9", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_9", &"ring_9", &"ring_4", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_10", &"ring_10", &"ring_1", Color("#C8202F"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_1", 201.0, true),
				SolutionStepScript.new(&"ring_4", 324.1, true),
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
			def.par_moves = 10
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(373.0, 482.0), 76.0, 24.0, Color("#29B6F6"), 48.5, [GapDefinitionScript.new(27.7, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(423.0, 841.0), 115.0, 24.0, Color("#62C73E"), 53.7, [GapDefinitionScript.new(107.0, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(373.0, 482.0), 150.0, 24.0, Color("#EA7829"), 359.9, [])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(373.0, 482.0), 115.0, 24.0, Color("#32ADDA"), 39.0, [GapDefinitionScript.new(141.0, 56.0, 16.0), GapDefinitionScript.new(55.5, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(423.0, 841.0), 150.0, 24.0, Color("#C8202F"), 224.5, [GapDefinitionScript.new(273.7, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(373.0, 482.0), 40.0, 24.0, Color("#F38224"), 21.6, [GapDefinitionScript.new(309.5, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(423.0, 841.0), 76.0, 24.0, Color("#C8202F"), 199.1, [GapDefinitionScript.new(199.6, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(212.0, 675.0), 40.0, 24.0, Color("#29B6F6"), 63.4, [GapDefinitionScript.new(174.3, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(423.0, 841.0), 40.0, 24.0, Color("#CB2336"), 163.0, [GapDefinitionScript.new(44.0, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_2", &"ring_1", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_1", &"ring_1", &"ring_0", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_2", &"ring_0", &"ring_4", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_3", &"ring_1", &"ring_7", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_4", &"ring_0", &"ring_8", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_5", &"ring_8", &"ring_5", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_6", &"ring_0", &"ring_6", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_7", &"ring_6", &"ring_3", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_8", &"ring_7", &"ring_3", Color("#29B6F6"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_3", 74.3, true),
				SolutionStepScript.new(&"ring_3", 301.0, true),
				SolutionStepScript.new(&"ring_6", 62.5, true),
				SolutionStepScript.new(&"ring_5", 132.6, true),
				SolutionStepScript.new(&"ring_8", 218.1, true),
				SolutionStepScript.new(&"ring_7", 223.9, true),
				SolutionStepScript.new(&"ring_4", 348.3, true),
				SolutionStepScript.new(&"ring_0", 54.3, true),
				SolutionStepScript.new(&"ring_1", 155.1, true)
			]

		37:
			def.title = "Level 37"
			def.instruction = "Clear the rings!"
			def.par_moves = 12
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(480.0, 612.0), 76.0, 24.0, Color("#32ADDA"), 94.0, [])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(366.0, 387.0), 40.0, 24.0, Color("#32ADDA"), 136.3, [GapDefinitionScript.new(30.8, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(366.0, 387.0), 115.0, 24.0, Color("#32ADDA"), 328.3, [GapDefinitionScript.new(166.3, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(281.0, 550.0), 40.0, 24.0, Color("#7D2AD4"), 253.4, [GapDefinitionScript.new(160.0, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(267.0, 804.0), 40.0, 24.0, Color("#29B6F6"), 100.7, [GapDefinitionScript.new(345.7, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(480.0, 612.0), 115.0, 24.0, Color("#32ADDA"), 225.0, [GapDefinitionScript.new(67.2, 56.0, 16.0)])
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
				LinkDefinitionScript.new(&"link_5", &"ring_4", &"ring_5", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_6", &"ring_10", &"ring_7", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_7", &"ring_6", &"ring_9", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_8", &"ring_3", &"ring_1", Color("#7D2AD4")),
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
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(431.0, 612.0), 115.0, 24.0, Color("#29B6F6"), 230.9, [GapDefinitionScript.new(180.6, 56.0, 16.0), GapDefinitionScript.new(345.3, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(238.0, 354.0), 76.0, 24.0, Color("#4361CF"), 143.4, [GapDefinitionScript.new(188.4, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(211.0, 859.0), 150.0, 24.0, Color("#7D2AD4"), 328.4, [GapDefinitionScript.new(148.0, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(211.0, 859.0), 115.0, 24.0, Color("#4361CF"), 67.2, [GapDefinitionScript.new(241.1, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(238.0, 354.0), 40.0, 24.0, Color("#EA7829"), 96.1, [GapDefinitionScript.new(78.5, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(476.0, 841.0), 76.0, 24.0, Color("#7D2AD4"), 294.2, [GapDefinitionScript.new(66.8, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(504.0, 358.0), 76.0, 24.0, Color("#32ADDA"), 234.9, [])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(238.0, 354.0), 150.0, 24.0, Color("#62C73E"), 64.0, [GapDefinitionScript.new(17.2, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(238.0, 354.0), 115.0, 24.0, Color("#C8202F"), 1.9, [GapDefinitionScript.new(128.3, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(211.0, 859.0), 76.0, 24.0, Color("#4361CF"), 96.6, [GapDefinitionScript.new(306.5, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(476.0, 841.0), 40.0, 24.0, Color("#8228D9"), 53.8, [GapDefinitionScript.new(135.2, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_6", &"ring_10", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_1", &"ring_10", &"ring_7", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_2", &"ring_7", &"ring_5", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_3", &"ring_10", &"ring_2", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_4", &"ring_6", &"ring_8", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_5", &"ring_6", &"ring_3", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_6", &"ring_6", &"ring_4", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_7", &"ring_3", &"ring_0", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_8", &"ring_4", &"ring_0", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_9", &"ring_5", &"ring_9", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_10", &"ring_10", &"ring_1", Color("#8228D9"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_1", 235.6, true),
				SolutionStepScript.new(&"ring_9", 49.7, true),
				SolutionStepScript.new(&"ring_0", 247.9, true),
				SolutionStepScript.new(&"ring_0", 311.1, true),
				SolutionStepScript.new(&"ring_4", 282.3, true),
				SolutionStepScript.new(&"ring_3", 59.2, true),
				SolutionStepScript.new(&"ring_8", 232.6, true),
				SolutionStepScript.new(&"ring_2", 208.1, true),
				SolutionStepScript.new(&"ring_5", 177.2, true),
				SolutionStepScript.new(&"ring_7", 46.7, true),
				SolutionStepScript.new(&"ring_10", 138.1, true)
			]

		39:
			def.title = "Level 39"
			def.instruction = "Clear the rings!"
			def.par_moves = 12
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(203.0, 706.0), 115.0, 24.0, Color("#4361CF"), 211.5, [GapDefinitionScript.new(202.5, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(278.0, 505.0), 40.0, 24.0, Color("#29B6F6"), 222.6, [GapDefinitionScript.new(0.6, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(407.0, 661.0), 76.0, 24.0, Color("#EA7829"), 5.3, [GapDefinitionScript.new(29.1, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(503.0, 428.0), 115.0, 24.0, Color("#F38224"), 201.5, [GapDefinitionScript.new(308.1, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(203.0, 706.0), 40.0, 24.0, Color("#F38224"), 356.2, [GapDefinitionScript.new(274.8, 56.0, 16.0), GapDefinitionScript.new(216.7, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(203.0, 706.0), 76.0, 24.0, Color("#62C73E"), 106.2, [GapDefinitionScript.new(131.0, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(503.0, 428.0), 40.0, 24.0, Color("#EA7829"), 312.8, [])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(503.0, 428.0), 76.0, 24.0, Color("#32ADDA"), 138.8, [GapDefinitionScript.new(95.6, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(515.0, 747.0), 40.0, 24.0, Color("#62C73E"), 46.2, [GapDefinitionScript.new(98.1, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(411.0, 876.0), 115.0, 24.0, Color("#EA7829"), 314.7, [GapDefinitionScript.new(254.3, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(278.0, 505.0), 76.0, 24.0, Color("#EA7829"), 282.2, [GapDefinitionScript.new(50.8, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_6", &"ring_2", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_1", &"ring_2", &"ring_1", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_2", &"ring_2", &"ring_3", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_3", &"ring_6", &"ring_8", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_4", &"ring_1", &"ring_5", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_5", &"ring_1", &"ring_7", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_6", &"ring_6", &"ring_10", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_7", &"ring_3", &"ring_0", Color("#F38224")),
				LinkDefinitionScript.new(&"link_8", &"ring_2", &"ring_9", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_9", &"ring_1", &"ring_4", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_10", &"ring_3", &"ring_4", Color("#F38224"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_4", 100.5, true),
				SolutionStepScript.new(&"ring_4", 15.7, true),
				SolutionStepScript.new(&"ring_9", 14.6, true),
				SolutionStepScript.new(&"ring_0", 114.7, true),
				SolutionStepScript.new(&"ring_10", 290.3, true),
				SolutionStepScript.new(&"ring_7", 65.5, true),
				SolutionStepScript.new(&"ring_5", 159.5, true),
				SolutionStepScript.new(&"ring_8", 169.8, true),
				SolutionStepScript.new(&"ring_3", 164.3, true),
				SolutionStepScript.new(&"ring_1", 49.8, true),
				SolutionStepScript.new(&"ring_2", 263.3, true)
			]

		40:
			def.title = "Level 40"
			def.instruction = "Clear the rings!"
			def.par_moves = 16
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(292.0, 636.0), 40.0, 24.0, Color("#29B6F6"), 165.0, [GapDefinitionScript.new(169.8, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(292.0, 636.0), 150.0, 24.0, Color("#EA7829"), 302.6, [])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(460.0, 432.0), 40.0, 24.0, Color("#F38224"), 218.0, [GapDefinitionScript.new(291.4, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(292.0, 636.0), 76.0, 24.0, Color("#CB2336"), 343.9, [GapDefinitionScript.new(141.7, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(292.0, 636.0), 115.0, 24.0, Color("#4361CF"), 319.4, [GapDefinitionScript.new(124.1, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(514.0, 528.0), 40.0, 24.0, Color("#CB2336"), 117.9, [GapDefinitionScript.new(5.8, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(487.0, 705.0), 40.0, 24.0, Color("#32ADDA"), 32.3, [GapDefinitionScript.new(38.4, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(330.0, 872.0), 40.0, 24.0, Color("#8228D9"), 66.5, [GapDefinitionScript.new(68.9, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(290.0, 433.0), 40.0, 24.0, Color("#62C73E"), 261.5, [GapDefinitionScript.new(100.6, 56.0, 16.0), GapDefinitionScript.new(203.6, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(480.0, 896.0), 76.0, 24.0, Color("#32ADDA"), 89.8, [GapDefinitionScript.new(85.0, 56.0, 16.0), GapDefinitionScript.new(153.2, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(232.0, 829.0), 40.0, 24.0, Color("#EA7829"), 305.4, [GapDefinitionScript.new(173.7, 56.0, 16.0), GapDefinitionScript.new(181.3, 56.0, 16.0)])
			var r11 = PieceDefinitionScript.new(&"ring_11", Vector2(480.0, 896.0), 40.0, 24.0, Color("#CB2336"), 272.2, [GapDefinitionScript.new(349.5, 56.0, 16.0), GapDefinitionScript.new(283.7, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_1", &"ring_2", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_1", &"ring_1", &"ring_6", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_2", &"ring_6", &"ring_3", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_3", &"ring_2", &"ring_0", Color("#F38224")),
				LinkDefinitionScript.new(&"link_4", &"ring_0", &"ring_5", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_5", &"ring_2", &"ring_11", Color("#F38224")),
				LinkDefinitionScript.new(&"link_6", &"ring_0", &"ring_11", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_7", &"ring_6", &"ring_7", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_8", &"ring_7", &"ring_10", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_9", &"ring_2", &"ring_10", Color("#F38224")),
				LinkDefinitionScript.new(&"link_10", &"ring_11", &"ring_4", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_11", &"ring_4", &"ring_9", Color("#4361CF")),
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
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(339.0, 620.0), 150.0, 24.0, Color("#F38224"), 242.1, [GapDefinitionScript.new(124.5, 56.0, 16.0), GapDefinitionScript.new(47.4, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(339.0, 620.0), 40.0, 24.0, Color("#62C73E"), 251.0, [GapDefinitionScript.new(268.2, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(220.0, 354.0), 40.0, 24.0, Color("#8228D9"), 160.2, [GapDefinitionScript.new(244.2, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(339.0, 620.0), 115.0, 24.0, Color("#32ADDA"), 265.3, [GapDefinitionScript.new(199.9, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(491.0, 813.0), 40.0, 24.0, Color("#F38224"), 190.9, [])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(491.0, 813.0), 76.0, 24.0, Color("#EA7829"), 308.7, [GapDefinitionScript.new(180.9, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(316.0, 384.0), 40.0, 24.0, Color("#7D2AD4"), 229.5, [GapDefinitionScript.new(300.3, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(335.0, 843.0), 40.0, 24.0, Color("#CB2336"), 214.5, [GapDefinitionScript.new(68.4, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(339.0, 620.0), 76.0, 24.0, Color("#7D2AD4"), 87.2, [GapDefinitionScript.new(173.1, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(495.0, 351.0), 76.0, 24.0, Color("#62C73E"), 140.7, [GapDefinitionScript.new(224.0, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(248.0, 803.0), 40.0, 24.0, Color("#4361CF"), 205.3, [GapDefinitionScript.new(86.6, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_4", &"ring_7", Color("#F38224")),
				LinkDefinitionScript.new(&"link_1", &"ring_7", &"ring_5", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_2", &"ring_7", &"ring_1", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_3", &"ring_4", &"ring_3", Color("#F38224")),
				LinkDefinitionScript.new(&"link_4", &"ring_3", &"ring_2", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_5", &"ring_7", &"ring_8", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_6", &"ring_8", &"ring_9", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_7", &"ring_2", &"ring_0", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_8", &"ring_4", &"ring_0", Color("#F38224")),
				LinkDefinitionScript.new(&"link_9", &"ring_4", &"ring_6", Color("#F38224")),
				LinkDefinitionScript.new(&"link_10", &"ring_6", &"ring_10", Color("#7D2AD4"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_10", 192.7, true),
				SolutionStepScript.new(&"ring_6", 127.5, true),
				SolutionStepScript.new(&"ring_0", 4.4, true),
				SolutionStepScript.new(&"ring_0", 121.4, true),
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
			def.par_moves = 13
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(484.0, 820.0), 150.0, 24.0, Color("#C8202F"), 274.0, [GapDefinitionScript.new(307.1, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(216.0, 439.0), 150.0, 24.0, Color("#CB2336"), 142.3, [GapDefinitionScript.new(6.4, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(484.0, 820.0), 115.0, 24.0, Color("#C8202F"), 224.0, [GapDefinitionScript.new(347.9, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(439.0, 572.0), 40.0, 24.0, Color("#EA7829"), 161.5, [])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(216.0, 439.0), 115.0, 24.0, Color("#8228D9"), 121.1, [GapDefinitionScript.new(93.9, 56.0, 16.0), GapDefinitionScript.new(156.7, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(211.0, 681.0), 76.0, 24.0, Color("#62C73E"), 326.2, [GapDefinitionScript.new(81.0, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(216.0, 439.0), 76.0, 24.0, Color("#32ADDA"), 99.7, [GapDefinitionScript.new(355.3, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(216.0, 439.0), 40.0, 24.0, Color("#F38224"), 125.5, [GapDefinitionScript.new(104.6, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(484.0, 820.0), 40.0, 24.0, Color("#7D2AD4"), 52.0, [GapDefinitionScript.new(331.7, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(274.0, 811.0), 40.0, 24.0, Color("#EA7829"), 142.7, [GapDefinitionScript.new(150.9, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(484.0, 820.0), 76.0, 24.0, Color("#F38224"), 31.9, [GapDefinitionScript.new(163.1, 56.0, 16.0)])
			var r11 = PieceDefinitionScript.new(&"ring_11", Vector2(500.0, 405.0), 76.0, 24.0, Color("#29B6F6"), 7.2, [GapDefinitionScript.new(24.3, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_3", &"ring_6", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_1", &"ring_6", &"ring_9", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_2", &"ring_3", &"ring_4", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_3", &"ring_9", &"ring_4", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_4", &"ring_3", &"ring_0", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_5", &"ring_3", &"ring_7", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_6", &"ring_6", &"ring_5", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_7", &"ring_6", &"ring_11", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_8", &"ring_5", &"ring_1", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_9", &"ring_5", &"ring_2", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_10", &"ring_11", &"ring_8", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_11", &"ring_3", &"ring_10", Color("#EA7829"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_10", 96.6, true),
				SolutionStepScript.new(&"ring_8", 300.6, true),
				SolutionStepScript.new(&"ring_2", 219.1, true),
				SolutionStepScript.new(&"ring_1", 84.8, true),
				SolutionStepScript.new(&"ring_11", 148.9, true),
				SolutionStepScript.new(&"ring_5", 190.1, true),
				SolutionStepScript.new(&"ring_7", 286.2, true),
				SolutionStepScript.new(&"ring_0", 312.6, true),
				SolutionStepScript.new(&"ring_4", 284.4, true),
				SolutionStepScript.new(&"ring_4", 297.0, true),
				SolutionStepScript.new(&"ring_9", 110.2, true),
				SolutionStepScript.new(&"ring_6", 35.6, true)
			]

		43:
			def.title = "Level 43"
			def.instruction = "Clear the rings!"
			def.par_moves = 12
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(306.0, 459.0), 115.0, 24.0, Color("#29B6F6"), 192.3, [GapDefinitionScript.new(54.4, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(368.0, 790.0), 150.0, 24.0, Color("#62C73E"), 346.8, [GapDefinitionScript.new(177.5, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(368.0, 790.0), 115.0, 24.0, Color("#4361CF"), 112.6, [])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(306.0, 459.0), 150.0, 24.0, Color("#8228D9"), 17.0, [GapDefinitionScript.new(106.4, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(368.0, 790.0), 76.0, 24.0, Color("#32ADDA"), 145.2, [GapDefinitionScript.new(209.3, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(306.0, 459.0), 76.0, 24.0, Color("#4361CF"), 109.6, [GapDefinitionScript.new(282.6, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(306.0, 459.0), 40.0, 24.0, Color("#32ADDA"), 287.2, [GapDefinitionScript.new(345.3, 56.0, 16.0), GapDefinitionScript.new(251.8, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(504.0, 618.0), 40.0, 24.0, Color("#C8202F"), 312.5, [GapDefinitionScript.new(68.5, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(490.0, 373.0), 40.0, 24.0, Color("#62C73E"), 274.7, [GapDefinitionScript.new(289.3, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(368.0, 790.0), 40.0, 24.0, Color("#62C73E"), 14.7, [GapDefinitionScript.new(85.6, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(509.0, 480.0), 40.0, 24.0, Color("#CB2336"), 26.9, [GapDefinitionScript.new(253.5, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_2", &"ring_8", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_1", &"ring_2", &"ring_7", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_2", &"ring_8", &"ring_4", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_3", &"ring_2", &"ring_10", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_4", &"ring_10", &"ring_0", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_5", &"ring_0", &"ring_1", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_6", &"ring_0", &"ring_9", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_7", &"ring_9", &"ring_6", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_8", &"ring_8", &"ring_6", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_9", &"ring_9", &"ring_3", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_10", &"ring_9", &"ring_5", Color("#62C73E"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_5", 156.8, true),
				SolutionStepScript.new(&"ring_3", 333.0, true),
				SolutionStepScript.new(&"ring_6", 83.1, true),
				SolutionStepScript.new(&"ring_6", 94.1, true),
				SolutionStepScript.new(&"ring_9", 173.8, true),
				SolutionStepScript.new(&"ring_1", 81.9, true),
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
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(393.0, 367.0), 115.0, 24.0, Color("#8228D9"), 10.6, [GapDefinitionScript.new(233.3, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(283.0, 746.0), 40.0, 24.0, Color("#CB2336"), 304.4, [GapDefinitionScript.new(85.9, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(393.0, 367.0), 76.0, 24.0, Color("#29B6F6"), 321.5, [GapDefinitionScript.new(64.6, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(488.0, 514.0), 40.0, 24.0, Color("#F38224"), 61.3, [])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(335.0, 604.0), 40.0, 24.0, Color("#F38224"), 133.4, [GapDefinitionScript.new(46.2, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(209.0, 868.0), 40.0, 24.0, Color("#F38224"), 197.6, [GapDefinitionScript.new(298.8, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(204.0, 494.0), 76.0, 24.0, Color("#C8202F"), 344.3, [GapDefinitionScript.new(66.7, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(480.0, 874.0), 115.0, 24.0, Color("#29B6F6"), 69.1, [GapDefinitionScript.new(72.3, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(335.0, 604.0), 76.0, 24.0, Color("#C8202F"), 224.6, [GapDefinitionScript.new(338.4, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(480.0, 874.0), 76.0, 24.0, Color("#8228D9"), 254.1, [GapDefinitionScript.new(141.1, 56.0, 16.0)])
			var r11 = PieceDefinitionScript.new(&"ring_11", Vector2(501.0, 643.0), 76.0, 24.0, Color("#7D2AD4"), 149.0, [GapDefinitionScript.new(165.0, 56.0, 16.0), GapDefinitionScript.new(215.2, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_4", &"ring_5", Color("#F38224")),
				LinkDefinitionScript.new(&"link_1", &"ring_5", &"ring_6", Color("#F38224")),
				LinkDefinitionScript.new(&"link_2", &"ring_4", &"ring_0", Color("#F38224")),
				LinkDefinitionScript.new(&"link_3", &"ring_0", &"ring_2", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_4", &"ring_2", &"ring_10", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_5", &"ring_6", &"ring_9", Color("#F38224")),
				LinkDefinitionScript.new(&"link_6", &"ring_10", &"ring_11", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_7", &"ring_9", &"ring_11", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_8", &"ring_10", &"ring_7", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_9", &"ring_10", &"ring_3", Color("#8228D9")),
				LinkDefinitionScript.new(&"link_10", &"ring_11", &"ring_1", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_11", &"ring_9", &"ring_8", Color("#C8202F"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_8", 169.5, true),
				SolutionStepScript.new(&"ring_1", 195.3, true),
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
			def.par_moves = 11
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(215.0, 357.0), 76.0, 24.0, Color("#C8202F"), 180.3, [GapDefinitionScript.new(1.3, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(519.0, 691.0), 76.0, 24.0, Color("#32ADDA"), 166.7, [GapDefinitionScript.new(13.7, 56.0, 16.0), GapDefinitionScript.new(214.1, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(215.0, 357.0), 150.0, 24.0, Color("#32ADDA"), 138.6, [])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(215.0, 357.0), 40.0, 24.0, Color("#62C73E"), 224.2, [])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(254.0, 744.0), 76.0, 24.0, Color("#8228D9"), 30.6, [GapDefinitionScript.new(14.8, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(519.0, 691.0), 150.0, 24.0, Color("#EA7829"), 9.2, [GapDefinitionScript.new(22.4, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(215.0, 357.0), 115.0, 24.0, Color("#C8202F"), 74.5, [])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(519.0, 691.0), 115.0, 24.0, Color("#4361CF"), 167.3, [GapDefinitionScript.new(184.9, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(258.0, 595.0), 40.0, 24.0, Color("#C8202F"), 130.3, [GapDefinitionScript.new(188.5, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(490.0, 352.0), 76.0, 24.0, Color("#32ADDA"), 27.4, [GapDefinitionScript.new(254.2, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(335.0, 526.0), 40.0, 24.0, Color("#32ADDA"), 136.0, [GapDefinitionScript.new(335.9, 56.0, 16.0)])
			var r11 = PieceDefinitionScript.new(&"ring_11", Vector2(519.0, 691.0), 40.0, 24.0, Color("#4361CF"), 285.0, [GapDefinitionScript.new(330.2, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_6", &"ring_4", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_1", &"ring_6", &"ring_10", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_2", &"ring_10", &"ring_8", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_3", &"ring_8", &"ring_9", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_4", &"ring_10", &"ring_11", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_5", &"ring_2", &"ring_5", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_6", &"ring_3", &"ring_7", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_7", &"ring_6", &"ring_1", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_8", &"ring_2", &"ring_1", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_9", &"ring_11", &"ring_0", Color("#4361CF"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_0", 46.4, true),
				SolutionStepScript.new(&"ring_1", 13.6, true),
				SolutionStepScript.new(&"ring_1", 214.0, true),
				SolutionStepScript.new(&"ring_7", 42.8, true),
				SolutionStepScript.new(&"ring_5", 205.3, true),
				SolutionStepScript.new(&"ring_11", 251.7, true),
				SolutionStepScript.new(&"ring_9", 239.5, true),
				SolutionStepScript.new(&"ring_8", 129.6, true),
				SolutionStepScript.new(&"ring_10", 258.7, true),
				SolutionStepScript.new(&"ring_4", 249.5, true)
			]

		46:
			def.title = "Level 46"
			def.instruction = "Clear the rings!"
			def.par_moves = 12
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(450.0, 725.0), 76.0, 24.0, Color("#8228D9"), 158.5, [GapDefinitionScript.new(164.0, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(450.0, 725.0), 40.0, 24.0, Color("#CB2336"), 343.3, [GapDefinitionScript.new(186.5, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(414.0, 488.0), 76.0, 24.0, Color("#CB2336"), 19.5, [GapDefinitionScript.new(209.0, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(414.0, 488.0), 150.0, 24.0, Color("#F38224"), 20.4, [GapDefinitionScript.new(109.2, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(218.0, 829.0), 76.0, 24.0, Color("#29B6F6"), 329.3, [GapDefinitionScript.new(276.6, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(414.0, 488.0), 40.0, 24.0, Color("#C8202F"), 69.9, [GapDefinitionScript.new(215.7, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(218.0, 829.0), 40.0, 24.0, Color("#8228D9"), 213.6, [GapDefinitionScript.new(143.2, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(340.0, 875.0), 40.0, 24.0, Color("#F38224"), 70.6, [GapDefinitionScript.new(273.8, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(210.0, 627.0), 40.0, 24.0, Color("#F38224"), 212.1, [GapDefinitionScript.new(241.2, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(414.0, 488.0), 115.0, 24.0, Color("#32ADDA"), 214.3, [])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(209.0, 390.0), 40.0, 24.0, Color("#8228D9"), 39.2, [GapDefinitionScript.new(279.1, 56.0, 16.0)])
			var r11 = PieceDefinitionScript.new(&"ring_11", Vector2(210.0, 627.0), 76.0, 24.0, Color("#F38224"), 194.7, [GapDefinitionScript.new(141.6, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_9", &"ring_1", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_1", &"ring_1", &"ring_8", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_2", &"ring_8", &"ring_5", Color("#F38224")),
				LinkDefinitionScript.new(&"link_3", &"ring_5", &"ring_11", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_4", &"ring_5", &"ring_4", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_5", &"ring_11", &"ring_10", Color("#F38224")),
				LinkDefinitionScript.new(&"link_6", &"ring_11", &"ring_2", Color("#F38224")),
				LinkDefinitionScript.new(&"link_7", &"ring_1", &"ring_3", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_8", &"ring_9", &"ring_0", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_9", &"ring_1", &"ring_6", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_10", &"ring_0", &"ring_7", Color("#8228D9"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_7", 32.4, true),
				SolutionStepScript.new(&"ring_6", 192.6, true),
				SolutionStepScript.new(&"ring_0", 97.4, true),
				SolutionStepScript.new(&"ring_3", 332.2, true),
				SolutionStepScript.new(&"ring_2", 296.7, true),
				SolutionStepScript.new(&"ring_10", 170.7, true),
				SolutionStepScript.new(&"ring_4", 23.3, true),
				SolutionStepScript.new(&"ring_11", 184.1, true),
				SolutionStepScript.new(&"ring_5", 290.0, true),
				SolutionStepScript.new(&"ring_8", 141.1, true),
				SolutionStepScript.new(&"ring_1", 74.8, true)
			]

		47:
			def.title = "Level 47"
			def.instruction = "Clear the rings!"
			def.par_moves = 13
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(278.0, 737.0), 76.0, 24.0, Color("#4361CF"), 332.5, [])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(349.0, 432.0), 115.0, 24.0, Color("#4361CF"), 181.3, [GapDefinitionScript.new(217.2, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(499.0, 889.0), 150.0, 24.0, Color("#C8202F"), 41.0, [GapDefinitionScript.new(324.0, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(499.0, 889.0), 76.0, 24.0, Color("#C8202F"), 286.0, [GapDefinitionScript.new(91.5, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(462.0, 553.0), 40.0, 24.0, Color("#4361CF"), 233.6, [GapDefinitionScript.new(77.4, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(499.0, 889.0), 40.0, 24.0, Color("#CB2336"), 231.1, [GapDefinitionScript.new(185.6, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(349.0, 432.0), 76.0, 24.0, Color("#C8202F"), 124.6, [GapDefinitionScript.new(275.8, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(499.0, 889.0), 115.0, 24.0, Color("#CB2336"), 220.8, [GapDefinitionScript.new(44.3, 56.0, 16.0), GapDefinitionScript.new(70.1, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(481.0, 665.0), 40.0, 24.0, Color("#7D2AD4"), 78.9, [GapDefinitionScript.new(238.1, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(347.0, 429.0), 40.0, 24.0, Color("#32ADDA"), 118.4, [GapDefinitionScript.new(34.7, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(386.0, 650.0), 40.0, 24.0, Color("#29B6F6"), 259.8, [GapDefinitionScript.new(192.9, 56.0, 16.0)])
			var r11 = PieceDefinitionScript.new(&"ring_11", Vector2(278.0, 737.0), 40.0, 24.0, Color("#EA7829"), 297.8, [GapDefinitionScript.new(172.9, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_5", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_1", &"ring_5", &"ring_8", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_2", &"ring_8", &"ring_2", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_3", &"ring_2", &"ring_11", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_4", &"ring_8", &"ring_1", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_5", &"ring_0", &"ring_4", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_6", &"ring_4", &"ring_9", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_7", &"ring_8", &"ring_6", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_8", &"ring_6", &"ring_7", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_9", &"ring_11", &"ring_7", Color("#EA7829")),
				LinkDefinitionScript.new(&"link_10", &"ring_4", &"ring_3", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_11", &"ring_11", &"ring_10", Color("#EA7829"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_10", 308.2, true),
				SolutionStepScript.new(&"ring_3", 172.2, true),
				SolutionStepScript.new(&"ring_7", 144.4, true),
				SolutionStepScript.new(&"ring_7", 207.5, true),
				SolutionStepScript.new(&"ring_6", 144.7, true),
				SolutionStepScript.new(&"ring_9", 12.5, true),
				SolutionStepScript.new(&"ring_4", 57.6, true),
				SolutionStepScript.new(&"ring_1", 203.3, true),
				SolutionStepScript.new(&"ring_11", 221.6, true),
				SolutionStepScript.new(&"ring_2", 301.4, true),
				SolutionStepScript.new(&"ring_8", 207.3, true),
				SolutionStepScript.new(&"ring_5", 28.9, true)
			]

		48:
			def.title = "Level 48"
			def.instruction = "Clear the rings!"
			def.par_moves = 11
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(273.0, 797.0), 150.0, 24.0, Color("#29B6F6"), 31.9, [])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(273.0, 797.0), 115.0, 24.0, Color("#C8202F"), 312.2, [GapDefinitionScript.new(256.8, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(395.0, 548.0), 115.0, 24.0, Color("#F38224"), 300.9, [GapDefinitionScript.new(294.4, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(225.0, 422.0), 40.0, 24.0, Color("#C8202F"), 94.5, [GapDefinitionScript.new(167.1, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(495.0, 406.0), 40.0, 24.0, Color("#CB2336"), 187.5, [GapDefinitionScript.new(53.6, 56.0, 16.0), GapDefinitionScript.new(219.6, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(273.0, 797.0), 40.0, 24.0, Color("#F38224"), 147.7, [])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(395.0, 548.0), 76.0, 24.0, Color("#62C73E"), 298.1, [GapDefinitionScript.new(334.5, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(395.0, 548.0), 40.0, 24.0, Color("#62C73E"), 128.0, [GapDefinitionScript.new(226.6, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(518.0, 826.0), 76.0, 24.0, Color("#62C73E"), 223.0, [GapDefinitionScript.new(279.8, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(225.0, 422.0), 76.0, 24.0, Color("#7D2AD4"), 198.0, [GapDefinitionScript.new(293.8, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(273.0, 797.0), 76.0, 24.0, Color("#32ADDA"), 167.5, [])
			var r11 = PieceDefinitionScript.new(&"ring_11", Vector2(518.0, 826.0), 40.0, 24.0, Color("#62C73E"), 337.5, [GapDefinitionScript.new(266.4, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_0", &"ring_7", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_1", &"ring_5", &"ring_8", Color("#F38224")),
				LinkDefinitionScript.new(&"link_2", &"ring_5", &"ring_11", Color("#F38224")),
				LinkDefinitionScript.new(&"link_3", &"ring_0", &"ring_9", Color("#29B6F6")),
				LinkDefinitionScript.new(&"link_4", &"ring_8", &"ring_2", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_5", &"ring_10", &"ring_6", Color("#32ADDA")),
				LinkDefinitionScript.new(&"link_6", &"ring_11", &"ring_1", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_7", &"ring_7", &"ring_3", Color("#62C73E")),
				LinkDefinitionScript.new(&"link_8", &"ring_3", &"ring_4", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_9", &"ring_8", &"ring_4", Color("#62C73E"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_4", 227.3, true),
				SolutionStepScript.new(&"ring_4", 123.0, true),
				SolutionStepScript.new(&"ring_3", 229.4, true),
				SolutionStepScript.new(&"ring_1", 110.0, true),
				SolutionStepScript.new(&"ring_6", 141.6, true),
				SolutionStepScript.new(&"ring_2", 131.7, true),
				SolutionStepScript.new(&"ring_9", 148.9, true),
				SolutionStepScript.new(&"ring_11", 280.4, true),
				SolutionStepScript.new(&"ring_8", 266.9, true),
				SolutionStepScript.new(&"ring_7", 249.5, true)
			]

		49:
			def.title = "Level 49"
			def.instruction = "Clear the rings!"
			def.par_moves = 15
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(490.0, 624.0), 150.0, 24.0, Color("#32ADDA"), 288.6, [GapDefinitionScript.new(321.1, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(358.0, 830.0), 76.0, 24.0, Color("#32ADDA"), 227.9, [GapDefinitionScript.new(139.4, 56.0, 16.0), GapDefinitionScript.new(197.7, 56.0, 16.0)])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(436.0, 375.0), 40.0, 24.0, Color("#62C73E"), 332.2, [GapDefinitionScript.new(158.6, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(436.0, 375.0), 76.0, 24.0, Color("#4361CF"), 310.6, [GapDefinitionScript.new(157.1, 56.0, 16.0)])
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
				LinkDefinitionScript.new(&"link_6", &"ring_6", &"ring_3", Color("#8228D9")),
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
			var r0 = PieceDefinitionScript.new(&"ring_0", Vector2(293.0, 773.0), 115.0, 24.0, Color("#4361CF"), 222.6, [GapDefinitionScript.new(92.4, 56.0, 16.0)])
			var r1 = PieceDefinitionScript.new(&"ring_1", Vector2(293.0, 773.0), 150.0, 24.0, Color("#4361CF"), 168.4, [])
			var r2 = PieceDefinitionScript.new(&"ring_2", Vector2(346.0, 498.0), 76.0, 24.0, Color("#CB2336"), 231.1, [GapDefinitionScript.new(16.1, 56.0, 16.0)])
			var r3 = PieceDefinitionScript.new(&"ring_3", Vector2(346.0, 498.0), 115.0, 24.0, Color("#7D2AD4"), 246.5, [GapDefinitionScript.new(8.0, 56.0, 16.0)])
			var r4 = PieceDefinitionScript.new(&"ring_4", Vector2(520.0, 499.0), 40.0, 24.0, Color("#CB2336"), 92.6, [GapDefinitionScript.new(129.5, 56.0, 16.0), GapDefinitionScript.new(12.6, 56.0, 16.0)])
			var r5 = PieceDefinitionScript.new(&"ring_5", Vector2(227.0, 370.0), 40.0, 24.0, Color("#7D2AD4"), 203.2, [GapDefinitionScript.new(163.4, 56.0, 16.0)])
			var r6 = PieceDefinitionScript.new(&"ring_6", Vector2(485.0, 595.0), 40.0, 24.0, Color("#EA7829"), 263.4, [GapDefinitionScript.new(34.3, 56.0, 16.0)])
			var r7 = PieceDefinitionScript.new(&"ring_7", Vector2(293.0, 773.0), 40.0, 24.0, Color("#C8202F"), 115.4, [GapDefinitionScript.new(235.9, 56.0, 16.0)])
			var r8 = PieceDefinitionScript.new(&"ring_8", Vector2(346.0, 498.0), 40.0, 24.0, Color("#C8202F"), 81.1, [GapDefinitionScript.new(250.5, 56.0, 16.0)])
			var r9 = PieceDefinitionScript.new(&"ring_9", Vector2(293.0, 773.0), 76.0, 24.0, Color("#29B6F6"), 244.3, [GapDefinitionScript.new(78.2, 56.0, 16.0)])
			var r10 = PieceDefinitionScript.new(&"ring_10", Vector2(520.0, 876.0), 40.0, 24.0, Color("#C8202F"), 359.3, [GapDefinitionScript.new(35.7, 56.0, 16.0)])
			def.pieces = [r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10]
			def.links = [
				LinkDefinitionScript.new(&"link_0", &"ring_1", &"ring_2", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_1", &"ring_1", &"ring_3", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_2", &"ring_3", &"ring_5", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_3", &"ring_5", &"ring_9", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_4", &"ring_2", &"ring_10", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_5", &"ring_1", &"ring_8", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_6", &"ring_3", &"ring_4", Color("#7D2AD4")),
				LinkDefinitionScript.new(&"link_7", &"ring_1", &"ring_4", Color("#4361CF")),
				LinkDefinitionScript.new(&"link_8", &"ring_4", &"ring_0", Color("#CB2336")),
				LinkDefinitionScript.new(&"link_9", &"ring_10", &"ring_6", Color("#C8202F")),
				LinkDefinitionScript.new(&"link_10", &"ring_10", &"ring_7", Color("#C8202F"))
			]
			def.canonical_steps = [
				SolutionStepScript.new(&"ring_7", 148.5, true),
				SolutionStepScript.new(&"ring_6", 48.6, true),
				SolutionStepScript.new(&"ring_0", 217.2, true),
				SolutionStepScript.new(&"ring_4", 117.0, true),
				SolutionStepScript.new(&"ring_4", 50.8, true),
				SolutionStepScript.new(&"ring_8", 210.4, true),
				SolutionStepScript.new(&"ring_10", 209.6, true),
				SolutionStepScript.new(&"ring_9", 182.5, true),
				SolutionStepScript.new(&"ring_5", 243.7, true),
				SolutionStepScript.new(&"ring_3", 92.9, true),
				SolutionStepScript.new(&"ring_2", 84.8, true)
			]

