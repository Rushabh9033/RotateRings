from PIL import Image
import numpy as np

img = Image.open('C:/Users/RUSHABH/.gemini/antigravity/brain/e9c78948-a74c-446f-bc98-f1b2f607e40c/new_video_frames/level3_play.png').convert('RGB')
arr = np.array(img)
h, w, _ = arr.shape

# Rings in Level 3:
# Blue (top)
# Orange (left)
# Purple (right)
# Red (bottom)

blue_pts = []
orange_pts = []
purple_pts = []
red_pts = []

for y in range(200, 600):
    for x in range(50, 350):
        r, g, b = [int(v) for v in arr[y, x]]
        # Blue: b > 160, g > 110, r < 70, y < 350
        if b > 160 and g > 110 and r < 70 and y < 350:
            blue_pts.append((x, y))
        # Orange: r > 180, 80 < g < 150, b < 60
        elif r > 180 and 80 < g < 150 and b < 60:
            orange_pts.append((x, y))
        # Purple: r > 90, b > 140, g < 80
        elif r > 90 and b > 140 and g < 80:
            purple_pts.append((x, y))
        # Red: r > 180, g < 70, b < 70
        elif r > 180 and g < 70 and b < 70:
            red_pts.append((x, y))

def get_stats(pts, name):
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]
    cx = (min(xs) + max(xs)) / 2.0
    cy = (min(ys) + max(ys)) / 2.0
    diam_x = max(xs) - min(xs)
    diam_y = max(ys) - min(ys)
    r = (diam_x + diam_y) / 4.0
    print(f"[{name}] Vid Center: ({cx:.1f}, {cy:.1f}), Radius: {r:.1f}")
    return cx, cy, r

c_b = get_stats(blue_pts, "Blue")
c_o = get_stats(orange_pts, "Orange")
c_p = get_stats(purple_pts, "Purple")
c_r = get_stats(red_pts, "Red")

scale = 1.875
center_vid = np.array([192.0, 404.0])
center_godot = np.array([360.0, 600.0])

for name, (cx, cy, r) in [("Blue", c_b), ("Orange", c_o), ("Purple", c_p), ("Red", c_r)]:
    pos_g = center_godot + (np.array([cx, cy]) - center_vid) * scale
    r_g = r * scale
    print(f"GODOT {name}: Vector2({pos_g[0]:.1f}, {pos_g[1]:.1f}), Radius: {r_g:.1f}")
