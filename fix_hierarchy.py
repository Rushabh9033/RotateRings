with open("D:/AI secound Brain/RotateRings/scenes/level_select/LevelSelectScreen.tscn", "r", encoding="utf-8") as f:
    text = f.read()

text = text.replace('parent="SafeArea/Header"', 'parent="SafeArea/VBox/Header"')

with open("D:/AI secound Brain/RotateRings/scenes/level_select/LevelSelectScreen.tscn", "w", encoding="utf-8") as f:
    f.write(text)
