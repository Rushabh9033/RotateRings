"""
test_l2_acceptance.py — Phase 16 L2 acceptance report.

For each authored piece in data/user_levels/2.json, compare against
the re-measured reference image and print a per-piece error report.

Output:
  - per-piece: authored vs reference target, error dx/dy, radius error
  - per-link: cuff position/orientation
  - global: frame_scale, frame_offset_*, puzzle bbox
  - pass criterion: per-piece center error < 2 px after calibration
"""

import os
import sys
import json
import math
from PIL import Image
import numpy as np
import scipy.ndimage as ndi

REF_DIR = r"D:\AI secound Brain\RotateRings\ALL 2to100 levels"
LEVELS_DIR = r"D:\AI secound Brain\RotateRings\data\user_levels"
CANVAS_W = 720.0
CANVAS_H = 1280.0
PASS_THRESHOLD_PX = 2.0

COLOR_TARGETS = {
    "orange": (234, 120, 41),
    "cyan":   (50, 173, 218),
    "purple": (123, 97, 255),
}

def close(c, target, tol=50):
    return all(abs(int(c[i]) - int(target[i])) <= tol for i in range(3))

def measure_reference(path):
    # Use the SAME pipeline as tools/author_level.py to keep the
    # authored positions and the reference targets consistent. Apply
    # the canonical canvas calibration: place the ref image so the
    # puzzle region is centered in the 720x1280 canvas.
    from author_level import measure_components
    components, (W, H) = measure_components(path)
    # Find the puzzle centroid (avg of largest per-color component
    # centers). The author script places the ref at the top-left of
    # the canvas; we shift the calibration so the centroid lands at
    # the canvas center (360, 640).
    centroid_ref = None
    for color in ("orange", "cyan", "purple"):
        c = components[color][0] if components[color] else None
        if c is None: continue
        if centroid_ref is None:
            centroid_ref = [c["cx"], c["cy"]]
        else:
            centroid_ref[0] += c["cx"]
            centroid_ref[1] += c["cy"]
    if centroid_ref is not None:
        centroid_ref[0] /= 3
        centroid_ref[1] /= 3
    s = 720.0 / W
    # Map centroid to canvas center: centroid * s + off = (360, 640)
    off_x = 360.0 - centroid_ref[0] * s
    off_y = 640.0 - centroid_ref[1] * s
    # Apply offset to every component center.
    for color in components:
        for c in components[color]:
            c["cx"] = c["cx"] * s + off_x
            c["cy"] = c["cy"] * s + off_y
            c["w"] *= s
            c["h"] *= s
    return components, (W, H), (s, off_x, off_y)

# Phase 15: cuff reference targets. Each cuff component in the ref image
# becomes a target dict { "x", "y", "width", "height", "orientation" }.
# We can't reliably know which authored link each cuff corresponds to,
# so we report per-cuff measurements and let the human associate.
def cuff_targets(components: dict) -> list:
    targets = []
    for i, c in enumerate(components.get("cuff", [])):
        targets.append({
            "index": i,
            "x": float(c["cx"]),
            "y": float(c["cy"]),
            "w": float(c["w"]),
            "h": float(c["h"]),
            "area": int(c["area"]),
        })
    return targets

