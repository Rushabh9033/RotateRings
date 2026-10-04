extends Resource
class_name LevelDefinition

@export var level_id: int = 1
@export var chapter_id: int = 1
@export var title: String = "Level 1"
@export var instruction: String = ""

@export var pieces: Array = []
@export var links: Array = []

@export var par_moves: int = 1
@export var canonical_steps: Array = []

@export var theme_id: StringName = &"porcelain"
