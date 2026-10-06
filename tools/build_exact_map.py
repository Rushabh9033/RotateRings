import easyocr
import glob
import os
import json
import re

folder = r"D:\AI secound Brain\RotateRings\ALL 2to100 levels"
files = [f for f in glob.glob(os.path.join(folder, "*")) if f.endswith('.jpeg') or f.endswith('.jpg') or f.endswith('.png')]

print(f"Total files: {len(files)}")
reader = easyocr.Reader(['en'], gpu=False)

exact_map = {}

# First check numbered files like 2.jpeg, 3.jpeg
for f in files:
    base = os.path.basename(f)
    name_without_ext = os.path.splitext(base)[0]
    if name_without_ext.isdigit():
        lvl = int(name_without_ext)
        exact_map[lvl] = f

# Next OCR remaining files
for f in files:
    base = os.path.basename(f)
    if base.startswith("WhatsApp"):
        img = cv2.imread(f) if 'cv2' in globals() else None
        res = reader.readtext(f)
        text = " ".join([r[1] for r in res])
        nums = re.findall(r'\d+', text)
        if nums:
            lvl = int(nums[0])
            if 1 <= lvl <= 150 and lvl not in exact_map:
                exact_map[lvl] = f

print(f"Mapped {len(exact_map)} levels out of 100!")
with open("tools/exact_level_map.json", "w") as out:
    json.dump(exact_map, out, indent=2)

for k in sorted(exact_map.keys()):
    print(f"Level {k}: {os.path.basename(exact_map[k])}")
