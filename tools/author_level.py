"""
author_level.py — generate a complete data/user_levels/<n>.json from a
reference image (n.jpeg). For each color the largest component becomes
a ring; the cuff-colored components between rings become connectors.

Heuristics (good enough for Levels 2-100 based on the palette of
4 colors: orange / cyan / purple / cuff):
  1. Mask each color with morphological closing (anti-alias merge).
  2. For each color EXCEPT cuff, pick the largest component as a ring.
     Smaller components of the same color are either (a) cuff-nubs
     that share the ring's color, or (b) part of a "Tidy up" / fork
     shape — we treat them as visual noise and skip them.
  3. For the cuff color, every component is a connector. Build a
     link from the nearest ring on the cuff's "left" side to the
     nearest ring on its "right" side. Distance measured from
     component centroids.
  4. The closed hub piece (one with no gap) is the one with the
     most cuffs attached. It also gets role = ROOT_ANCHOR.

Usage:
  python tools/author_level.py 5        # writes data/user_levels/5.json
  python tools/author_level.py 5 --dry  # preview without writing
  python tools/author_level.py 5 6 7    # multiple levels
"""

import os
import sys
import json
import math
import argparse
from PIL import Image
import numpy as np
import scipy.ndimage as ndi

REF_DIR = r"D:\AI secound Brain\RotateRings\ALL 2to100 levels"
LEVELS_DIR = r"D:\AI secound Brain\RotateRings\data\user_levels"
VIEWPORT_W = 720.0
VIEWPORT_H = 1280.0

COLOR_TARGETS = {
    "orange": (234, 120, 41),
    "cyan":   (50, 173, 218),
    "purple": (123, 97, 255),
    "cuff":   (31, 90, 130),
}

def close(c, target, tol=50):
    return all(abs(int(c[i]) - int(target[i])) <= tol for i in range(3))

def measure_components(path):
    img = Image.open(path).convert("RGB")
    arr = np.array(img)
    H, W, _ = arr.shape

    masks = {}
    for name, target in COLOR_TARGETS.items():
        m = np.zeros((H, W), dtype=bool)
        for y in range(H):
            for x in range(W):
                if close(arr[y, x], target):
                    m[y, x] = True
        masks[name] = ndi.binary_closing(m, iterations=4)

    # Scale ref->viewport.
    sx = VIEWPORT_W / float(W)
    sy = VIEWPORT_H / float(H)

    components = {}
    for name, mask in masks.items():
        lbl, n = ndi.label(mask)
        comps = []
        for i in range(1, n + 1):
            ys, xs = np.where(lbl == i)
            if len(ys) < 50: continue
            x0, x1 = int(xs.min()), int(xs.max())
            y0, y1 = int(ys.min()), int(ys.max())
            comps.append({
                "x0": x0 * sx, "y0": y0 * sy,
                "x1": x1 * sx, "y1": y1 * sy,
                "cx": ((x0 + x1) / 2.0) * sx,
                "cy": ((y0 + y1) / 2.0) * sy,
                "w": (x1 - x0 + 1) * sx,
                "h": (y1 - y0 + 1) * sy,
                "area": int((lbl == i).sum()),
            })
        comps.sort(key=lambda d: -d["area"])
        components[name] = comps
    return components, (W, H)

def color_to_hex(name: str) -> str:
    r, g, b = COLOR_TARGETS[name]
    return "#%02X%02X%02X" % (r, g, b)

