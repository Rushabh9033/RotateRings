extends SceneTree

# Smoke test: load the gameplay screen, verify EditBtn + PieceEditOverlay are
# present in the rendered tree.
func _init() -> void:
	var screen_scene = load("res://scenes/gameplay/GameplayScreen.tscn")
	if screen_scene == null:
		print("FAIL: cannot load GameplayScreen.tscn")
		quit(1); return
	var screen = screen_scene.instantiate()
	root.add_child(screen)
	if not screen.is_node_ready():
		await screen.ready
	var hud = screen.get_node_or_null("SafeArea/TopHUD")
	var edit_btn = screen.get_node_or_null("SafeArea/TopHUD/EditBtn")
	var overlay = screen.get_node_or_null("PuzzleArea/PieceEditOverlay")
	var overlay_script = overlay.get_script() if overlay else null
	print("HUD exists: ", hud != null)
	print("EditBtn node path: ", "SafeArea/TopHUD/EditBtn")
	print("EditBtn exists: ", edit_btn != null)
	if edit_btn:
		print("  EditBtn text: ", edit_btn.text)
		print("  EditBtn visible initially: ", edit_btn.visible)
	print("Overlay exists: ", overlay != null)
	print("Overlay has script: ", overlay_script != null)
	if overlay_script:
		print("Overlay class: ", overlay_script.resource_path)
	quit(0)
