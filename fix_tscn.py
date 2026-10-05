import re

with open('D:/AI secound Brain/RotateRings/scenes/level_select/LevelSelectScreen.tscn', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('parent=\"SafeArea\"', 'parent=\"SafeArea/VBox\"')
text = text.replace('[node name=\"Header\"', '[node name=\"VBox\" type=\"VBoxContainer\" parent=\"SafeArea\"]\nlayout_mode = 2\n\n[node name=\"Header\"')

with open('D:/AI secound Brain/RotateRings/scenes/level_select/LevelSelectScreen.tscn', 'w', encoding='utf-8') as f:
    f.write(text)