def main():
    level_id = 2
    ref_path = os.path.join(REF_DIR, f"{level_id}.jpeg")
    lvl_path = os.path.join(LEVELS_DIR, f"{level_id}.json")

    print("==========================================")
    print(f"Level {level_id} acceptance report")
    print(f"Reference: {os.path.basename(ref_path)} (685x1170)")
    print(f"Authored canvas: {int(CANVAS_W)}x{int(CANVAS_H)}")
    print("==========================================")

    if not os.path.exists(ref_path) or not os.path.exists(lvl_path):
        print(f"FAIL: missing {ref_path} or {lvl_path}")
        return 1

    measured, ref_size, calib = measure_reference(ref_path)
    s, off_x, off_y = calib
    print(f"  Calibration: scale={s:.4f}  off=({off_x:.2f}, {off_y:.2f})")
    with open(lvl_path, "r", encoding="utf-8") as f:
        authored = json.load(f)

    failures = 0
    # Match authored pieces to measured components.
    by_color = {"orange_1": "orange", "cyan_2": "cyan", "purple_3": "purple"}
    used = set()
    print("\n--- Pieces ---")
    for piece in authored["pieces"]:
        col = by_color.get(piece["id"], "")
        if not col or col not in measured:
            continue
        comps = measured[col]
        # Greedy nearest unmatched.
        best, best_d, best_i = None, 1e18, 0
        for i, c in enumerate(comps):
            if (col, i) in used: continue
            d = (c["cx"] - piece["x"]) ** 2 + (c["cy"] - piece["y"]) ** 2
            if d < best_d:
                best, best_d, best_i = c, d, i
        if best is None: continue
        used.add((col, best_i))
        ax, ay = piece["x"], piece["y"]
        rx, ry = best["cx"], best["cy"]
        dx, dy = ax - rx, ay - ry
        err_len = math.hypot(dx, dy)
        ar = float(piece["radius"])
        rr = max(best["w"], best["h"]) * 0.5
        rerr = ar - rr
        status = "OK" if err_len < PASS_THRESHOLD_PX else "FAIL"
        if status == "FAIL": failures += 1
        print(f"  {piece['id']}")
        print(f"    authored   ({ax:7.2f}, {ay:7.2f})  r={ar:5.1f}")
        print(f"    ref target ({rx:7.2f}, {ry:7.2f})  r={rr:5.1f}")
        print(f"    error      ({dx:+7.2f}, {dy:+7.2f})  {status}  (len={err_len:.2f} px)")
        print(f"    radius err  {rerr:+.2f}")
        if piece.get("gaps"):
            g = piece["gaps"][0]
            print(f"    gap center {float(g.get('center_angle_deg', 0)):5.1f} (cannot verify from bbox alone)")

    print("\n--- Links (cuff geometry) ---")
    for link in authored["links"]:
        from_p = next((p for p in authored["pieces"] if p["id"] == link["from_id"]), None)
        to_p = next((p for p in authored["pieces"] if p["id"] == link["to_id"]), None)
        if from_p is None or to_p is None: continue
        dx = to_p["x"] - from_p["x"]
        dy = to_p["y"] - from_p["y"]
        dist = math.hypot(dx, dy)
        angle = math.degrees(math.atan2(dy, dx)) % 360.0
        print(f"  {link['from_id']} -> {link['to_id']}  dist={dist:.1f}  angle={angle:.1f}  "
              f"collar={float(link.get('collar_angle_deg', 0)):.1f}  "
              f"stem={float(link.get('stem_distance_from_piece', 0)):.1f}")

    # Phase 15: cuff reference targets. These are the actual cuff blobs
    # in the reference image. The human (or the snap action) maps each
    # authored link to one of these.
    print("\n--- Cuff reference targets (in canvas space) ---")
    cuffs = cuff_targets(measured)
    if not cuffs:
        print("  (no cuff components detected in reference)")
    for c in cuffs:
        print(f"  cuff[{c['index']}]  ({c['x']:.1f}, {c['y']:.1f})  size {c['w']:.0f}x{c['h']:.0f}  area={c['area']}")

    print("\n--- Global transform ---")
    fs = float(authored.get("frame_scale", 1.0))
    fo_x = float(authored.get("frame_offset_x", 0.0))
    fo_y = float(authored.get("frame_offset_y", 0.0))
    print(f"  frame_scale:    {fs:.4f}")
    print(f"  frame_offset_x: {fo_x:.2f}")
    print(f"  frame_offset_y: {fo_y:.2f}")
    minx, miny, maxx, maxy = 1e9, 1e9, -1e9, -1e9
    for p in authored["pieces"]:
        r = float(p["radius"])
        minx = min(minx, p["x"] - r); miny = min(miny, p["y"] - r)
        maxx = max(maxx, p["x"] + r); maxy = max(maxy, p["y"] + r)
    print(f"  puzzle bbox:    ({minx:.0f}, {miny:.0f}) - ({maxx:.0f}, {maxy:.0f})  size {maxx-minx:.0f} x {maxy-miny:.0f}")

    print("\n--- Acceptance summary ---")
    print(f"  Pass criterion: per-piece center error < {PASS_THRESHOLD_PX} px after calibration.")
    if failures == 0:
        print(f"  RESULT: PASS (0 pieces failed)")
        return 0
    else:
        print(f"  RESULT: FAIL ({failures} pieces failed)")
        return 1

if __name__ == "__main__":
    sys.exit(main())