import numpy as np
from PIL import Image
from collections import deque
import colorsys

img = Image.open("ALL 2to100 levels/6.jpeg").convert("RGB")
w, h = img.size
sx = 720.0 / w
sy = 1280.0 / h

arr = np.array(img) / 255.0
y_start, y_end = int(0.25 * h), int(0.75 * h)
sub = arr[y_start:y_end, :]

# HSV
H = np.zeros((sub.shape[0], sub.shape[1]))
S = np.zeros((sub.shape[0], sub.shape[1]))
for y in range(sub.shape[0]):
    for x in range(sub.shape[1]):
        r, g, b = sub[y, x]
        h_val, s_val, _ = colorsys.rgb_to_hsv(r, g, b)
        H[y, x] = h_val * 360.0
        S[y, x] = s_val

is_col = S > 0.35

# Component definitions based on pixel regions
def get_pts(mask):
    ys, xs = np.where(mask)
    return [(xs[i] * sx, (ys[i] + y_start) * sy) for i in range(len(xs))]

# Circle fitting via Kasa algebraic method
def fit_circle(pts):
    x = np.array([p[0] for p in pts])
    y = np.array([p[1] for p in pts])
    A = np.column_stack([x, y, np.ones_like(x)])
    b = x**2 + y**2
    c, residuals, rank, s = np.linalg.lstsq(A, b, rcond=None)
    xc = c[0] / 2.0
    yc = c[1] / 2.0
    r = np.sqrt(c[2] + xc**2 + yc**2)
    return xc, yc, r

# 1. Orange ring (bottom-left)
pts_orange_ring = get_pts(((H >= 15) & (H < 45) & is_col) & (np.arange(sub.shape[0])[:, None] + y_start > 0.45 * h) & (np.arange(sub.shape[1])[None, :] < 0.40 * w))
xc_orange, yc_orange, r_orange = fit_circle(pts_orange_ring)
print(f"Orange Ring: center=({xc_orange:.1f}, {yc_orange:.1f}), radius={r_orange:.1f}")

# 2. Cyan arc (top-left)
pts_cyan = get_pts((H >= 165) & (H < 205) & is_col)
xc_cyan, yc_cyan, r_cyan = fit_circle(pts_cyan)
print(f"Cyan Arc: center=({xc_cyan:.1f}, {yc_cyan:.1f}), radius={r_cyan:.1f}")

# 3. Purple arc (top-right)
pts_purple = get_pts((H >= 250) & (H < 305) & is_col)
xc_purple, yc_purple, r_purple = fit_circle(pts_purple)
print(f"Purple Arc: center=({xc_purple:.1f}, {yc_purple:.1f}), radius={r_purple:.1f}")

# 4. Red arc (center)
pts_red = get_pts(((H < 15) | (H > 345)) & is_col)
xc_red, yc_red, r_red = fit_circle(pts_red)
print(f"Red Arc: center=({xc_red:.1f}, {yc_red:.1f}), radius={r_red:.1f}")

# 5. Green arc (middle-right)
pts_green_arc = get_pts(((H >= 75) & (H < 165) & is_col) & (np.arange(sub.shape[1])[None, :] > 0.55 * w))
xc_green, yc_green, r_green = fit_circle(pts_green_arc)
print(f"Green Arc: center=({xc_green:.1f}, {yc_green:.1f}), radius={r_green:.1f}")

# 6. Blue arc (bottom-right)
pts_blue = get_pts((H >= 205) & (H < 250) & is_col)
xc_blue, yc_blue, r_blue = fit_circle(pts_blue)
print(f"Blue Arc: center=({xc_blue:.1f}, {yc_blue:.1f}), radius={r_blue:.1f}")

# 7. Orange L slider
pts_orange_l = get_pts(((H >= 15) & (H < 45) & is_col) & (np.arange(sub.shape[0])[:, None] + y_start < 0.45 * h))
xs_ol = [p[0] for p in pts_orange_l]
ys_ol = [p[1] for p in pts_orange_l]
print(f"Orange L: min=({min(xs_ol):.1f}, {min(ys_ol):.1f}), max=({max(xs_ol):.1f}, {max(ys_ol):.1f}), span=({max(xs_ol)-min(xs_ol):.1f} x {max(ys_ol)-min(ys_ol):.1f})")

# 8. Green L slider
pts_green_l = get_pts(((H >= 75) & (H < 165) & is_col) & (np.arange(sub.shape[1])[None, :] <= 0.55 * w))
xs_gl = [p[0] for p in pts_green_l]
ys_gl = [p[1] for p in pts_green_l]
print(f"Green L: min=({min(xs_gl):.1f}, {min(ys_gl):.1f}), max=({max(xs_gl):.1f}, {max(ys_gl):.1f}), span=({max(xs_gl)-min(xs_gl):.1f} x {max(ys_gl)-min(ys_gl):.1f})")
