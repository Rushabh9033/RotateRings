import cv2
import numpy as np
from scipy.optimize import minimize
import json

img = cv2.imread("ALL 2to100 levels/23.jpeg")
hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

scale = 720.0 / 685.0
y_off = 20.0

def to_g(x, y):
    return round(x * scale, 1), round(y * scale + y_off, 1)

# Ring list to measure in 23.jpeg:
# (id, cname, approx_box (y1, y2, x1, x2), is_hub, approx_r)
specs = [
    # Hubs:
    ("purple_hub_tl", "purple", (180, 290, 160, 270), True, 45.0),
    ("blue_hub_mid", "blue", (430, 560, 290, 420), True, 45.0),
    
    # Top Right:
    ("green_tr", "green", (140, 240, 410, 520), False, 42.0),
    ("orange_outer_tr", "orange", (220, 380, 400, 560), False, 72.0),
    ("purple_inner_tr", "purple", (250, 360, 430, 530), False, 42.0),
    
    # Top Mid & TL:
    ("green_outer_tm", "green", (180, 330, 280, 420), False, 68.0),
    ("cyan_inner_top", "cyan", (200, 300, 300, 390), False, 42.0),
    ("orange_outer_tl", "orange", (300, 460, 110, 260), False, 72.0),
    ("cyan_inner_tl", "cyan", (330, 430, 130, 230), False, 42.0),
    
    # Mid Left & Center:
    ("blue_outer_ml", "blue", (430, 590, 120, 270), False, 72.0),
    ("green_inner_ml", "green", (460, 560, 150, 240), False, 42.0),
    ("red_outer_mid", "red", (360, 510, 270, 410), False, 68.0),
    ("green_inner_mid", "green", (380, 480, 300, 380), False, 42.0),
    ("red_outer_mr", "red", (400, 560, 430, 570), False, 68.0),
    ("green_inner_mr", "green", (420, 530, 450, 550), False, 42.0),
    
    # Center lower:
    ("cyan_mid_bot", "cyan", (540, 650, 260, 360), False, 42.0),
    
    # Bottom:
    ("green_outer_bl", "green", (620, 780, 120, 270), False, 72.0),
    ("blue_inner_bl", "blue", (650, 750, 150, 240), False, 42.0),
    ("red_bot", "red", (640, 760, 300, 420), False, 45.0),
    ("orange_outer_br", "orange", (600, 760, 410, 560), False, 72.0),
    ("purple_inner_br", "purple", (630, 730, 440, 530), False, 42.0),
]

fitted = {}

for pid, cname, (y1, y2, x1, x2), is_hub, ar in specs:
    sub = img[y1:y2, x1:x2]
    sub_hsv = hsv[y1:y2, x1:x2]
    # filter by color
    if cname == "purple":
        m = cv2.inRange(sub_hsv, np.array([130, 80, 80]), np.array([165, 255, 255]))
    elif cname == "blue":
        m = cv2.inRange(sub_hsv, np.array([105, 80, 80]), np.array([130, 255, 255]))
    elif cname == "green":
        m = cv2.inRange(sub_hsv, np.array([35, 80, 80]), np.array([85, 255, 255]))
    elif cname == "orange":
        m = cv2.inRange(sub_hsv, np.array([10, 80, 80]), np.array([25, 255, 255]))
    elif cname == "red":
        m = cv2.inRange(sub_hsv, np.array([0, 100, 100]), np.array([10, 255, 255])) | cv2.inRange(sub_hsv, np.array([170, 100, 100]), np.array([180, 255, 255]))
    elif cname == "cyan":
        m = cv2.inRange(sub_hsv, np.array([85, 80, 80]), np.array([105, 255, 255]))
    
    pts = np.argwhere(m)
    if len(pts) > 30:
        ys = pts[:, 0] + y1
        xs = pts[:, 1] + x1
        res = minimize(lambda p: np.mean((np.sqrt((xs-p[0])**2 + (ys-p[1])**2) - p[2])**2), [np.mean(xs), np.mean(ys), ar])
        cx, cy, r = res.x
        fitted[pid] = (cx, cy, r)
        print(f"{pid:16s}: cx={cx:5.1f}, cy={cy:5.1f}, r={r:4.1f}")
    else:
        print(f"FAILED to fit {pid}")

with open("tools/lvl23_fitted.json", "w") as f:
    json.dump({k: [round(x, 1) for x in v] for k, v in fitted.items()}, f, indent=2)