def author_level(n, dry_run=False):
    ref_path = os.path.join(REF_DIR, f"{n}.jpeg")
    out_path = os.path.join(LEVELS_DIR, f"{n}.json")
    if not os.path.exists(ref_path):
        return {"level": n, "ok": False, "error": f"missing {ref_path}"}

    components, img_size = measure_components(ref_path)
    # Pick the rings. Many levels have multiple same-color rings
    # (mirror, triad, or grid layouts). Take ALL components whose area
    # is at least 30% of the largest AND whose centroid is more than
    # 120px away from any already-picked ring (so the cuff-nub
    # artifacts AND the second-arc of a single C-shape ring don't get
    # a duplicate entry).
    rings = []  # [ {color, cx, cy, radius} ]
    for color in ("orange", "cyan", "purple"):
        comps = components.get(color, [])
        if not comps: continue
        largest = comps[0]["area"]
        for c in comps:
            if c["area"] < largest * 0.30: break
            # Dedup: if there's already a ring of the same color
            # within 120px, skip. The two arcs of a C-shape ring are
            # typically 80-110px apart, so this collapses them.
            is_dup = False
            for r in rings:
                if r["color"] == color and math.hypot(r["cx"] - c["cx"], r["cy"] - c["cy"]) < 120.0:
                    is_dup = True
                    break
            if is_dup: continue
            rings.append({
                "color": color,
                "cx": c["cx"], "cy": c["cy"],
                "radius": max(c["w"], c["h"]) * 0.5,
            })

    # Build pieces. One per ring. The first ring (in reading order) is
    # the closed root anchor; the rest get a default gap.
    pieces = []
    for i, r in enumerate(rings):
        role = 1 if i == 0 else 0  # ROOT_ANCHOR / NORMAL
        piece = {
            "id": f"{r['color']}_{i+1}",
            "color_name": r["color"],
            "color_hex": color_to_hex(r["color"]),
            "x": float(r["cx"]),
            "y": float(r["cy"]),
            "start_angle_deg": 0.0,
            "radius": float(r["radius"]),
            "radius_y": float(r["radius"]),
            "thickness": 22.0,
            "shape_type": 0,  # CIRCLE
            "piece_type": 0 if i == 0 else 1,  # CLOSED / OPEN
            "gaps": [] if i == 0 else [
                {"center_angle_deg": 90.0, "width_deg": 80.0, "tolerance_deg": 16.0}
            ],
            "role": role,
            "z_index": 1,
            "initially_locked": False,
            "locked": False,
            "property_locks": {},
            "release_direction": {"x": 1.0, "y": 0.0},
            "target_exit_angle_deg": 0.0,
            "motion_model": 0,
        }
        pieces.append(piece)

    # Build links. For each cuff component, find the two closest rings
    # on either side and connect them. The cuff is between them.
    links = []
    link_id = 0
    used_targets: set = set()  # ring ids that have at least one link
    for cuff in components.get("cuff", []):
        if len(rings) < 2: break
        # Sort rings by their angle from the cuff's centroid.
        ranked = sorted(rings, key=lambda r: math.atan2(r["cy"] - cuff["cy"],
                                                       r["cx"] - cuff["cx"]))
        # The two rings on the smallest angle delta (consecutive in the
        # sorted list) form the pair the cuff connects. Skip self-pairs
        # (cuff lies INSIDE a ring, not between two).
        best_pair = None
        best_gap = 1e9
        for i in range(len(ranked)):
            r1 = ranked[i]
            r2 = ranked[(i + 1) % len(ranked)]
            # Compare by color+position so we don't link a ring to itself
            # (the wraparound case when the cuff is INSIDE one ring).
            if r1["color"] == r2["color"] and abs(r1["cx"] - r2["cx"]) < 0.5 and abs(r1["cy"] - r2["cy"]) < 0.5:
                continue
            a1 = math.atan2(r1["cy"] - cuff["cy"], r1["cx"] - cuff["cx"])
            a2 = math.atan2(r2["cy"] - cuff["cy"], r2["cx"] - cuff["cx"])
            gap = abs(a2 - a1)
            if gap < best_gap:
                best_gap = gap
                best_pair = (r1, r2)
        if best_pair is None: continue
        from_ring, to_ring = best_pair
        # The link's parent is the ring whose color matches the cuff's
        # nearest neighbor. In our heuristic, both are valid parents;
        # the puzzle's gravity hub is the closed root. Pick the root
        # as the parent if it exists, else the first ring.
        parent = next((p for p in pieces if p["role"] == 1), pieces[0]) if pieces else None
        if parent is None: continue
        # Skip self-pairs where the chosen "to" ring IS the root (the
        # cuff is inside the root, not between two rings).
        to_id = to_ring["color"] + "_" + str(rings.index(to_ring) + 1)
        if parent["id"] == to_id: continue
        used_targets.add(to_id)
        # Compute collar + stem distance.
        dx = to_ring["cx"] - parent["x"]
        dy = to_ring["cy"] - parent["y"]
        dist = math.hypot(dx, dy)
        collar = math.fmod(math.degrees(math.atan2(dy, dx)) - parent["start_angle_deg"], 360.0)
        if collar < 0: collar += 360.0
        link = {
            "id": f"link_{link_id}",
            "from_id": parent["id"],
            "to_id": to_id,
            "collar_angle_deg": collar,
            "cuff_center_local": {"x": 0.0, "y": 0.0},
            "cuff_orientation_deg": 0.0,
            "cuff_width": 32.0,
            "cuff_depth": 18.0,
            "cuff_round_radius": 5.0,
            "stem_length": dist,
            "stem_width": 6.0,
            "stem_distance_from_piece": dist,
            "stem_dist": dist,
            "joint_color_hex": color_to_hex("cuff"),
            "joint_color_name": "cuff",
            "clearance_tolerance_deg": 16.0,
            "is_detached": False,
            "z_index": 0,
        }
        links.append(link)
        link_id += 1

    data = {
        "id": n,
        "title": f"Level {n}",
        "instruction": "",
        "par_moves": max(1, len(links)),
        "theme_id": "porcelain",
        "frame_scale": 1.0,
        "frame_offset_x": 0.0,
        "frame_offset_y": 0.0,
        "frame_anchor": "auto",
        "grid_size": 20.0,
        "snap_to_grid": False,
        "snap_to_piece_centers": False,
        "snap_to_edges": False,
        "snap_to_guides": False,
        "snap_to_connector_points": False,
        "nudge_step": 1.0,
        "nudge_shift_multiplier": 10.0,
        "nudge_alt_multiplier": 0.1,
        "guides": [],
        "reference_guides": [],
        "size_links": {},
        "locks": {},
        "pieces": pieces,
        "links": links,
        "source": "author_level.py",
    }

    # Post-link pass: any ring that still has no incoming link needs to
    # be connected to the parent (or the nearest other ring if no parent
    # exists). Without this the validator reports "N disconnected
    # components" because the adjacency graph is a star and a star
    # is fully connected only if every non-root has at least one edge.
    if pieces:
        parent_piece = next((p for p in pieces if p["role"] == 1), pieces[0])
        for p in pieces:
            if p["id"] == parent_piece["id"]: continue
            has_incoming = any(l["to_id"] == p["id"] for l in links)
            if not has_incoming:
                # Connect this ring to the parent with a default collar.
                dx = p["x"] - parent_piece["x"]
                dy = p["y"] - parent_piece["y"]
                dist = math.hypot(dx, dy) or 1.0
                collar = math.fmod(math.degrees(math.atan2(dy, dx)) - parent_piece["start_angle_deg"], 360.0)
                if collar < 0: collar += 360.0
                links.append({
                    "id": f"link_{link_id}_fallback",
                    "from_id": parent_piece["id"],
                    "to_id": p["id"],
                    "collar_angle_deg": collar,
                    "cuff_center_local": {"x": 0.0, "y": 0.0},
                    "cuff_orientation_deg": 0.0,
                    "cuff_width": 32.0,
                    "cuff_depth": 18.0,
                    "cuff_round_radius": 5.0,
                    "stem_length": dist,
                    "stem_width": 6.0,
                    "stem_distance_from_piece": dist,
                    "stem_dist": dist,
                    "joint_color_hex": color_to_hex("cuff"),
                    "joint_color_name": "cuff",
                    "clearance_tolerance_deg": 16.0,
                    "is_detached": False,
                    "z_index": 0,
                })
                link_id += 1
    if not dry_run:
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)
    return {
        "level": n,
        "ok": True,
        "n_pieces": len(pieces),
        "n_links": len(links),
        "ring_count": len(rings),
        "cuff_count": len(components.get("cuff", [])),
    }

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("levels", nargs="+", type=int)
    ap.add_argument("--dry", action="store_true", help="Don't write JSON")
    args = ap.parse_args()
    successes = 0
    for n in args.levels:
        r = author_level(n, dry_run=args.dry)
        if r.get("ok"):
            successes += 1
            print(f"  [L{n:>3}]  {r['n_pieces']} pieces, {r['n_links']} links  "
                  f"(rings: {r['ring_count']}, cuffs seen: {r['cuff_count']})")
        else:
            print(f"  [L{n:>3}]  ERR: {r.get('error')}")
    print(f"\nSummary: {successes}/{len(args.levels)} authored" +
          (" (dry run)" if args.dry else ""))

if __name__ == "__main__":
    main()