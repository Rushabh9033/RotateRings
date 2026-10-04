extends SceneTree

func _init():
	var validator = load("res://tools/level_validator.gd").new()
	var report = validator.run_audit()
	print("=== LEVEL VALIDATOR AUDIT ===")
	print("PASS: ", report["pass"].size())
	print("WARNING: ", report["warning"].size())
	print("FAIL: ", report["fail"].size())
	
	for fail in report["fail"]:
		print("---")
		print("LEVEL ", fail.id, ": ", fail.title)
		for issue in fail.issues:
			print("  [FAIL] ", issue)
			
	for warn in report["warning"]:
		print("---")
		print("LEVEL ", warn.id, ": ", warn.title)
		for issue in warn.issues:
			print("  [WARN] ", issue)
			
	print("=== END OF AUDIT ===")
	quit()
