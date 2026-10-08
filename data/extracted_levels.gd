## AUTO-GENERATED FROM level_extraction.json
## Use ExtractedLevels.build(level_id) to fetch.
extends RefCounted
class_name ExtractedLevels

const PieceDefinitionScript = preload("res://data/piece_definition.gd")
const GapDefinitionScript = preload("res://data/gap_definition.gd")
const LinkDefinitionScript = preload("res://data/link_definition.gd")
const LevelDefinitionScript = preload("res://data/level_definition.gd")

static func build(level_id: int):
	match level_id:
		77:
			var def := LevelDefinitionScript.new()
			def.level_id = 77
			def.title = "Level 77"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r17 := PieceDefinitionScript.new(&"r17", Vector2(404.0, 680.0), 110.0, 22.0, Color("#8B5CF6"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r17.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r1", Vector2(230.0, 280.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(155.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r2", Vector2(404.0, 280.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(270.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r3", Vector2(586.0, 280.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(245.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r4", Vector2(767.0, 280.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r5", Vector2(230.0, 374.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r6", Vector2(404.0, 374.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r7", Vector2(586.0, 374.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r8", Vector2(767.0, 374.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r9", Vector2(230.0, 476.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(155.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r10", Vector2(404.0, 476.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(245.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r11", Vector2(586.0, 476.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(245.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r12", Vector2(767.0, 476.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r13", Vector2(230.0, 579.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(155.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r14", Vector2(586.0, 579.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r15", Vector2(767.0, 579.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r16", Vector2(230.0, 680.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(180.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r18", Vector2(586.0, 680.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r19", Vector2(767.0, 680.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r17)
			def.links = [
				LinkDefinitionScript.new(&"link_r1_r2", &"r1", &"r2", Color("#FF3B30"), 90.0, 104.0),
				LinkDefinitionScript.new(&"link_r1_r5", &"r1", &"r5", Color("#FF3B30"), 180.0, 24.0),
				LinkDefinitionScript.new(&"link_r2_r3", &"r2", &"r3", Color("#22C55E"), 90.0, 112.0),
				LinkDefinitionScript.new(&"link_r3_r4", &"r3", &"r4", Color("#22C55E"), 90.0, 111.0),
				LinkDefinitionScript.new(&"link_r3_r7", &"r3", &"r7", Color("#22C55E"), 180.0, 24.0),
				LinkDefinitionScript.new(&"link_r4_r8", &"r4", &"r8", Color("#FF3B30"), 180.0, 24.0),
				LinkDefinitionScript.new(&"link_r5_r6", &"r5", &"r6", Color("#06B6D4"), 90.0, 104.0),
				LinkDefinitionScript.new(&"link_r6_r7", &"r6", &"r7", Color("#22C55E"), 90.0, 112.0),
				LinkDefinitionScript.new(&"link_r7_r8", &"r7", &"r8", Color("#3B82F6"), 90.0, 111.0),
				LinkDefinitionScript.new(&"link_r8_r12", &"r8", &"r12", Color("#8B5CF6"), 180.0, 32.0),
				LinkDefinitionScript.new(&"link_r9_r10", &"r9", &"r10", Color("#3B82F6"), 90.0, 104.0),
				LinkDefinitionScript.new(&"link_r9_r13", &"r9", &"r13", Color("#3B82F6"), 180.0, 33.0),
				LinkDefinitionScript.new(&"link_r10_r11", &"r10", &"r11", Color("#22C55E"), 90.0, 112.0),
				LinkDefinitionScript.new(&"link_r11_r12", &"r11", &"r12", Color("#06B6D4"), 90.0, 111.0),
				LinkDefinitionScript.new(&"link_r11_r14", &"r11", &"r14", Color("#06B6D4"), 180.0, 33.0),
				LinkDefinitionScript.new(&"link_r12_r15", &"r12", &"r15", Color("#F97316"), 180.0, 33.0),
				LinkDefinitionScript.new(&"link_r13_r16", &"r13", &"r16", Color("#22C55E"), 180.0, 31.0),
				LinkDefinitionScript.new(&"link_r14_r18", &"r14", &"r18", Color("#8B5CF6"), 180.0, 31.0),
				LinkDefinitionScript.new(&"link_r15_r19", &"r15", &"r19", Color("#8B5CF6"), 180.0, 31.0),
				LinkDefinitionScript.new(&"link_r17_r18", &"r17", &"r18", Color("#8B5CF6"), 90.0, 92.0),
				LinkDefinitionScript.new(&"link_r18_r19", &"r18", &"r19", Color("#06B6D4"), 90.0, 111.0),
				LinkDefinitionScript.new(&"link_r13_r10", &"r13", &"r10", Color("#22C55E"), 90.0, 132.2),
				LinkDefinitionScript.new(&"link_r14_r10", &"r14", &"r10", Color("#8B5CF6"), 270.0, 139.1),
			]
			return def
		78:
			var def := LevelDefinitionScript.new()
			def.level_id = 78
			def.title = "Level 78"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r9 := PieceDefinitionScript.new(&"r9", Vector2(550.0, 360.0), 110.0, 22.0, Color("#FF3B30"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r9.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r5", Vector2(480.0, 270.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(225.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r6", Vector2(570.0, 270.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(270.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r7", Vector2(270.0, 310.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(180.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r8", Vector2(420.0, 360.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r10", Vector2(300.0, 410.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(165.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r11", Vector2(360.0, 470.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(120.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r12", Vector2(480.0, 450.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(235.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r13", Vector2(580.0, 520.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r14", Vector2(180.0, 580.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(125.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r15", Vector2(230.0, 480.0), 56.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r16", Vector2(280.0, 550.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r17", Vector2(420.0, 550.0), 56.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r18", Vector2(220.0, 650.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(90.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r19", Vector2(320.0, 650.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r20", Vector2(420.0, 650.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(270.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r21", Vector2(480.0, 650.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r22", Vector2(560.0, 650.0), 56.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r9)
			def.links = [
				LinkDefinitionScript.new(&"link_r5_r6", &"r5", &"r6", Color("#22C55E"), 90.0, 20.0),
				LinkDefinitionScript.new(&"link_r5_r8", &"r5", &"r8", Color("#22C55E"), 180.0, 38.2),
				LinkDefinitionScript.new(&"link_r7_r8", &"r7", &"r8", Color("#06B6D4"), 90.0, 88.1),
				LinkDefinitionScript.new(&"link_r7_r10", &"r7", &"r10", Color("#06B6D4"), 180.0, 34.4),
				LinkDefinitionScript.new(&"link_r9_r12", &"r9", &"r12", Color("#FF3B30"), 180.0, 24.0),
				LinkDefinitionScript.new(&"link_r10_r11", &"r10", &"r11", Color("#3B82F6"), 90.0, 14.9),
				LinkDefinitionScript.new(&"link_r10_r16", &"r10", &"r16", Color("#3B82F6"), 180.0, 71.4),
				LinkDefinitionScript.new(&"link_r11_r12", &"r11", &"r12", Color("#22C55E"), 90.0, 51.7),
				LinkDefinitionScript.new(&"link_r11_r17", &"r11", &"r17", Color("#22C55E"), 180.0, 37.0),
				LinkDefinitionScript.new(&"link_r12_r13", &"r12", &"r13", Color("#8B5CF6"), 90.0, 52.1),
				LinkDefinitionScript.new(&"link_r12_r21", &"r12", &"r21", Color("#8B5CF6"), 180.0, 130.0),
				LinkDefinitionScript.new(&"link_r15_r14", &"r15", &"r14", Color("#FF3B30"), 180.0, 48.8),
				LinkDefinitionScript.new(&"link_r14_r16", &"r14", &"r16", Color("#F97316"), 90.0, 34.4),
				LinkDefinitionScript.new(&"link_r14_r18", &"r14", &"r18", Color("#F97316"), 180.0, 10.6),
				LinkDefinitionScript.new(&"link_r16_r19", &"r16", &"r19", Color("#22C55E"), 180.0, 37.7),
				LinkDefinitionScript.new(&"link_r18_r19", &"r18", &"r19", Color("#8B5CF6"), 90.0, 30.0),
				LinkDefinitionScript.new(&"link_r19_r20", &"r19", &"r20", Color("#22C55E"), 90.0, 30.0),
				LinkDefinitionScript.new(&"link_r20_r21", &"r20", &"r21", Color("#3B82F6"), 90.0, 4.0),
				LinkDefinitionScript.new(&"link_r13_r22", &"r13", &"r22", Color("#8B5CF6"), 180.0, 68.5),
			]
			return def
		79:
			var def := LevelDefinitionScript.new()
			def.level_id = 79
			def.title = "Level 79"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r7 := PieceDefinitionScript.new(&"r7", Vector2(288.0, 403.0), 110.0, 22.0, Color("#F97316"), 216.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r7.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r1", Vector2(462.0, 177.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(220.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r2", Vector2(259.0, 272.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(270.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r3", Vector2(461.0, 326.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(155.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r4", Vector2(660.0, 271.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r5", Vector2(659.0, 394.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r6", Vector2(461.0, 381.0), 56.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(180.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r10", Vector2(257.0, 516.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r12", Vector2(262.0, 640.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r15", Vector2(733.0, 637.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r17", Vector2(258.0, 763.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(180.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r19", Vector2(461.0, 756.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r21", Vector2(661.0, 757.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(90.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r7)
			def.links = [
				LinkDefinitionScript.new(&"link_r1_r2", &"r1", &"r2", Color("#F97316"), 270.0, 154.1),
				LinkDefinitionScript.new(&"link_r1_r4", &"r1", &"r4", Color("#F97316"), 90.0, 149.2),
				LinkDefinitionScript.new(&"link_r1_r3", &"r1", &"r3", Color("#F97316"), 180.0, 79.0),
				LinkDefinitionScript.new(&"link_r4_r3", &"r4", &"r3", Color("#8B5CF6"), 270.0, 136.5),
				LinkDefinitionScript.new(&"link_r4_r5", &"r4", &"r5", Color("#8B5CF6"), 180.0, 53.0),
				LinkDefinitionScript.new(&"link_r3_r6", &"r3", &"r6", Color("#F97316"), 180.0, 4.0),
				LinkDefinitionScript.new(&"link_r2_r10", &"r2", &"r10", Color("#06B6D4"), 180.0, 174.0),
				LinkDefinitionScript.new(&"link_r5_r15", &"r5", &"r15", Color("#FF3B30"), 180.0, 184.0),
				LinkDefinitionScript.new(&"link_r10_r12", &"r10", &"r12", Color("#06B6D4"), 180.0, 54.1),
				LinkDefinitionScript.new(&"link_r15_r21", &"r15", &"r21", Color("#FF3B30"), 180.0, 69.9),
				LinkDefinitionScript.new(&"link_r12_r17", &"r12", &"r17", Color("#3B82F6"), 180.0, 53.1),
				LinkDefinitionScript.new(&"link_r17_r19", &"r17", &"r19", Color("#22C55E"), 90.0, 133.1),
				LinkDefinitionScript.new(&"link_r19_r21", &"r19", &"r21", Color("#06B6D4"), 90.0, 130.0),
			]
			return def
		80:
			var def := LevelDefinitionScript.new()
			def.level_id = 80
			def.title = "Level 80"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r21 := PieceDefinitionScript.new(&"r21", Vector2(404.0, 715.0), 110.0, 22.0, Color("#3B82F6"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r21.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r1", Vector2(498.0, 285.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(13.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r2", Vector2(393.0, 308.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(200.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r3", Vector2(499.0, 393.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(40.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r4", Vector2(497.0, 381.0), 56.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r5", Vector2(497.0, 392.0), 56.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(90.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r6", Vector2(505.0, 390.0), 56.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(353.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r7", Vector2(234.0, 482.0), 80.0, 20.0, Color("#8B5CF6"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r8", Vector2(211.0, 483.0), 56.0, 20.0, Color("#FF3B30"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r9", Vector2(249.0, 526.0), 80.0, 20.0, Color("#22C55E"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r10", Vector2(272.0, 524.0), 56.0, 20.0, Color("#3B82F6"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r11", Vector2(732.0, 476.0), 80.0, 20.0, Color("#22C55E"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r12", Vector2(757.0, 475.0), 56.0, 20.0, Color("#06B6D4"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r13", Vector2(718.0, 523.0), 80.0, 20.0, Color("#8B5CF6"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r14", Vector2(743.0, 523.0), 56.0, 20.0, Color("#F97316"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r21)
			def.links = [
				LinkDefinitionScript.new(&"link_r1_r2", &"r1", &"r2", Color("#8B5CF6"), 289.0, 37.5),
				LinkDefinitionScript.new(&"link_r1_r3", &"r1", &"r3", Color("#8B5CF6"), 181.0, 38.0),
				LinkDefinitionScript.new(&"link_r1_r4", &"r1", &"r4", Color("#8B5CF6"), 140.0, 33.0),
				LinkDefinitionScript.new(&"link_r3_r5", &"r3", &"r5", Color("#8B5CF6"), 272.0, 4.0),
				LinkDefinitionScript.new(&"link_r3_r6", &"r3", &"r6", Color("#8B5CF6"), 93.0, 4.0),
			]
			return def
		81:
			var def := LevelDefinitionScript.new()
			def.level_id = 81
			def.title = "Level 81"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r4 := PieceDefinitionScript.new(&"r4", Vector2(284.0, 279.0), 110.0, 22.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(50.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r4.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r10", Vector2(315.0, 465.0), 56.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(315.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r12", Vector2(409.0, 558.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(315.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r13", Vector2(486.0, 651.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(90.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r14", Vector2(657.0, 651.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(270.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r16", Vector2(477.0, 763.0), 56.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(90.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r4)
			def.links = [
				LinkDefinitionScript.new(&"link_r10_r12", &"r10", &"r12", Color("#FF3B30"), 135.0, 69.2),
				LinkDefinitionScript.new(&"link_r12_r13", &"r12", &"r13", Color("#8B5CF6"), 315.0, 50.7),
				LinkDefinitionScript.new(&"link_r13_r14", &"r13", &"r14", Color("#3B82F6"), 90.0, 101.0),
				LinkDefinitionScript.new(&"link_r14_r16", &"r14", &"r16", Color("#22C55E"), 225.0, 149.0),
			]
			return def
		82:
			var def := LevelDefinitionScript.new()
			def.level_id = 82
			def.title = "Level 82"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r1 := PieceDefinitionScript.new(&"r1", Vector2(500.0, 456.0), 110.0, 22.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r1.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r14", Vector2(698.0, 703.0), 56.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(270.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r15", Vector2(670.0, 793.0), 56.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(180.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r1)
			def.links = [
				LinkDefinitionScript.new(&"link_r14_r15", &"r14", &"r15", Color("#3B82F6"), 180.0, 38.3),
			]
			return def
		83:
			var def := LevelDefinitionScript.new()
			def.level_id = 83
			def.title = "Level 83"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r3 := PieceDefinitionScript.new(&"r3", Vector2(360.0, 303.0), 110.0, 22.0, Color("#06B6D4"), 180.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r3.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r1", Vector2(360.0, 343.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r2", Vector2(283.0, 344.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(120.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r4", Vector2(438.0, 345.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r5", Vector2(360.0, 453.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(90.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r6", Vector2(215.0, 587.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r7", Vector2(506.0, 587.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r8", Vector2(215.0, 711.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(90.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r9", Vector2(360.0, 704.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(70.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r10", Vector2(506.0, 711.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r3)
			def.links = [
				LinkDefinitionScript.new(&"link_r1_r2", &"r1", &"r2", Color("#FF3B30"), 270.0, 7.0),
				LinkDefinitionScript.new(&"link_r1_r4", &"r1", &"r4", Color("#FF3B30"), 90.0, 8.0),
				LinkDefinitionScript.new(&"link_r2_r5", &"r2", &"r5", Color("#F97316"), 135.0, 63.5),
				LinkDefinitionScript.new(&"link_r3_r2", &"r3", &"r2", Color("#06B6D4"), 225.0, 4.0),
				LinkDefinitionScript.new(&"link_r3_r4", &"r3", &"r4", Color("#06B6D4"), 135.0, 4.0),
				LinkDefinitionScript.new(&"link_r4_r5", &"r4", &"r5", Color("#8B5CF6"), 225.0, 63.2),
				LinkDefinitionScript.new(&"link_r6_r8", &"r6", &"r8", Color("#06B6D4"), 180.0, 54.0),
				LinkDefinitionScript.new(&"link_r7_r10", &"r7", &"r10", Color("#F97316"), 180.0, 54.0),
				LinkDefinitionScript.new(&"link_r8_r9", &"r8", &"r9", Color("#3B82F6"), 90.0, 75.2),
				LinkDefinitionScript.new(&"link_r9_r10", &"r9", &"r10", Color("#22C55E"), 90.0, 76.2),
			]
			return def
		84:
			var def := LevelDefinitionScript.new()
			def.level_id = 84
			def.title = "Level 84"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r8 := PieceDefinitionScript.new(&"r8", Vector2(360.0, 420.0), 110.0, 22.0, Color("#8B5CF6"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r8.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r1", Vector2(200.0, 260.0), 56.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(110.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r2", Vector2(520.0, 260.0), 56.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r3", Vector2(200.0, 340.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(270.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r4", Vector2(280.0, 340.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(315.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r5", Vector2(440.0, 340.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r6", Vector2(520.0, 340.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r7", Vector2(280.0, 420.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(155.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r9", Vector2(440.0, 420.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(20.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r10", Vector2(280.0, 500.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(315.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r11", Vector2(440.0, 500.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(45.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r12", Vector2(200.0, 500.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(155.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r13", Vector2(520.0, 500.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r14", Vector2(200.0, 580.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(110.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r15", Vector2(280.0, 580.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r16", Vector2(440.0, 580.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r17", Vector2(520.0, 580.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r18", Vector2(280.0, 660.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r19", Vector2(440.0, 660.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(20.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r8)
			def.links = [
				LinkDefinitionScript.new(&"link_r1_r4", &"r1", &"r4", Color("#22C55E"), 135.0, 50.1),
				LinkDefinitionScript.new(&"link_r2_r5", &"r2", &"r5", Color("#3B82F6"), 225.0, 50.1),
				LinkDefinitionScript.new(&"link_r3_r4", &"r3", &"r4", Color("#22C55E"), 90.0, 10.0),
				LinkDefinitionScript.new(&"link_r3_r7", &"r3", &"r7", Color("#22C55E"), 135.0, 43.1),
				LinkDefinitionScript.new(&"link_r4_r7", &"r4", &"r7", Color("#FF3B30"), 180.0, 10.0),
				LinkDefinitionScript.new(&"link_r6_r5", &"r6", &"r5", Color("#22C55E"), 270.0, 10.0),
				LinkDefinitionScript.new(&"link_r8_r4", &"r8", &"r4", Color("#8B5CF6"), 315.0, 23.1),
				LinkDefinitionScript.new(&"link_r8_r5", &"r8", &"r5", Color("#8B5CF6"), 45.0, 23.1),
				LinkDefinitionScript.new(&"link_r8_r7", &"r8", &"r7", Color("#8B5CF6"), 270.0, 4.0),
				LinkDefinitionScript.new(&"link_r8_r9", &"r8", &"r9", Color("#8B5CF6"), 90.0, 4.0),
				LinkDefinitionScript.new(&"link_r9_r6", &"r9", &"r6", Color("#3B82F6"), 45.0, 43.1),
				LinkDefinitionScript.new(&"link_r10_r7", &"r10", &"r7", Color("#06B6D4"), 0.0, 10.0),
				LinkDefinitionScript.new(&"link_r10_r11", &"r10", &"r11", Color("#06B6D4"), 90.0, 90.0),
				LinkDefinitionScript.new(&"link_r10_r12", &"r10", &"r12", Color("#06B6D4"), 270.0, 10.0),
				LinkDefinitionScript.new(&"link_r10_r15", &"r10", &"r15", Color("#06B6D4"), 180.0, 10.0),
				LinkDefinitionScript.new(&"link_r11_r9", &"r11", &"r9", Color("#F97316"), 0.0, 10.0),
				LinkDefinitionScript.new(&"link_r11_r13", &"r11", &"r13", Color("#F97316"), 90.0, 10.0),
				LinkDefinitionScript.new(&"link_r11_r16", &"r11", &"r16", Color("#F97316"), 180.0, 10.0),
				LinkDefinitionScript.new(&"link_r12_r14", &"r12", &"r14", Color("#22C55E"), 180.0, 10.0),
				LinkDefinitionScript.new(&"link_r13_r17", &"r13", &"r17", Color("#22C55E"), 180.0, 10.0),
				LinkDefinitionScript.new(&"link_r14_r18", &"r14", &"r18", Color("#FF3B30"), 135.0, 43.1),
				LinkDefinitionScript.new(&"link_r18_r15", &"r18", &"r15", Color("#8B5CF6"), 0.0, 10.0),
				LinkDefinitionScript.new(&"link_r18_r19", &"r18", &"r19", Color("#8B5CF6"), 90.0, 90.0),
				LinkDefinitionScript.new(&"link_r19_r16", &"r19", &"r16", Color("#F97316"), 0.0, 10.0),
				LinkDefinitionScript.new(&"link_r19_r17", &"r19", &"r17", Color("#F97316"), 45.0, 43.1),
			]
			return def
		85:
			var def := LevelDefinitionScript.new()
			def.level_id = 85
			def.title = "Level 85"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r14 := PieceDefinitionScript.new(&"r14", Vector2(490.0, 600.0), 110.0, 22.0, Color("#FF3B30"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r14.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r1", Vector2(230.0, 310.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(180.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r2", Vector2(360.0, 320.0), 80.0, 20.0, Color("#3B82F6"), 90.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r3", Vector2(510.0, 370.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r4", Vector2(530.0, 290.0), 56.0, 20.0, Color("#8B5CF6"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r5", Vector2(570.0, 370.0), 56.0, 20.0, Color("#8B5CF6"), 90.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r6", Vector2(180.0, 420.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(135.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r7", Vector2(310.0, 440.0), 80.0, 20.0, Color("#F97316"), 90.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r8", Vector2(420.0, 430.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(240.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r9", Vector2(220.0, 520.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(80.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r10", Vector2(290.0, 540.0), 80.0, 20.0, Color("#3B82F6"), 180.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r11", Vector2(520.0, 500.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r12", Vector2(410.0, 510.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(190.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r13", Vector2(350.0, 600.0), 80.0, 20.0, Color("#FF3B30"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r15", Vector2(570.0, 680.0), 80.0, 20.0, Color("#22C55E"), 180.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r16", Vector2(310.0, 710.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(225.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r22", Vector2(480.0, 710.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(45.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r23", Vector2(230.0, 740.0), 80.0, 20.0, Color("#3B82F6"), 270.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r24", Vector2(200.0, 770.0), 80.0, 20.0, Color("#22C55E"), 90.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r25", Vector2(200.0, 810.0), 56.0, 20.0, Color("#22C55E"), 90.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r26", Vector2(400.0, 780.0), 80.0, 20.0, Color("#8B5CF6"), 90.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r14)
			def.links = [
				LinkDefinitionScript.new(&"link_r1_r6", &"r1", &"r6", Color("#06B6D4"), 180.0, 50.8),
				LinkDefinitionScript.new(&"link_r2_r3", &"r2", &"r3", Color("#3B82F6"), 270.0, 83.1),
				LinkDefinitionScript.new(&"link_r6_r9", &"r6", &"r9", Color("#06B6D4"), 180.0, 37.7),
				LinkDefinitionScript.new(&"link_r7_r8", &"r7", &"r8", Color("#F97316"), 270.0, 35.5),
				LinkDefinitionScript.new(&"link_r8_r12", &"r8", &"r12", Color("#8B5CF6"), 180.0, 10.6),
				LinkDefinitionScript.new(&"link_r8_r11", &"r8", &"r11", Color("#8B5CF6"), 90.0, 52.1),
				LinkDefinitionScript.new(&"link_r11_r12", &"r11", &"r12", Color("#F97316"), 270.0, 40.5),
				LinkDefinitionScript.new(&"link_r13_r12", &"r13", &"r12", Color("#FF3B30"), 180.0, 33.2),
				LinkDefinitionScript.new(&"link_r14_r16", &"r14", &"r16", Color("#FF3B30"), 180.0, 121.0),
				LinkDefinitionScript.new(&"link_r14_r22", &"r14", &"r22", Color("#FF3B30"), 180.0, 20.5),
				LinkDefinitionScript.new(&"link_r15_r22", &"r15", &"r22", Color("#22C55E"), 90.0, 19.9),
				LinkDefinitionScript.new(&"link_r26_r22", &"r26", &"r22", Color("#8B5CF6"), 180.0, 31.3),
			]
			return def
		86:
			var def := LevelDefinitionScript.new()
			def.level_id = 86
			def.title = "Level 86"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r10 := PieceDefinitionScript.new(&"r10", Vector2(360.0, 490.0), 110.0, 22.0, Color("#8B5CF6"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r10.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r1", Vector2(360.0, 210.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(225.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r2", Vector2(220.0, 260.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(185.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r3", Vector2(500.0, 260.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(265.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r4", Vector2(280.0, 390.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(115.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r5", Vector2(440.0, 390.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r6", Vector2(140.0, 410.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(5.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r7", Vector2(580.0, 410.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r8", Vector2(180.0, 560.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(100.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r9", Vector2(540.0, 560.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r11", Vector2(270.0, 620.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(225.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r12", Vector2(450.0, 620.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(135.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r13", Vector2(360.0, 670.0), 80.0, 20.0, Color("#22C55E"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r14", Vector2(220.0, 760.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r15", Vector2(310.0, 760.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r16", Vector2(410.0, 760.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r17", Vector2(500.0, 760.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r18", Vector2(360.0, 350.0), 80.0, 20.0, Color("#06B6D4"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r19", Vector2(360.0, 580.0), 80.0, 20.0, Color("#8B5CF6"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r20", Vector2(270.0, 490.0), 80.0, 20.0, Color("#3B82F6"), 90.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r21", Vector2(450.0, 490.0), 80.0, 20.0, Color("#22C55E"), 90.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r10)
			def.links = [
				LinkDefinitionScript.new(&"link_r1_r2", &"r1", &"r2", Color("#8B5CF6"), 225.0, 78.7),
				LinkDefinitionScript.new(&"link_r1_r3", &"r1", &"r3", Color("#8B5CF6"), 135.0, 78.7),
				LinkDefinitionScript.new(&"link_r2_r4", &"r2", &"r4", Color("#22C55E"), 135.0, 73.2),
				LinkDefinitionScript.new(&"link_r2_r6", &"r2", &"r6", Color("#22C55E"), 225.0, 100.0),
				LinkDefinitionScript.new(&"link_r3_r5", &"r3", &"r5", Color("#FF3B30"), 225.0, 73.2),
				LinkDefinitionScript.new(&"link_r3_r7", &"r3", &"r7", Color("#FF3B30"), 135.0, 100.0),
				LinkDefinitionScript.new(&"link_r6_r8", &"r6", &"r8", Color("#06B6D4"), 135.0, 85.2),
				LinkDefinitionScript.new(&"link_r7_r9", &"r7", &"r9", Color("#F97316"), 225.0, 85.2),
				LinkDefinitionScript.new(&"link_r8_r11", &"r8", &"r11", Color("#3B82F6"), 135.0, 38.2),
				LinkDefinitionScript.new(&"link_r9_r12", &"r9", &"r12", Color("#22C55E"), 225.0, 38.2),
				LinkDefinitionScript.new(&"link_r10_r11", &"r10", &"r11", Color("#8B5CF6"), 225.0, 68.1),
				LinkDefinitionScript.new(&"link_r10_r12", &"r10", &"r12", Color("#8B5CF6"), 135.0, 68.1),
				LinkDefinitionScript.new(&"link_r11_r14", &"r11", &"r14", Color("#22C55E"), 225.0, 78.7),
				LinkDefinitionScript.new(&"link_r12_r17", &"r12", &"r17", Color("#FF3B30"), 135.0, 78.7),
				LinkDefinitionScript.new(&"link_r13_r15", &"r13", &"r15", Color("#22C55E"), 225.0, 28.0),
				LinkDefinitionScript.new(&"link_r13_r16", &"r13", &"r16", Color("#22C55E"), 135.0, 28.0),
				LinkDefinitionScript.new(&"link_r14_r15", &"r14", &"r15", Color("#FF3B30"), 90.0, 20.0),
				LinkDefinitionScript.new(&"link_r15_r16", &"r15", &"r16", Color("#06B6D4"), 90.0, 30.0),
				LinkDefinitionScript.new(&"link_r16_r17", &"r16", &"r17", Color("#F97316"), 90.0, 20.0),
			]
			return def
		87:
			var def := LevelDefinitionScript.new()
			def.level_id = 87
			def.title = "Level 87"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r3 := PieceDefinitionScript.new(&"r3", Vector2(267.0, 328.0), 110.0, 22.0, Color("#06B6D4"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r3.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r1", Vector2(381.0, 236.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(175.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r2", Vector2(625.0, 268.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r4", Vector2(600.0, 384.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r5", Vector2(381.0, 427.0), 80.0, 20.0, Color("#FF3B30"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r6", Vector2(313.0, 595.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(270.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r7", Vector2(497.0, 601.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(270.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r9", Vector2(323.0, 729.0), 56.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r11", Vector2(609.0, 196.0), 80.0, 20.0, Color("#22C55E"), 90.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r12", Vector2(497.0, 286.0), 80.0, 20.0, Color("#3B82F6"), 25.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r13", Vector2(323.0, 384.0), 80.0, 20.0, Color("#FF3B30"), 150.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r14", Vector2(497.0, 412.0), 80.0, 20.0, Color("#FF3B30"), 90.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r15", Vector2(381.0, 482.0), 80.0, 20.0, Color("#FF3B30"), 180.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r16", Vector2(454.0, 528.0), 80.0, 20.0, Color("#F97316"), 90.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r17", Vector2(182.0, 595.0), 56.0, 20.0, Color("#22C55E"), 270.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r18", Vector2(412.0, 595.0), 80.0, 20.0, Color("#22C55E"), 90.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r19", Vector2(323.0, 662.0), 80.0, 20.0, Color("#F97316"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r20", Vector2(497.0, 659.0), 80.0, 20.0, Color("#FF3B30"), 180.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r21", Vector2(560.0, 677.0), 80.0, 20.0, Color("#8B5CF6"), 90.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r3)
			def.links = [
				LinkDefinitionScript.new(&"link_r11_r1", &"r11", &"r1", Color("#22C55E"), 270.0, 156.5),
				LinkDefinitionScript.new(&"link_r11_r2", &"r11", &"r2", Color("#22C55E"), 90.0, 4.0),
				LinkDefinitionScript.new(&"link_r12_r2", &"r12", &"r2", Color("#3B82F6"), 205.0, 54.3),
				LinkDefinitionScript.new(&"link_r13_r1", &"r13", &"r1", Color("#FF3B30"), 330.0, 84.0),
				LinkDefinitionScript.new(&"link_r14_r4", &"r14", &"r4", Color("#FF3B30"), 270.0, 31.7),
				LinkDefinitionScript.new(&"link_r16_r2", &"r16", &"r2", Color("#F97316"), 270.0, 236.2),
				LinkDefinitionScript.new(&"link_r17_r6", &"r17", &"r6", Color("#22C55E"), 90.0, 68.0),
				LinkDefinitionScript.new(&"link_r18_r6", &"r18", &"r6", Color("#22C55E"), 270.0, 24.0),
				LinkDefinitionScript.new(&"link_r18_r7", &"r18", &"r7", Color("#22C55E"), 90.0, 10.2),
				LinkDefinitionScript.new(&"link_r19_r6", &"r19", &"r6", Color("#F97316"), 0.0, 4.0),
				LinkDefinitionScript.new(&"link_r19_r9", &"r19", &"r9", Color("#F97316"), 180.0, 4.0),
				LinkDefinitionScript.new(&"link_r20_r7", &"r20", &"r7", Color("#FF3B30"), 0.0, 4.0),
				LinkDefinitionScript.new(&"link_r21_r4", &"r21", &"r4", Color("#8B5CF6"), 90.0, 220.7),
			]
			return def
		88:
			var def := LevelDefinitionScript.new()
			def.level_id = 88
			def.title = "Level 88"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r6 := PieceDefinitionScript.new(&"r6", Vector2(689.0, 320.0), 110.0, 22.0, Color("#22C55E"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r6.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r9", Vector2(302.0, 463.0), 56.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(90.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r10", Vector2(485.0, 516.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r14", Vector2(535.0, 633.0), 56.0, 20.0, Color("#22C55E"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r6)
			def.links = [
				LinkDefinitionScript.new(&"link_r9_r10", &"r9", &"r10", Color("#22C55E"), 135.0, 127.5),
			]
			return def
		89:
			var def := LevelDefinitionScript.new()
			def.level_id = 89
			def.title = "Level 89"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r7 := PieceDefinitionScript.new(&"r7", Vector2(498.0, 483.0), 110.0, 22.0, Color("#06B6D4"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r7.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r1", Vector2(194.0, 322.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(155.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r2", Vector2(498.0, 298.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(270.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r3", Vector2(787.0, 320.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r4", Vector2(498.0, 396.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r5", Vector2(648.0, 396.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(180.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r6", Vector2(348.0, 483.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(245.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r8", Vector2(648.0, 483.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r9", Vector2(796.0, 483.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r10", Vector2(198.0, 483.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(155.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r11", Vector2(498.0, 569.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(80.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r12", Vector2(194.0, 644.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r13", Vector2(498.0, 647.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r14", Vector2(787.0, 644.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r15", Vector2(348.0, 571.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(90.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r7)
			def.links = [
				LinkDefinitionScript.new(&"link_r1_r2", &"r1", &"r2", Color("#8B5CF6"), 84.0, 234.9),
				LinkDefinitionScript.new(&"link_r1_r4", &"r1", &"r4", Color("#8B5CF6"), 142.0, 242.9),
				LinkDefinitionScript.new(&"link_r1_r10", &"r1", &"r10", Color("#8B5CF6"), 170.0, 91.0),
				LinkDefinitionScript.new(&"link_r2_r5", &"r2", &"r5", Color("#06B6D4"), 140.0, 109.2),
				LinkDefinitionScript.new(&"link_r2_r3", &"r2", &"r3", Color("#06B6D4"), 97.0, 219.8),
				LinkDefinitionScript.new(&"link_r3_r5", &"r3", &"r5", Color("#3B82F6"), 218.0, 88.4),
				LinkDefinitionScript.new(&"link_r3_r9", &"r3", &"r9", Color("#3B82F6"), 191.0, 93.2),
				LinkDefinitionScript.new(&"link_r4_r6", &"r4", &"r6", Color("#22C55E"), 210.0, 103.4),
				LinkDefinitionScript.new(&"link_r5_r8", &"r5", &"r8", Color("#3B82F6"), 180.0, 17.0),
				LinkDefinitionScript.new(&"link_r6_r10", &"r6", &"r10", Color("#8B5CF6"), 270.0, 80.0),
				LinkDefinitionScript.new(&"link_r6_r15", &"r6", &"r15", Color("#8B5CF6"), 180.0, 18.0),
				LinkDefinitionScript.new(&"link_r8_r9", &"r8", &"r9", Color("#F97316"), 90.0, 78.0),
				LinkDefinitionScript.new(&"link_r8_r11", &"r8", &"r11", Color("#F97316"), 210.0, 102.9),
				LinkDefinitionScript.new(&"link_r9_r14", &"r9", &"r14", Color("#8B5CF6"), 170.0, 91.3),
				LinkDefinitionScript.new(&"link_r10_r12", &"r10", &"r12", Color("#FF3B30"), 170.0, 91.0),
				LinkDefinitionScript.new(&"link_r11_r14", &"r11", &"r14", Color("#FF3B30"), 142.0, 228.6),
				LinkDefinitionScript.new(&"link_r12_r15", &"r12", &"r15", Color("#06B6D4"), 38.0, 100.4),
				LinkDefinitionScript.new(&"link_r12_r13", &"r12", &"r13", Color("#06B6D4"), 97.0, 234.0),
				LinkDefinitionScript.new(&"link_r13_r15", &"r13", &"r15", Color("#22C55E"), 320.0, 98.2),
				LinkDefinitionScript.new(&"link_r13_r14", &"r13", &"r14", Color("#22C55E"), 264.0, 219.0),
			]
			return def
		90:
			var def := LevelDefinitionScript.new()
			def.level_id = 90
			def.title = "Level 90"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r12 := PieceDefinitionScript.new(&"r12", Vector2(362.0, 452.0), 110.0, 22.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(25.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r12.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r11", Vector2(422.0, 403.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r14", Vector2(322.0, 413.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(110.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r20", Vector2(361.0, 520.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r12)
			def.links = [
				LinkDefinitionScript.new(&"link_r20_r12", &"r20", &"r12", Color("#F97316"), 0.0, 4.0),
				LinkDefinitionScript.new(&"link_r12_r20", &"r12", &"r20", Color("#06B6D4"), 180.0, 4.0),
				LinkDefinitionScript.new(&"link_r12_r11", &"r12", &"r11", Color("#06B6D4"), 50.0, 4.0),
				LinkDefinitionScript.new(&"link_r11_r12", &"r11", &"r12", Color("#FF3B30"), 230.0, 4.0),
				LinkDefinitionScript.new(&"link_r12_r14", &"r12", &"r14", Color("#06B6D4"), 310.0, 4.0),
				LinkDefinitionScript.new(&"link_r14_r12", &"r14", &"r12", Color("#F97316"), 130.0, 4.0),
			]
			return def
		91:
			var def := LevelDefinitionScript.new()
			def.level_id = 91
			def.title = "Level 91"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r8 := PieceDefinitionScript.new(&"r8", Vector2(597.0, 408.0), 110.0, 22.0, Color("#22C55E"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r8.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r10", Vector2(401.0, 413.0), 56.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(180.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r11", Vector2(401.0, 520.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r12", Vector2(239.0, 586.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(110.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r14", Vector2(587.0, 638.0), 56.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r15", Vector2(239.0, 689.0), 56.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(180.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r16", Vector2(392.0, 732.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(45.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r8)
			def.links = [
				LinkDefinitionScript.new(&"link_r11_r10", &"r11", &"r10", Color("#FF3B30"), 90.0, 44.0),
				LinkDefinitionScript.new(&"link_r12_r11", &"r12", &"r11", Color("#F97316"), 0.0, 104.9),
				LinkDefinitionScript.new(&"link_r12_r16", &"r12", &"r16", Color("#F97316"), 135.0, 141.5),
				LinkDefinitionScript.new(&"link_r14_r16", &"r14", &"r16", Color("#06B6D4"), 180.0, 153.5),
				LinkDefinitionScript.new(&"link_r15_r16", &"r15", &"r16", Color("#3B82F6"), 135.0, 95.9),
			]
			return def
		92:
			var def := LevelDefinitionScript.new()
			def.level_id = 92
			def.title = "Level 92"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r16 := PieceDefinitionScript.new(&"r16", Vector2(401.0, 587.0), 110.0, 22.0, Color("#8B5CF6"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r16.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r1", Vector2(236.0, 221.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(270.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r2", Vector2(408.0, 223.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(105.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r3", Vector2(568.0, 222.0), 56.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r4", Vector2(247.0, 327.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(180.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r5", Vector2(538.0, 325.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(45.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r6", Vector2(741.0, 251.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(270.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r7", Vector2(236.0, 433.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(155.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r8", Vector2(401.0, 399.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(75.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r9", Vector2(549.0, 426.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(270.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r10", Vector2(730.0, 357.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r11", Vector2(236.0, 539.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(160.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r12", Vector2(392.0, 493.0), 56.0, 20.0, Color("#22C55E"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r13", Vector2(549.0, 532.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(90.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r14", Vector2(772.0, 463.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r15", Vector2(225.0, 645.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r17", Vector2(741.0, 587.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(180.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r18", Vector2(225.0, 740.0), 56.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r19", Vector2(390.0, 692.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(75.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r20", Vector2(568.0, 645.0), 56.0, 20.0, Color("#22C55E"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r21", Vector2(579.0, 730.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(50.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r22", Vector2(730.0, 682.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r16)
			def.links = [
				LinkDefinitionScript.new(&"link_r1_r2", &"r1", &"r2", Color("#F97316"), 90.0, 102.0),
				LinkDefinitionScript.new(&"link_r1_r4", &"r1", &"r4", Color("#F97316"), 180.0, 36.6),
				LinkDefinitionScript.new(&"link_r2_r5", &"r2", &"r5", Color("#3B82F6"), 90.0, 95.2),
				LinkDefinitionScript.new(&"link_r3_r5", &"r3", &"r5", Color("#FF3B30"), 180.0, 44.3),
				LinkDefinitionScript.new(&"link_r4_r7", &"r4", &"r7", Color("#22C55E"), 180.0, 36.6),
				LinkDefinitionScript.new(&"link_r5_r6", &"r5", &"r6", Color("#8B5CF6"), 90.0, 146.1),
				LinkDefinitionScript.new(&"link_r5_r8", &"r5", &"r8", Color("#8B5CF6"), 270.0, 85.7),
				LinkDefinitionScript.new(&"link_r6_r10", &"r6", &"r10", Color("#22C55E"), 180.0, 36.6),
				LinkDefinitionScript.new(&"link_r7_r8", &"r7", &"r8", Color("#22C55E"), 90.0, 98.5),
				LinkDefinitionScript.new(&"link_r7_r11", &"r7", &"r11", Color("#22C55E"), 180.0, 36.0),
				LinkDefinitionScript.new(&"link_r8_r9", &"r8", &"r9", Color("#FF3B30"), 90.0, 80.4),
				LinkDefinitionScript.new(&"link_r9_r13", &"r9", &"r13", Color("#06B6D4"), 180.0, 36.0),
				LinkDefinitionScript.new(&"link_r10_r14", &"r10", &"r14", Color("#F97316"), 180.0, 44.0),
				LinkDefinitionScript.new(&"link_r11_r15", &"r11", &"r15", Color("#F97316"), 180.0, 36.6),
				LinkDefinitionScript.new(&"link_r14_r17", &"r14", &"r17", Color("#06B6D4"), 180.0, 57.8),
				LinkDefinitionScript.new(&"link_r15_r18", &"r15", &"r18", Color("#22C55E"), 180.0, 32.0),
				LinkDefinitionScript.new(&"link_r16_r19", &"r16", &"r19", Color("#8B5CF6"), 180.0, 15.6),
				LinkDefinitionScript.new(&"link_r17_r22", &"r17", &"r22", Color("#06B6D4"), 180.0, 25.6),
				LinkDefinitionScript.new(&"link_r19_r21", &"r19", &"r21", Color("#22C55E"), 115.0, 122.8),
				LinkDefinitionScript.new(&"link_r20_r21", &"r20", &"r21", Color("#22C55E"), 245.0, 22.7),
				LinkDefinitionScript.new(&"link_r21_r22", &"r21", &"r22", Color("#22C55E"), 90.0, 88.4),
			]
			return def
		93:
			var def := LevelDefinitionScript.new()
			def.level_id = 93
			def.title = "Level 93"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r5 := PieceDefinitionScript.new(&"r5", Vector2(500.0, 387.0), 110.0, 22.0, Color("#22C55E"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r5.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r1", Vector2(289.0, 279.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(219.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r2", Vector2(498.0, 279.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(245.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r3", Vector2(689.0, 279.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r4", Vector2(313.0, 403.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(115.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r6", Vector2(685.0, 422.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r7", Vector2(396.0, 494.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(90.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r8", Vector2(581.0, 471.0), 80.0, 20.0, Color("#8B5CF6"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r9", Vector2(686.0, 516.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r10", Vector2(269.0, 587.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(105.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r11", Vector2(500.0, 586.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r12", Vector2(686.0, 587.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r13", Vector2(362.0, 664.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(137.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r14", Vector2(637.0, 663.0), 56.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(45.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r5)
			def.links = [
				LinkDefinitionScript.new(&"link_r1_r4", &"r1", &"r4", Color("#22C55E"), 138.0, 56.3),
				LinkDefinitionScript.new(&"link_r1_r2", &"r1", &"r2", Color("#22C55E"), 90.0, 139.0),
				LinkDefinitionScript.new(&"link_r2_r3", &"r2", &"r3", Color("#F97316"), 90.0, 121.0),
				LinkDefinitionScript.new(&"link_r3_r6", &"r3", &"r6", Color("#3B82F6"), 228.0, 73.1),
				LinkDefinitionScript.new(&"link_r4_r7", &"r4", &"r7", Color("#06B6D4"), 138.0, 53.2),
				LinkDefinitionScript.new(&"link_r5_r7", &"r5", &"r7", Color("#22C55E"), 225.0, 59.2),
				LinkDefinitionScript.new(&"link_r6_r9", &"r6", &"r9", Color("#F97316"), 180.0, 24.0),
				LinkDefinitionScript.new(&"link_r7_r10", &"r7", &"r10", Color("#F97316"), 221.0, 87.4),
				LinkDefinitionScript.new(&"link_r7_r11", &"r7", &"r11", Color("#F97316"), 139.0, 68.9),
				LinkDefinitionScript.new(&"link_r8_r9", &"r8", &"r9", Color("#8B5CF6"), 91.0, 39.2),
				LinkDefinitionScript.new(&"link_r9_r12", &"r9", &"r12", Color("#06B6D4"), 180.0, 4.0),
				LinkDefinitionScript.new(&"link_r10_r13", &"r10", &"r13", Color("#FF3B30"), 139.0, 50.7),
				LinkDefinitionScript.new(&"link_r11_r13", &"r11", &"r13", Color("#06B6D4"), 180.0, 88.5),
				LinkDefinitionScript.new(&"link_r11_r12", &"r11", &"r12", Color("#06B6D4"), 90.0, 116.0),
				LinkDefinitionScript.new(&"link_r12_r14", &"r12", &"r14", Color("#FF3B30"), 220.0, 27.4),
			]
			return def
		94:
			var def := LevelDefinitionScript.new()
			def.level_id = 94
			def.title = "Level 94"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r20 := PieceDefinitionScript.new(&"r20", Vector2(420.0, 620.0), 110.0, 22.0, Color("#3B82F6"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r20.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r13", Vector2(200.0, 470.0), 56.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r14", Vector2(230.0, 560.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(120.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r15", Vector2(200.0, 510.0), 80.0, 20.0, Color("#8B5CF6"), 180.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r16", Vector2(280.0, 620.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r17", Vector2(250.0, 590.0), 80.0, 20.0, Color("#22C55E"), 135.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r18", Vector2(320.0, 530.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(190.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r19", Vector2(300.0, 560.0), 80.0, 20.0, Color("#22C55E"), 225.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r21", Vector2(360.0, 530.0), 80.0, 20.0, Color("#3B82F6"), 90.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r22", Vector2(480.0, 540.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r23", Vector2(420.0, 580.0), 80.0, 20.0, Color("#22C55E"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r24", Vector2(540.0, 620.0), 56.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(90.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r25", Vector2(460.0, 620.0), 80.0, 20.0, Color("#06B6D4"), 90.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r26", Vector2(450.0, 540.0), 80.0, 20.0, Color("#8B5CF6"), 270.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r27", Vector2(320.0, 500.0), 80.0, 20.0, Color("#06B6D4"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r28", Vector2(420.0, 720.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r29", Vector2(420.0, 660.0), 80.0, 20.0, Color("#F97316"), 180.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r30", Vector2(280.0, 700.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r31", Vector2(240.0, 700.0), 80.0, 20.0, Color("#3B82F6"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r32", Vector2(240.0, 740.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(90.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r33", Vector2(320.0, 780.0), 80.0, 20.0, Color("#F97316"), 180.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r34", Vector2(320.0, 750.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(155.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r35", Vector2(370.0, 720.0), 80.0, 20.0, Color("#8B5CF6"), 270.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r36", Vector2(420.0, 800.0), 56.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r37", Vector2(420.0, 760.0), 80.0, 20.0, Color("#22C55E"), 225.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r38", Vector2(480.0, 800.0), 56.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(270.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r39", Vector2(280.0, 740.0), 80.0, 20.0, Color("#FF3B30"), 180.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r20)
			def.links = [
				LinkDefinitionScript.new(&"link_r15_r13", &"r15", &"r13", Color("#8B5CF6"), 180.0, 4.0),
				LinkDefinitionScript.new(&"link_r17_r14", &"r17", &"r14", Color("#22C55E"), 135.0, 4.0),
				LinkDefinitionScript.new(&"link_r19_r18", &"r19", &"r18", Color("#22C55E"), 225.0, 4.0),
				LinkDefinitionScript.new(&"link_r21_r18", &"r21", &"r18", Color("#3B82F6"), 90.0, 4.0),
				LinkDefinitionScript.new(&"link_r26_r22", &"r26", &"r22", Color("#8B5CF6"), 270.0, 4.0),
				LinkDefinitionScript.new(&"link_r31_r32", &"r31", &"r32", Color("#3B82F6"), 0.0, 4.0),
				LinkDefinitionScript.new(&"link_r33_r34", &"r33", &"r34", Color("#F97316"), 180.0, 4.0),
				LinkDefinitionScript.new(&"link_r35_r28", &"r35", &"r28", Color("#8B5CF6"), 270.0, 4.0),
				LinkDefinitionScript.new(&"link_r37_r28", &"r37", &"r28", Color("#22C55E"), 225.0, 4.0),
				LinkDefinitionScript.new(&"link_r39_r30", &"r39", &"r30", Color("#FF3B30"), 180.0, 4.0),
			]
			return def
		95:
			var def := LevelDefinitionScript.new()
			def.level_id = 95
			def.title = "Level 95"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r14 := PieceDefinitionScript.new(&"r14", Vector2(320.0, 600.0), 110.0, 22.0, Color("#22C55E"), 180.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r14.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r1", Vector2(150.0, 260.0), 56.0, 20.0, Color("#FF3B30"), 270.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r2", Vector2(300.0, 260.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(245.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r3", Vector2(450.0, 260.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(245.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r4", Vector2(620.0, 260.0), 56.0, 20.0, Color("#22C55E"), 90.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r5", Vector2(360.0, 350.0), 80.0, 20.0, Color("#3B82F6"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r6", Vector2(220.0, 380.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(10.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r7", Vector2(520.0, 380.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r8", Vector2(220.0, 500.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r9", Vector2(320.0, 480.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(155.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r10", Vector2(380.0, 470.0), 80.0, 20.0, Color("#F97316"), 315.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r11", Vector2(450.0, 500.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(270.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r12", Vector2(560.0, 500.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r13", Vector2(260.0, 640.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(30.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r15", Vector2(440.0, 640.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(195.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r16", Vector2(560.0, 640.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r17", Vector2(220.0, 770.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(180.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r18", Vector2(340.0, 770.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r19", Vector2(490.0, 770.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(5.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r14)
			def.links = [
				LinkDefinitionScript.new(&"link_r2_r3", &"r2", &"r3", Color("#FF3B30"), 90.0, 80.0),
				LinkDefinitionScript.new(&"link_r2_r6", &"r2", &"r6", Color("#FF3B30"), 225.0, 74.2),
				LinkDefinitionScript.new(&"link_r3_r7", &"r3", &"r7", Color("#F97316"), 135.0, 68.9),
				LinkDefinitionScript.new(&"link_r6_r8", &"r6", &"r8", Color("#8B5CF6"), 180.0, 50.0),
				LinkDefinitionScript.new(&"link_r7_r12", &"r7", &"r12", Color("#22C55E"), 135.0, 56.5),
				LinkDefinitionScript.new(&"link_r11_r12", &"r11", &"r12", Color("#8B5CF6"), 90.0, 40.0),
				LinkDefinitionScript.new(&"link_r8_r13", &"r8", &"r13", Color("#F97316"), 135.0, 75.6),
				LinkDefinitionScript.new(&"link_r11_r15", &"r11", &"r15", Color("#8B5CF6"), 180.0, 70.4),
				LinkDefinitionScript.new(&"link_r15_r16", &"r15", &"r16", Color("#FF3B30"), 90.0, 50.0),
				LinkDefinitionScript.new(&"link_r12_r16", &"r12", &"r16", Color("#22C55E"), 180.0, 70.0),
				LinkDefinitionScript.new(&"link_r13_r17", &"r13", &"r17", Color("#FF3B30"), 225.0, 66.0),
				LinkDefinitionScript.new(&"link_r17_r18", &"r17", &"r18", Color("#F97316"), 90.0, 50.0),
				LinkDefinitionScript.new(&"link_r14_r18", &"r14", &"r18", Color("#22C55E"), 180.0, 81.2),
				LinkDefinitionScript.new(&"link_r18_r19", &"r18", &"r19", Color("#06B6D4"), 90.0, 80.0),
				LinkDefinitionScript.new(&"link_r15_r18", &"r15", &"r18", Color("#FF3B30"), 225.0, 94.0),
				LinkDefinitionScript.new(&"link_r15_r19", &"r15", &"r19", Color("#FF3B30"), 135.0, 69.3),
				LinkDefinitionScript.new(&"link_r16_r19", &"r16", &"r19", Color("#06B6D4"), 225.0, 77.6),
			]
			return def
		96:
			var def := LevelDefinitionScript.new()
			def.level_id = 96
			def.title = "Level 96"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r29 := PieceDefinitionScript.new(&"r29", Vector2(450.0, 720.0), 110.0, 22.0, Color("#F97316"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r29.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r7", Vector2(290.0, 460.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r8", Vector2(340.0, 390.0), 56.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(50.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r9", Vector2(410.0, 370.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(230.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r10", Vector2(480.0, 430.0), 56.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(90.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r11", Vector2(400.0, 440.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r12", Vector2(310.0, 520.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(25.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r13", Vector2(310.0, 590.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(225.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r14", Vector2(530.0, 560.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(45.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r15", Vector2(440.0, 540.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r16", Vector2(380.0, 580.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(235.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r17", Vector2(380.0, 650.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(5.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r18", Vector2(310.0, 660.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(225.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r19", Vector2(480.0, 610.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(170.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r20", Vector2(380.0, 720.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(135.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r21", Vector2(310.0, 730.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(110.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r22", Vector2(360.0, 780.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(30.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r23", Vector2(480.0, 760.0), 56.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(90.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r24", Vector2(200.0, 420.0), 56.0, 20.0, Color("#F97316"), 90.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r25", Vector2(230.0, 560.0), 56.0, 20.0, Color("#22C55E"), 90.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r26", Vector2(530.0, 480.0), 56.0, 20.0, Color("#8B5CF6"), 180.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r27", Vector2(230.0, 650.0), 56.0, 20.0, Color("#22C55E"), 90.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r28", Vector2(550.0, 610.0), 56.0, 20.0, Color("#22C55E"), 270.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r29)
			def.links = [
				LinkDefinitionScript.new(&"link_r24_r7", &"r24", &"r7", Color("#F97316"), 90.0, 35.5),
				LinkDefinitionScript.new(&"link_r7_r12", &"r7", &"r12", Color("#22C55E"), 135.0, 4.0),
				LinkDefinitionScript.new(&"link_r8_r9", &"r8", &"r9", Color("#8B5CF6"), 90.0, 9.8),
				LinkDefinitionScript.new(&"link_r9_r10", &"r9", &"r10", Color("#06B6D4"), 135.0, 29.2),
				LinkDefinitionScript.new(&"link_r9_r11", &"r9", &"r11", Color("#06B6D4"), 180.0, 4.0),
				LinkDefinitionScript.new(&"link_r12_r11", &"r12", &"r11", Color("#06B6D4"), 45.0, 50.4),
				LinkDefinitionScript.new(&"link_r12_r13", &"r12", &"r13", Color("#06B6D4"), 180.0, 4.0),
				LinkDefinitionScript.new(&"link_r25_r13", &"r25", &"r13", Color("#22C55E"), 90.0, 22.4),
				LinkDefinitionScript.new(&"link_r13_r16", &"r13", &"r16", Color("#3B82F6"), 90.0, 4.0),
				LinkDefinitionScript.new(&"link_r13_r18", &"r13", &"r18", Color("#3B82F6"), 180.0, 4.0),
				LinkDefinitionScript.new(&"link_r11_r15", &"r11", &"r15", Color("#F97316"), 135.0, 37.7),
				LinkDefinitionScript.new(&"link_r26_r14", &"r26", &"r14", Color("#8B5CF6"), 180.0, 17.0),
				LinkDefinitionScript.new(&"link_r15_r14", &"r15", &"r14", Color("#F97316"), 90.0, 22.2),
				LinkDefinitionScript.new(&"link_r16_r15", &"r16", &"r15", Color("#8B5CF6"), 45.0, 4.0),
				LinkDefinitionScript.new(&"link_r16_r17", &"r16", &"r17", Color("#8B5CF6"), 180.0, 4.0),
				LinkDefinitionScript.new(&"link_r15_r17", &"r15", &"r17", Color("#F97316"), 225.0, 55.3),
				LinkDefinitionScript.new(&"link_r27_r18", &"r27", &"r18", Color("#22C55E"), 90.0, 17.6),
				LinkDefinitionScript.new(&"link_r18_r17", &"r18", &"r17", Color("#06B6D4"), 90.0, 4.0),
				LinkDefinitionScript.new(&"link_r15_r19", &"r15", &"r19", Color("#F97316"), 135.0, 10.6),
				LinkDefinitionScript.new(&"link_r28_r19", &"r28", &"r19", Color("#22C55E"), 270.0, 7.0),
				LinkDefinitionScript.new(&"link_r18_r21", &"r18", &"r21", Color("#06B6D4"), 180.0, 4.0),
				LinkDefinitionScript.new(&"link_r17_r20", &"r17", &"r20", Color("#22C55E"), 180.0, 4.0),
				LinkDefinitionScript.new(&"link_r21_r20", &"r21", &"r20", Color("#22C55E"), 90.0, 4.0),
				LinkDefinitionScript.new(&"link_r21_r22", &"r21", &"r22", Color("#22C55E"), 135.0, 4.0),
				LinkDefinitionScript.new(&"link_r20_r22", &"r20", &"r22", Color("#06B6D4"), 225.0, 4.0),
				LinkDefinitionScript.new(&"link_r29_r19", &"r29", &"r19", Color("#F97316"), 0.0, 24.0),
				LinkDefinitionScript.new(&"link_r29_r20", &"r29", &"r20", Color("#F97316"), 270.0, 4.0),
				LinkDefinitionScript.new(&"link_r29_r23", &"r29", &"r23", Color("#F97316"), 90.0, 4.0),
				LinkDefinitionScript.new(&"link_r29_r22", &"r29", &"r22", Color("#F97316"), 225.0, 18.2),
			]
			return def
		97:
			var def := LevelDefinitionScript.new()
			def.level_id = 97
			def.title = "Level 97"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r8 := PieceDefinitionScript.new(&"r8", Vector2(290.0, 428.0), 110.0, 22.0, Color("#FF3B30"), 360.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r8.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r9", Vector2(380.0, 368.0), 56.0, 20.0, Color("#22C55E"), 360.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r10", Vector2(491.0, 403.0), 70.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(253.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r11", Vector2(466.0, 490.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r14", Vector2(480.0, 624.0), 56.0, 20.0, Color("#8B5CF6"), 360.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r8)
			def.links = [
				LinkDefinitionScript.new(&"link_r8_r10", &"r8", &"r10", Color("#FF3B30"), 180.0, 112.5),
				LinkDefinitionScript.new(&"link_r10_r11", &"r10", &"r11", Color("#06B6D4"), 120.0, 20.5),
			]
			return def
		98:
			var def := LevelDefinitionScript.new()
			def.level_id = 98
			def.title = "Level 98"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r16 := PieceDefinitionScript.new(&"r16", Vector2(300.0, 1000.0), 110.0, 22.0, Color("#22C55E"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r16.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r4", Vector2(500.0, 250.0), 56.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r5", Vector2(500.0, 400.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(155.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r6", Vector2(650.0, 325.0), 56.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(90.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r9", Vector2(500.0, 550.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(155.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r10", Vector2(650.0, 550.0), 56.0, 20.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(90.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r11", Vector2(200.0, 700.0), 56.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r12", Vector2(200.0, 850.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(120.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r14", Vector2(500.0, 700.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(165.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r15", Vector2(650.0, 700.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r17", Vector2(600.0, 1000.0), 56.0, 20.0, Color("#22C55E"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r18", Vector2(450.0, 1000.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r19", Vector2(650.0, 850.0), 56.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(90.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r22", Vector2(500.0, 625.0), 80.0, 20.0, Color("#FF3B30"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r16)
			def.links = [
				LinkDefinitionScript.new(&"link_r4_r5", &"r4", &"r5", Color("#3B82F6"), 180.0, 87.0),
				LinkDefinitionScript.new(&"link_r5_r6", &"r5", &"r6", Color("#8B5CF6"), 90.0, 104.7),
				LinkDefinitionScript.new(&"link_r5_r9", &"r5", &"r9", Color("#8B5CF6"), 180.0, 80.0),
				LinkDefinitionScript.new(&"link_r9_r10", &"r9", &"r10", Color("#22C55E"), 90.0, 87.0),
				LinkDefinitionScript.new(&"link_r11_r12", &"r11", &"r12", Color("#F97316"), 180.0, 87.0),
				LinkDefinitionScript.new(&"link_r14_r15", &"r14", &"r15", Color("#3B82F6"), 90.0, 80.0),
				LinkDefinitionScript.new(&"link_r14_r18", &"r14", &"r18", Color("#3B82F6"), 180.0, 234.1),
				LinkDefinitionScript.new(&"link_r19_r15", &"r19", &"r15", Color("#8B5CF6"), 0.0, 87.0),
				LinkDefinitionScript.new(&"link_r16_r18", &"r16", &"r18", Color("#22C55E"), 90.0, 60.0),
				LinkDefinitionScript.new(&"link_r17_r18", &"r17", &"r18", Color("#22C55E"), 270.0, 87.0),
				LinkDefinitionScript.new(&"link_r22_r9", &"r22", &"r9", Color("#FF3B30"), 0.0, 4.0),
				LinkDefinitionScript.new(&"link_r22_r14", &"r22", &"r14", Color("#FF3B30"), 180.0, 4.0),
			]
			return def
		99:
			var def := LevelDefinitionScript.new()
			def.level_id = 99
			def.title = "Level 99"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r13 := PieceDefinitionScript.new(&"r13", Vector2(270.0, 860.0), 110.0, 22.0, Color("#8B5CF6"), 0.0, [], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r13.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r1", Vector2(180.0, 260.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(155.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r2", Vector2(270.0, 200.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(65.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r3", Vector2(450.0, 200.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(100.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r4", Vector2(540.0, 260.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(315.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r5", Vector2(180.0, 440.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(45.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r6", Vector2(360.0, 360.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(220.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r7", Vector2(540.0, 420.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r8", Vector2(360.0, 450.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r9", Vector2(360.0, 550.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r10", Vector2(180.0, 680.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(70.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r11", Vector2(540.0, 680.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r12", Vector2(360.0, 700.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(335.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r14", Vector2(450.0, 860.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(135.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r13)
			def.links = [
				LinkDefinitionScript.new(&"link_r1_r2", &"r1", &"r2", Color("#FF3B30"), 90.0, 38.2),
				LinkDefinitionScript.new(&"link_r1_r5", &"r1", &"r5", Color("#FF3B30"), 180.0, 110.0),
				LinkDefinitionScript.new(&"link_r2_r3", &"r2", &"r3", Color("#F97316"), 90.0, 110.0),
				LinkDefinitionScript.new(&"link_r3_r4", &"r3", &"r4", Color("#3B82F6"), 90.0, 38.2),
				LinkDefinitionScript.new(&"link_r4_r7", &"r4", &"r7", Color("#8B5CF6"), 180.0, 90.0),
				LinkDefinitionScript.new(&"link_r5_r6", &"r5", &"r6", Color("#22C55E"), 45.0, 127.0),
				LinkDefinitionScript.new(&"link_r5_r6", &"r5", &"r6", Color("#22C55E"), 90.0, 127.0),
				LinkDefinitionScript.new(&"link_r6_r7", &"r6", &"r7", Color("#3B82F6"), 45.0, 119.7),
				LinkDefinitionScript.new(&"link_r6_r8", &"r6", &"r8", Color("#3B82F6"), 180.0, 20.0),
				LinkDefinitionScript.new(&"link_r7_r11", &"r7", &"r11", Color("#22C55E"), 180.0, 190.0),
				LinkDefinitionScript.new(&"link_r8_r9", &"r8", &"r9", Color("#F97316"), 180.0, 30.0),
				LinkDefinitionScript.new(&"link_r9_r10", &"r9", &"r10", Color("#22C55E"), 225.0, 152.0),
				LinkDefinitionScript.new(&"link_r9_r11", &"r9", &"r11", Color("#22C55E"), 135.0, 152.0),
				LinkDefinitionScript.new(&"link_r9_r12", &"r9", &"r12", Color("#22C55E"), 180.0, 80.0),
				LinkDefinitionScript.new(&"link_r10_r12", &"r10", &"r12", Color("#FF3B30"), 90.0, 111.1),
				LinkDefinitionScript.new(&"link_r11_r14", &"r11", &"r14", Color("#3B82F6"), 225.0, 131.2),
				LinkDefinitionScript.new(&"link_r12_r14", &"r12", &"r14", Color("#3B82F6"), 135.0, 113.6),
			]
			return def
		100:
			var def := LevelDefinitionScript.new()
			def.level_id = 100
			def.title = "Level 100"
			def.instruction = "Rotate rings to align gaps. Clear all rings to win."
			var __hub_r1 := PieceDefinitionScript.new(&"r1", Vector2(358.0, 461.0), 110.0, 22.0, Color("#06B6D4"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE)
			__hub_r1.role = PieceDefinitionScript.PieceRole.HUB
			def.pieces = [
				PieceDefinitionScript.new(&"r2", Vector2(343.0, 577.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(105.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r3", Vector2(215.0, 367.0), 70.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(100.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r4", Vector2(344.0, 319.0), 70.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(225.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r5", Vector2(487.0, 279.0), 70.0, 20.0, Color("#F97316"), 0.0, [GapDefinitionScript.new(230.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r6", Vector2(631.0, 321.0), 70.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(85.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r7", Vector2(764.0, 371.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(270.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r8", Vector2(222.0, 559.0), 56.0, 20.0, Color("#FF3B30"), 0.0, [GapDefinitionScript.new(90.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r9", Vector2(488.0, 588.0), 56.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r10", Vector2(483.0, 638.0), 70.0, 20.0, Color("#3B82F6"), 0.0, [GapDefinitionScript.new(45.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r11", Vector2(669.0, 566.0), 56.0, 20.0, Color("#22C55E"), 0.0, [GapDefinitionScript.new(270.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
				PieceDefinitionScript.new(&"r12", Vector2(491.0, 692.0), 56.0, 20.0, Color("#8B5CF6"), 0.0, [GapDefinitionScript.new(0.0, 110.0, 16.0)], 0.0, PieceDefinitionScript.ShapeType.CIRCLE),
			]
			def.pieces.append(__hub_r1)
			def.links = [
				LinkDefinitionScript.new(&"link_r1_r2", &"r1", &"r2", Color("#06B6D4"), 180.0, 27.0),
				LinkDefinitionScript.new(&"link_r1_r3", &"r1", &"r3", Color("#06B6D4"), 315.0, 81.1),
				LinkDefinitionScript.new(&"link_r1_r4", &"r1", &"r4", Color("#06B6D4"), 345.0, 52.7),
				LinkDefinitionScript.new(&"link_r1_r5", &"r1", &"r5", Color("#06B6D4"), 15.0, 133.1),
				LinkDefinitionScript.new(&"link_r1_r6", &"r1", &"r6", Color("#06B6D4"), 45.0, 216.8),
				LinkDefinitionScript.new(&"link_r1_r7", &"r1", &"r7", Color("#06B6D4"), 75.0, 325.9),
				LinkDefinitionScript.new(&"link_r3_r4", &"r3", &"r4", Color("#22C55E"), 45.0, 67.6),
				LinkDefinitionScript.new(&"link_r4_r5", &"r4", &"r5", Color("#FF3B30"), 45.0, 78.5),
				LinkDefinitionScript.new(&"link_r5_r6", &"r5", &"r6", Color("#F97316"), 135.0, 80.0),
				LinkDefinitionScript.new(&"link_r6_r7", &"r6", &"r7", Color("#8B5CF6"), 135.0, 72.1),
				LinkDefinitionScript.new(&"link_r8_r2", &"r8", &"r2", Color("#FF3B30"), 225.0, 59.3),
				LinkDefinitionScript.new(&"link_r9_r10", &"r9", &"r10", Color("#22C55E"), 180.0, 4.0),
				LinkDefinitionScript.new(&"link_r10_r2", &"r10", &"r2", Color("#3B82F6"), 225.0, 82.7),
				LinkDefinitionScript.new(&"link_r10_r11", &"r10", &"r11", Color("#3B82F6"), 45.0, 136.4),
				LinkDefinitionScript.new(&"link_r12_r2", &"r12", &"r2", Color("#8B5CF6"), 0.0, 124.4),
			]
			return def
		_:
			return null
