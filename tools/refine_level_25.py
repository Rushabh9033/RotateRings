import cv2
import numpy as np

img = cv2.imread('ALL 2to100 levels/25.jpeg')
vis = img.copy()

R = 44.0

rings = [
    ("purple_r1", 282, 308, R, 0, 105, (255, 0, 255)),
    ("cyan_r1", 198, 418, R, 55, 105, (255, 255, 0)),
    ("orange_r1", 308, 426, R, 250, 105, (0, 165, 255)),
    ("cyan_r2", 408, 368, R, 270, 105, (255, 255, 0)),
    ("orange_r2", 514, 368, R, 0, 105, (0, 165, 255)),
    
    ("red_r1", 216, 516, R, 180, 105, (0, 0, 255)),
    ("cyan_r3", 408, 546, R, 45, 105, (255, 255, 0)),
    ("blue_r1", 528, 534, R, 345, 105, (255, 100, 0)),
    
    ("orange_r3", 276, 606, R, 270, 105, (0, 165, 255)),
    ("red_r2", 376, 666, R, 45, 105, (0, 0, 255)),
    ("green_r1", 502, 650, R, 0, 105, (0, 255, 0)),
    
    ("cyan_r4", 192, 682, R, 180, 105, (255, 255, 0)),
    ("orange_r4", 158, 780, R, 90, 105, (0, 165, 255)),
    ("green_r2", 368, 794, R, 180, 105, (0, 255, 0)),
    ("blue_r2", 476, 766, R, 315, 105, (255, 100, 0)),
]

for name, cx, cy, r, gap_c, gap_w, col in rings:
    cv2.circle(vis, (int(cx), int(cy)), int(r), col, 2)
    start_a = (gap_c - gap_w / 2.0)
    end_a = (gap_c + gap_w / 2.0)
    cv2.ellipse(vis, (int(cx), int(cy)), (int(r), int(r)), 0, start_a, end_a, (0, 0, 0), 4)

# Draw sliders
sliders = [
    ("purple_s1", [(298, 298), (206, 298), (206, 455)], (255, 0, 255)),
    ("blue_s1", [(470, 408), (528, 408), (528, 555)], (255, 100, 0)),
    ("purple_s2", [(335, 540), (440, 435), (485, 480)], (255, 0, 255)),
    ("green_s1", [(256, 580), (256, 735), (298, 735)], (0, 255, 0)),
    ("green_s2", [(240, 740), (240, 800), (365, 800)], (0, 255, 0)),
]

for name, pts, col in sliders:
    for i in range(len(pts) - 1):
        cv2.line(vis, pts[i], pts[i+1], col, 4)

cv2.imwrite('_godot_test_out/wireframe_ref_25_v3.png', vis)
print("Saved wireframe_ref_25_v3.png")
