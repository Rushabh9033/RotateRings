import easyocr
import glob
import os
import json
import re
import cv2

folder = r"D:\AI secound Brain\RotateRings\ALL 2to100 levels"
files = [f for f in glob.glob(os.path.join(folder, "*")) if f.endswith('.jpeg') or f.endswith('.jpg') or f.endswith('.png')]

print(f"Total files: {len(files)}")
reader = easyocr.Reader(['en'], gpu=False)

exact_map = {}

# 1. First add explicitly numbered files like 2.jpeg, 3.jpeg
for f in files:
    base = os.path.basename(f)
    name_without_ext = os.path.splitext(base)[0]
    if name_without_ext.isdigit():
        lvl = int(name_without_ext)
        exact_map[lvl] = f

# 2. OCR cropped top-left of WhatsApp images
for f in files:
    base = os.path.basename(f)
    if base.startswith("WhatsApp"):
        img = cv2.imread(f)
        if img is None: continue
        h, w, _ = img.shape
        crop = img[0:int(h*0.15), 0:int(w*0.4)]
        res = reader.readtext(crop)
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
