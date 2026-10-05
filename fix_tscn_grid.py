with open("D:/AI secound Brain/RotateRings/scenes/level_select/LevelSelectScreen.tscn", "r", encoding="utf-8") as f:
    text = f.read()

text = text.replace(
    '[node name="Grid" type="GridContainer" parent="SafeArea/VBox/Scroll"]\nlayout_mode = 2\nsize_flags_horizontal = 6\nsize_flags_vertical = 6\ntheme_override_constants/h_separation = 24\ntheme_override_constants/v_separation = 24\ncolumns = 3',
    '[node name="MapContainer" type="Control" parent="SafeArea/VBox/Scroll"]\nlayout_mode = 2\nsize_flags_horizontal = 3\nsize_flags_vertical = 3'
)
# Wait, parent was SafeArea/Scroll originally but I might have moved it to SafeArea/VBox/Scroll?
# Let's just use regex to replace the Grid node block
import re
text = re.sub(
    r'\[node name="Grid" type="GridContainer".*?columns = 3',
    '[node name="MapContainer" type="Control" parent="SafeArea/VBox/Scroll"]\nlayout_mode = 2\nsize_flags_horizontal = 3\nsize_flags_vertical = 3',
    text,
    flags=re.DOTALL
)

with open("D:/AI secound Brain/RotateRings/scenes/level_select/LevelSelectScreen.tscn", "w", encoding="utf-8") as f:
    f.write(text)
