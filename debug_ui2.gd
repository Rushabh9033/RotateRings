extends Node
var frames = 0
var scene
func _ready():
    scene = preload("res://scenes/gameplay/GameplayScreen.tscn").instantiate()
    get_tree().root.add_child(scene)
func _process(delta):
    frames += 1
    if frames == 5:
        var top_hud = scene.get_node("SafeArea/TopHUD")
        var bottom_hud = scene.get_node("SafeArea/BottomHUD")
        print("REAL Top HUD: size=", top_hud.size, " pos=", top_hud.position)
        print("REAL Bottom HUD: size=", bottom_hud.size, " pos=", bottom_hud.position, " global_pos=", bottom_hud.global_position)
        get_tree().quit()

