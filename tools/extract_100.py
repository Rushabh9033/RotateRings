import cv2
import numpy as np
import glob
import os
import easyocr
import json

folder = r"D:\AI secound Brain\RotateRings\ALL 2to100 levels"
images = glob.glob(os.path.join(folder, "*.jpeg"))

print(f"Found {len(images)} images to process.")
# We will just process the first 5 to see if we can get anything useful
reader = easyocr.Reader(['en'], gpu=False)

def extract_level(img_path):
    img = cv2.imread(img_path)
    if img is None: return None
    
    # Try to read level number
    text_results = reader.readtext(img_path)
    level_num = -1
    for i, res in enumerate(text_results):
        if "Level" in res[1] and i+1 < len(text_results):
            try:
                level_num = int(text_results[i+1][1])
            except:
                pass
            break
            
    # Convert to HSV to find colored rings
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    
    # We define some basic color bounds (very rough)
    # Red, Blue, Green, Yellow, Orange, Purple
    colors = {
        "red1": ([0, 100, 100], [10, 255, 255]),
        "red2": ([160, 100, 100], [180, 255, 255]),
        "green": ([40, 100, 100], [80, 255, 255]),
        "blue": ([100, 100, 100], [140, 255, 255]),
        "yellow": ([20, 100, 100], [40, 255, 255])
    }
    
    rings = []
    
    for cname, (lower, upper) in colors.items():
        lower = np.array(lower, dtype="uint8")
        upper = np.array(upper, dtype="uint8")
        mask = cv2.inRange(hsv, lower, upper)
        
        # Hough circles on the mask
        blurred = cv2.GaussianBlur(mask, (9, 9), 2)
        circles = cv2.HoughCircles(blurred, cv2.HOUGH_GRADIENT, dp=1.2, minDist=50,
                                   param1=50, param2=20, minRadius=30, maxRadius=150)
                                   
        if circles is not None:
            circles = np.uint16(np.around(circles))
            for c in circles[0, :]:
                rings.append({"color": cname, "x": int(c[0]), "y": int(c[1]), "r": int(c[2])})
                
    return {"file": os.path.basename(img_path), "level": level_num, "rings": rings}

for img in images[:5]:
    res = extract_level(img)
    print(json.dumps(res, indent=2))

