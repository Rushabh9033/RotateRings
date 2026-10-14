import cv2
import numpy as np

img = cv2.imread('ALL 2to100 levels/26.jpeg')
vis = img.copy()

# Centroids of Level 26
# Center hub:
# (349.5, 558.2), radius ~ 48
hub_cx, hub_cy = 349.5, 558.2
R_hub = 48.0
R = 44.0

rings = [
    # 0. Center hub
    ("cyan_hub", hub_cx, hub_cy, R_hub, 0, 0, (255, 255, 0), True),
    
    # Inner ring of 6 C-rings:
    ("orange_in_top", 349.5, 436.0, R, 270, 105, (0, 165, 255), False),
    ("purple_in_tr", 436.0, 486.0, R, 270, 105, (255, 0, 255), False),
    ("red_in_br", 436.0, 630.0, R, 315, 105, (0, 0, 255), False),
    ("blue_in_bot", 349.5, 680.0, R, 90, 105, (255, 100, 0), False),
    ("green_in_bl", 263.0, 630.0, R, 135, 105, (0, 255, 0), False),
    ("purple_in_tl", 263.0, 486.0, R, 270, 105, (255, 0, 255), False),
    
    # Outer ring:
    ("green_top_left", 236.0, 387.0, R, 270, 105, (0, 255, 0), False),
    ("purple_tr", 452.0, 388.0, R, 270, 105, (255, 0, 255), False),
    ("red_tr", 520.0, 472.0, R, 0, 105, (0, 0, 255), False),
    ("orange_mr", 520.0, 560.0, R, 180, 105, (0, 165, 255), False),
    ("purple_mr", 528.0, 642.0, R, 0, 105, (255, 0, 255), False),
    ("red_br", 462.0, 732.0, R, 90, 105, (0, 0, 255), False),
    ("cyan_bl", 234.0, 727.0, R, 90, 105, (255, 255, 0), False),
    ("orange_bl", 165.0, 639.0, R, 180, 105, (0, 165, 255), False),
    ("green_ml", 239.0, 588.0, R, 180, 105, (0, 255, 0), False),
    ("blue_tl", 161.0, 470.0, R, 180, 105, (255, 100, 0), False),
]

for name, cx, cy, r, gap_c, gap_w, col, is_closed in rings:
    cv2.circle(vis, (int(cx), int(cy)), int(r), col, 2)
    cv2.circle(vis, (int(cx), int(cy)), 3, (0, 0, 0), -1)
    if not is_closed:
        start_a = (gap_c - gap_w / 2.0)
        end_a = (gap_c + gap_w / 2.0)
        cv2.ellipse(vis, (int(cx), int(cy)), (int(r), int(r)), 0, start_a, end_a, (0, 0, 0), 4)
    cv2.putText(vis, name, (int(cx - 30), int(cy - 5)), cv2.FONT_HERSHEY_SIMPLEX, 0.35, (0, 0, 0), 2)
    cv2.putText(vis, name, (int(cx - 30), int(cy - 5)), cv2.FONT_HERSHEY_SIMPLEX, 0.35, (255, 255, 255), 1)

cv2.imwrite('_godot_test_out/wireframe_ref_26.png', vis)
print("Saved wireframe_ref_26.png")
