import easyocr
import glob
import os
import json
import re

folder = r"D:\AI secound Brain\RotateRings\ALL 2to100 levels"
images = glob.glob(os.path.join(folder, "*.jpeg")) + glob.glob(os.path.join(folder, "*.jpg")) + glob.glob(os.path.join(folder, "*.png"))

print(f"Total images found: {len(images)}")

reader = easyocr.Reader(['en'], gpu=False)

level_map = {}

for img_path in images:
    filename = os.path.basename(img_path)
    res = reader.readtext(img_path)
    text = " ".join([r[1] for r in res])
    
    # Match "Level XX" or "Level\nXX" or "Level 2", etc.
    match = re.search(r'Level\s*(\d+)', text, re.IGNORECASE)
    if not match:
        # Search for standalone numbers near Level
        lines = [r[1].strip() for r in res]
        for i, line in enumerate(lines):
            if "level" in line.lower():
                # check next 1 or 2 items
                for j in range(i+1, min(i+3, len(lines))):
                    if lines[j].isdigit():
                        level_num = int(lines[j])
                        level_map[level_num] = img_path
                        break
    else:
        level_num = int(match.group(1))
        level_map[level_num] = img_path

print(f"Mapped {len(level_map)} levels out of {len(images)}.")
with open("tools/level_map.json", "w") as f:
    json.dump(level_map, f, indent=2)

for lvl in sorted(level_map.keys())[:15]:
    print(f"Level {lvl}: {level_map[lvl]}")
