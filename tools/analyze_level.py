import cv2
import numpy as np
import os
import glob
import json

folder = r"D:\AI secound Brain\RotateRings\ALL 2to100 levels"
images = glob.glob(os.path.join(folder, "*.png")) + glob.glob(os.path.join(folder, "*.jpg"))
if not images:
    print("No images found in", folder)
    exit()

img_path = images[0]
print("Analyzing:", img_path)

img = cv2.imread(img_path)
if img is None:
    print("Failed to load image")
    exit()

gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
# Apply blur to reduce noise
blurred = cv2.medianBlur(gray, 5)

# Detect circles
circles = cv2.HoughCircles(blurred, cv2.HOUGH_GRADIENT, dp=1, minDist=50,
                           param1=50, param2=30, minRadius=20, maxRadius=200)

detected = []
if circles is not None:
    circles = np.uint16(np.around(circles))
    for i in circles[0, :]:
        # i[0] = x, i[1] = y, i[2] = radius
        detected.append({"x": int(i[0]), "y": int(i[1]), "r": int(i[2])})

print("Found", len(detected), "circles")
print(json.dumps(detected, indent=2))
