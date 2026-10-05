with open("D:/AI secound Brain/RotateRings/data/level_database.gd", "r", encoding="utf-8") as f:
    text = f.read()

text = text.replace(
    'static func get_total_levels() -> int:\n\treturn 50',
    'static func get_total_levels() -> int:\n\treturn 12'
)

with open("D:/AI secound Brain/RotateRings/data/level_database.gd", "w", encoding="utf-8") as f:
    f.write(text)
