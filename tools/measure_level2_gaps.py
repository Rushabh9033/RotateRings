"""
Robust version handling gap that wraps around 0°.
"""
from PIL import Image
import numpy as np
import math

img = Image.open(r'D:\AI secound Brain\RotateRings\ALL 2to100 levels\2.jpeg').convert('RGB')
arr = np.array(img)
H, W, _ = arr.shape

def close(c, target, tol=50):
    return all(abs(int(c[i]) - int(target[i])) <= tol for i in range(3))

def measure_ring(name, color_target, cx, cy):
    m = np.zeros((H, W), dtype=bool)
    for y in range(H):
        for x in range(W):
            if close(arr[y, x], color_target):
                m[y, x] = True
    bins = np.zeros(360, dtype=int)
    ys, xs = np.where(m)
    for x, y in zip(xs, ys):
        dx, dy = x - cx, y - cy
        r = math.hypot(dx, dy)
        if 30 < r < 110:
            a = (math.degrees(math.atan2(dy, dx)) + 360) % 360
            bins[int(a) % 360] += 1
    max_b = bins.max() if bins.max() > 0 else 1
    is_gap = bins < max_b * 0.30
    # Find largest consecutive run, allowing wrap-around.
    # Add 720-bin copy for wrap detection.
    doubled = np.concatenate([is_gap, is_gap])
    best_start, best_len = 0, 0
    for i in range(720):
        if doubled[i]:
            j = i
            while j < 720 and doubled[j]:
                j += 1
            run_len = j - i
            if run_len > best_len:
                best_len = run_len
                best_start = i % 360
            i = j
    gap_center = (best_start + best_len / 2.0) % 360
    return bins, gap_center, best_len

def report(name, color, cx, cy):
    bins, gap_center, gap_len = measure_ring(name, color, cx, cy)
    print(f"\n{name}: center=({cx},{cy})  gap length={gap_len}°  gap center={gap_center:.1f}°")
    # Show density map (every 10°).
    bar = ""
    for a in range(0, 360, 10):
        d = sum(bins[a:a+10])
        bar += f"{d:4d}|"
    print(f"  density 0°→  : {bar}")
    # Identify gap as the lowest 60° region.
    sorted_bins = sorted([(bins[a], a) for a in range(360)])
    gap_center_est = np.mean([a for _, a in sorted_bins[:60]]) % 360
    print(f"  lowest-60° avg center = {gap_center_est:.1f}°")

report("orange", (234, 120, 41), 275, 497)
report("cyan",   (50, 173, 218), 425, 497)
report("purple", (123, 97, 255), 336, 620)
