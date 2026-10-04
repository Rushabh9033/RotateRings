from PIL import Image
import numpy as np

for name in ['rot_limit_8.png', 'rot_limit_11.png', 'detail_16.0s.png', 'detail_17.0s.png']:
    path = f'C:/Users/RUSHABH/.gemini/antigravity/brain/e9c78948-a74c-446f-bc98-f1b2f607e40c/new_video_frames/{name}'
    img = Image.open(path).convert('RGB')
    arr = np.array(img)
    
    # In Level 2:
    # Blue ring is top-right. Let's find its center and gap orientation
    # Blue ring pixels: x in [180, 310], y in [300, 450]
    blue_pts = []
    for y in range(300, 450):
        for x in range(180, 310):
            r, g, b = [int(v) for v in arr[y, x]]
            if b > 160 and g > 120 and r < 80:
                blue_pts.append((x, y))
    
    xs = [p[0] for p in blue_pts]
    ys = [p[1] for p in blue_pts]
    cx = (min(xs) + max(xs)) / 2.0
    cy = (min(ys) + max(ys)) / 2.0
    
    # Find the angles of blue pixels relative to (cx, cy)
    angles = []
    for x, y in blue_pts:
        dist = np.hypot(x - cx, y - cy)
        if 20 < dist < 50:
            ang = np.degrees(np.arctan2(y - cy, x - cx)) % 360.0
            angles.append(ang)
            
    # Histogram of angles in 36 buckets of 10 deg
    hist = [0] * 36
    for a in angles:
        hist[int(a // 10)] += 1
        
    empty_buckets = [i * 10 for i, count in enumerate(hist) if count < 10]
    print(f"=== {name} ===")
    print(f"Blue center: ({cx:.1f}, {cy:.1f}), Empty angles (Gap): {empty_buckets}")
