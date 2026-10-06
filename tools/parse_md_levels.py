import re
import json

md_path = r"D:\AI secound Brain\RotateRings\ROTATE_RINGS_LEVELS_2_TO_100.md"
with open(md_path, "r", encoding="utf-8") as f:
    text = f.read()

# Find all json blocks
blocks = re.findall(r'```json\s*(\{.*?\})\s*```', text, re.DOTALL)

print(f"Found {len(blocks)} JSON level blocks in markdown file!")

levels_dict = {}
for block in blocks:
    try:
        data = json.loads(block)
        if "level_id" in data:
            levels_dict[int(data["level_id"])] = data
    except Exception as e:
        print("Error parsing block:", e)

print(f"Successfully loaded {len(levels_dict)} levels into dictionary!")

with open("data/json_levels.json", "w", encoding="utf-8") as out:
    json.dump(levels_dict, out, indent=2)

print("Saved to data/json_levels.json!")
