with open("D:/AI secound Brain/RotateRings/scenes/level_select/LevelSelectScreen.gd", "r", encoding="utf-8") as f:
    text = f.read()

text = text.replace(
    '@onready var grid_container: GridContainer = $SafeArea/VBox/Scroll/Grid',
    '@onready var map_container: Control = $SafeArea/VBox/Scroll/MapContainer'
)

build_grid_old = """func build_grid() -> void:
	if not is_instance_valid(grid_container): return
	
	# Replace GridContainer with a generic Control for custom mapping
	var scroll = $SafeArea/VBox/Scroll
	var journey_map = Control.new()
	scroll.add_child(journey_map)
	grid_container.queue_free()"""

build_grid_new = """func build_grid() -> void:
	if not is_instance_valid(map_container): return
	
	for child in map_container.get_children():
		child.queue_free()
		
	var journey_map = map_container"""

text = text.replace(build_grid_old, build_grid_new)

with open("D:/AI secound Brain/RotateRings/scenes/level_select/LevelSelectScreen.gd", "w", encoding="utf-8") as f:
    f.write(text)
