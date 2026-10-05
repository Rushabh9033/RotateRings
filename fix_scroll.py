with open("D:/AI secound Brain/RotateRings/scenes/level_select/LevelSelectScreen.gd", "r", encoding="utf-8") as f:
    text = f.read()

import re

scroll_logic = """	progress_lbl.text = "%d / %d Cleared" % [cleared_count, total_levels]
	
	# Scroll to the highest unlocked level
	var highest_unlocked = 1
	for lvl in range(total_levels, 0, -1):
		if save_service and save_service.has_method("is_level_unlocked") and save_service.is_level_unlocked(lvl):
			highest_unlocked = lvl
			break
			
	var target_y = map_height - (highest_unlocked * vertical_spacing) - 100.0
	var scroll_node = $SafeArea/VBox/Scroll
	# Center the target_y in the scroll container
	call_deferred("_scroll_to", scroll_node, target_y - (scroll_node.size.y / 2.0))

func _scroll_to(scroll_node: ScrollContainer, val: float) -> void:
	scroll_node.scroll_vertical = int(max(0, val))
"""

text = text.replace('	progress_lbl.text = "%d / %d Cleared" % [cleared_count, total_levels]', scroll_logic)

with open("D:/AI secound Brain/RotateRings/scenes/level_select/LevelSelectScreen.gd", "w", encoding="utf-8") as f:
    f.write(text)
