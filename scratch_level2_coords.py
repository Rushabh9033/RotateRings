from PIL import Image
import numpy as np

img = Image.open('C:/Users/RUSHABH/.gemini/antigravity/brain/e9c78948-a74c-446f-bc98-f1b2f607e40c/new_video_frames/detail_16.0s.png').convert('RGB')
arr = np.array(img)
h, w, _ = arr.shape

# Colors in Level 2:
# Orange (top-left)
# Blue (top-right)
# Purple (bottom)

orange_pts = []
blue_pts = []
purple_pts = []

for y in range(250, 550):
    for x in range(50, 350):
        r, g, b = [int(v) for v in arr[y, x]]
        # Orange: r > 180, 80 < g < 150, b < 60
        if r > 180 and 80 < g < 150 and b < 60:
            orange_pts.append((x, y))
        # Blue: b > 160, g > 110, r < 70
        elif b > 160 and g > 110 and r < 70:
            blue_pts.append((x, y))
        # Purple: r > 90, b > 140, g < 80
        elif r > 90 and b > 140 and g < 80:
            purple_pts.append((x, y))

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

c_o = get_stats(orange_pts, "Orange")
c_b = get_stats(blue_pts, "Blue")
c_p = get_stats(purple_pts, "Purple")

# Distance between Orange and Blue in video:
dist_ob = np.hypot(c_b[0] - c_o[0], c_b[1] - c_o[1])
print(f"Dist Orange-Blue: {dist_ob:.1f}, Sum radii: {c_o[2] + c_b[2]:.1f}, Stem: {dist_ob - c_o[2] - c_b[2]:.1f}")

dist_po = np.hypot(c_o[0] - c_p[0], c_o[1] - c_p[1])
print(f"Dist Purple-Orange: {dist_po:.1f}, Sum radii: {c_p[2] + c_o[2]:.1f}, Stem: {dist_po - c_p[2] - c_o[2]:.1f}")

# Map to Godot (scale = 720 / 384 = 1.875)
scale = 1.875
center_vid = np.array([192.0, 404.0])
center_godot = np.array([360.0, 600.0])

for name, (cx, cy, r) in [("Orange", c_o), ("Blue", c_b), ("Purple", c_p)]:
    pos_g = center_godot + (np.array([cx, cy]) - center_vid) * scale
    r_g = r * scale
    print(f"GODOT {name}: Vector2({pos_g[0]:.1f}, {pos_g[1]:.1f}), Radius: {r_g:.1f}")
