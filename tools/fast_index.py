import cv2
import glob
import os
import easyocr
import json
import re

folder = r"D:\AI secound Brain\RotateRings\ALL 2to100 levels"
images = glob.glob(os.path.join(folder, "*.jpeg")) + glob.glob(os.path.join(folder, "*.jpg")) + glob.glob(os.path.join(folder, "*.png"))

print(f"Total images found: {len(images)}")
reader = easyocr.Reader(['en'], gpu=False)

level_map = {}

for img_path in images:
    img = cv2.imread(img_path)
    if img is None: continue
    h, w, _ = img.shape
    # Crop top-left region where Level number is displayed
    crop = img[0:int(h*0.15), 0:int(w*0.4)]
    
    res = reader.readtext(crop)
    text = " ".join([r[1] for r in res])
    
    # Find digits in crop text
    nums = re.findall(r'\d+', text)
    if nums:
        lvl = int(nums[0])
        if 1 <= lvl <= 150:
            level_map[lvl] = img_path

print(f"Successfully mapped {len(level_map)} levels!")
with open("tools/level_map.json", "w") as f:
    json.dump(level_map, f, indent=2)
