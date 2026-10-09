"""
Improved Level 2 measurement: dilate each color mask before labeling, so the
ring body and its anti-aliased inner highlight merge into one component.
Then look at the TWO largest components per color: one is the ring, the other
is the connector nub where its color bleeds into the cuff.
"""
from PIL import Image
import numpy as np
import json

img = Image.open(r'D:\AI secound Brain\RotateRings\ALL 2to100 levels\2.jpeg').convert('RGB')
arr = np.array(img)
H, W, _ = arr.shape
print(f"Reference image: {W} x {H}")

def close(c, target, tol=50):
    return all(abs(int(c[i]) - int(target[i])) <= tol for i in range(3))

# Build per-color mask
masks = {}
for name, target in [
    ("orange", (234, 120, 41)),
    ("cyan",   (50, 173, 218)),
    ("purple", (123, 97, 255)),
    ("cuff",   (31, 90, 130)),
]:
    m = np.zeros((H, W), dtype=bool)
    for y in range(H):
        for x in range(W):
            if close(arr[y, x], target):
                m[y, x] = True
    masks[name] = m

# Morphological closing: dilate 4 px then erode 4 px to merge highlights.
import scipy.ndimage as ndi
for name in masks:
    masks[name] = ndi.binary_closing(masks[name], iterations=4)

def components(mask):
    lbl, n = ndi.label(mask)
    out = []
    for i in range(1, n + 1):
        ys, xs = np.where(lbl == i)
        if len(ys) < 50: continue
        x0, x1 = int(xs.min()), int(xs.max())
        y0, y1 = int(ys.min()), int(ys.max())
        cx = (x0 + x1) / 2.0
        cy = (y0 + y1) / 2.0
        out.append({
            "x0": x0, "y0": y0, "x1": x1, "y1": y1,
            "cx": cx, "cy": cy,
            "w": x1 - x0 + 1, "h": y1 - y0 + 1,
            "area": int((lbl == i).sum()),
        })
    out.sort(key=lambda d: -d["area"])
    return out

result = {"image_size": [W, H]}
for name in ["orange", "cyan", "purple", "cuff"]:
    comps = components(masks[name])
    result[name] = comps[:6]
    print(f"\n--- {name} ---")
    for c in comps[:6]:
        print(f"  bbox=({c['x0']},{c['y0']})-({c['x1']},{c['y1']})  "
              f"size={c['w']}x{c['h']}  area={c['area']}  center=({c['cx']:.0f},{c['cy']:.0f})")

# Also: union of (orange + cyan + purple + cuff) gives the puzzle silhouette,
# excluding background. Useful for "where is the play area centroid".
puzzle = np.zeros((H, W), dtype=bool)
for name in masks: puzzle |= masks[name]
ys, xs = np.where(puzzle)
print(f"\nPuzzle bbox: x={xs.min()}-{xs.max()}, y={ys.min()}-{ys.max()}")
print(f"Puzzle center: ({(xs.min()+xs.max())/2:.0f}, {(ys.min()+ys.max())/2:.0f})")
print(f"Puzzle size: {xs.max()-xs.min()} x {ys.max()-ys.min()}")

result["puzzle_bbox"] = {
    "x0": int(xs.min()), "y0": int(ys.min()),
    "x1": int(xs.max()), "y1": int(ys.max()),
    "cx": float((xs.min()+xs.max())/2),
    "cy": float((ys.min()+ys.max())/2),
}

with open(r"D:\AI secound Brain\RotateRings\tools\measure_level2.json", "w") as f:
    json.dump(result, f, indent=2)
print("\nSaved tools/measure_level2.json")
