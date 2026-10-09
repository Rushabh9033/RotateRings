extends SceneTree

const LevelDatabaseScript = preload("res://data/level_database.gd")

func _initialize() -> void:
	var UserLevelsScript = preload("res://data/user_levels.gd")
	var from_user = UserLevelsScript.build(2)
	print("from_user_levels result type=", typeof(from_user))
	if from_user != null:
		print("from_user_levels is not null, size=", from_user.pieces.size())
		for p_def in from_user.pieces:
			print("  user id=", p_def.id, " pos=", p_def.position, " r=", p_def.radius)
	else:
		print("from_user_levels returned null")
	var def = LevelDatabaseScript.get_level(2)
	print("get_level(2).pieces.size=", def.pieces.size())
	for p_def in def.pieces:
		print("  get id=", p_def.id, " pos=", p_def.position, " r=", p_def.radius)
	quit(0)
