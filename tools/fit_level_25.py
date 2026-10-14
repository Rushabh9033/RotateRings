import cv2
import numpy as np

img = cv2.imread('ALL 2to100 levels/25.jpeg')
vis = img.copy()

# List candidate rings: (id, cx, cy, r, color_bgr)
# Standard ring radius is ~44px
R = 44.0

rings = [
    # Top cluster
    ("purple_r1", 280, 315, R, (255, 0, 255)),
    ("cyan_r1", 205, 420, R, (255, 255, 0)),
    ("orange_r1", 310, 420, R, (0, 165, 255)),
    ("cyan_r2", 415, 375, R, (255, 255, 0)),
    ("orange_r2", 520, 375, R, (0, 165, 255)),
    
    # Mid-upper cluster
    ("red_r1", 215, 520, R, (0, 0, 255)),
    ("cyan_r3", 410, 545, R, (255, 255, 0)),
    ("blue_r1", 525, 530, R, (255, 100, 0)),
    
    # Mid cluster
    ("orange_r3", 275, 600, R, (0, 165, 255)),
    ("red_r2", 375, 660, R, (0, 0, 255)),
    ("green_r1", 500, 650, R, (0, 255, 0)),
    
    # Lower cluster
    ("cyan_r4", 195, 675, R, (255, 255, 0)),
    ("orange_r4", 155, 770, R, (0, 165, 255)),
    ("green_r2", 370, 780, R, (0, 255, 0)),
    ("blue_r2", 475, 765, R, (255, 100, 0)),
]

for name, cx, cy, r, col in rings:
    cv2.circle(vis, (int(cx), int(cy)), int(r), col, 2)
    cv2.circle(vis, (int(cx), int(cy)), 3, (0, 0, 0), -1)
    cv2.putText(vis, name, (int(cx - 30), int(cy - 5)), cv2.FONT_HERSHEY_SIMPLEX, 0.4, (0, 0, 0), 2)
    cv2.putText(vis, name, (int(cx - 30), int(cy - 5)), cv2.FONT_HERSHEY_SIMPLEX, 0.4, (255, 255, 255), 1)

cv2.imwrite('_godot_test_out/wireframe_ref_25.png', vis)
print("Saved wireframe_ref_25.png")
