extends SceneTree
func _init():
    var v1 = Vector2.RIGHT.rotated(deg_to_rad(-150.0)) * 128.0
    var v2 = Vector2.RIGHT.rotated(deg_to_rad(-60.0)) * 114.0
    var v3 = Vector2.RIGHT.rotated(deg_to_rad(30.0)) * 116.0
    var total = v1 + v2 + v3
    print("v1: ", v1)
    print("v2: ", v2)
    print("v3: ", v3)
    print("total: ", total)
    quit()
