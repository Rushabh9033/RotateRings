import cv2
import numpy as np
import os
import glob

images = glob.glob(r"D:\AI secound Brain\RotateRings\ALL 2to100 levels\*.jpeg")
img_path = images[0]

img = cv2.imread(img_path)
gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
blurred = cv2.GaussianBlur(gray, (9, 9), 2)

circles = cv2.HoughCircles(blurred, cv2.HOUGH_GRADIENT, dp=1.2, minDist=30,
                           param1=50, param2=30, minRadius=20, maxRadius=200)

if circles is not None:
    circles = np.uint16(np.around(circles))
    print(f"Found {len(circles[0])} circles")
    for i in circles[0, :]:
        print(f"  Center: ({i[0]}, {i[1]}), Radius: {i[2]}")
else:
    print("Found 0 circles")
