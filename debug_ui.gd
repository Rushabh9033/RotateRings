extends SceneTree
func _init():
    var scene = preload("res://scenes/gameplay/GameplayScreen.tscn").instantiate()
    var top_hud = scene.get_node("SafeArea/TopHUD")
    var bottom_hud = scene.get_node("SafeArea/BottomHUD")
    print("Top HUD: size=", top_hud.size, " pos=", top_hud.position)
    print("Bottom HUD: size=", bottom_hud.size, " pos=", bottom_hud.position)
    quit()

