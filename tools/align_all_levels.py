"""
align_all_levels.py — batch-align every level 2..100 to its reference JPEG.

For each level n:
  1. Read the reference image at ALL 2to100 levels/<n>.jpeg.
  2. Find the per-color component bboxes (orange / cyan / purple / cuff)
     and the puzzle silhouette bbox.
  3. Map those into the engine's viewport space (720x1280) using the
     same sx/sy scaling used by tools/measure_level2.py and
     tools/reconstruct_level2.py.
  4. Read data/user_levels/<n>.json.
  5. Match each authored piece to the closest reference component
     (by color + relative position). Compute the (dx, dy) shift to
     center the piece on its reference target.
  6. Apply the shift via document.apply_edit semantics (we modify the
     piece dicts in-place and re-save; undo is not part of this script
     since we want a fresh overwrite).
  7. Print a per-level summary: N pieces aligned, mean center error.

Run:
  python tools/align_all_levels.py              # all 99 levels (2..100)
  python tools/align_all_levels.py --levels 2  # only level 2
  python tools/align_all_levels.py --levels 2 3 5  # specific levels
  python tools/align_all_levels.py --dry-run   # don't write
"""

import os
import sys
import json
import math
import argparse
from PIL import Image
import numpy as np
import scipy.ndimage as ndi

# Engine viewport: puzzles are framed into a 720x1280 area.
VIEWPORT_W = 720.0
VIEWPORT_H = 1280.0

REF_DIR = r"D:\AI secound Brain\RotateRings\ALL 2to100 levels"
LEVELS_DIR = r"D:\AI secound Brain\RotateRings\data\user_levels"

# Reference color targets (RGB) — the four palette colors used by levels.
COLOR_TARGETS = {
    "orange": (234, 120, 41),
    "cyan":   (50, 173, 218),
    "purple": (123, 97, 255),
    "cuff":   (31, 90, 130),
}

def close(c, target, tol=50):
    return all(abs(int(c[i]) - int(target[i])) <= tol for i in range(3))

def measure_reference(path):
    """Return per-color components and puzzle bbox in viewport coords.

    Each component is { cx, cy, x0, y0, x1, y1, w, h, area } scaled to the
    engine viewport.
    """
    img = Image.open(path).convert("RGB")
    arr = np.array(img)
    H, W, _ = arr.shape

    # Per-color binary mask with morphological closing so anti-aliased
    # highlights merge into the body.
    masks = {}
    for name, target in COLOR_TARGETS.items():
        m = np.zeros((H, W), dtype=bool)
        for y in range(H):
            for x in range(W):
                if close(arr[y, x], target):
                    m[y, x] = True
        masks[name] = ndi.binary_closing(m, iterations=4)

    # Connected components
    comps = {}
    for name, mask in masks.items():
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
        comps[name] = out

    # Scale reference coordinates into engine viewport.
    sx = VIEWPORT_W / float(W)
    sy = VIEWPORT_H / float(H)
    for name in list(comps.keys()):
        for c in comps[name]:
            c["cx"] *= sx
            c["cy"] *= sy
            c["x0"] *= sx; c["x1"] *= sx
            c["y0"] *= sy; c["y1"] *= sy
            c["w"]  *= sx
            c["h"]  *= sy

    # Puzzle bbox = union of all color masks.
    union = np.zeros((H, W), dtype=bool)
    for m in masks.values():
        union |= m
    ys, xs = np.where(union)
    puzzle = {
        "x0": float(xs.min()) * sx,
        "y0": float(ys.min()) * sy,
        "x1": float(xs.max()) * sx,
        "y1": float(ys.max()) * sy,
        "cx": float((xs.min() + xs.max()) / 2) * sx,
        "cy": float((ys.min() + ys.max()) / 2) * sy,
    }
    return {"image_size": [W, H], "components": comps, "puzzle_bbox": puzzle}

def piece_color(piece):
    """Return the dominant color of a piece from its color_hex / color_name."""
    hex_ = piece.get("color_hex", "")
    if isinstance(hex_, str) and hex_.startswith("#"):
        r = int(hex_[1:3], 16); g = int(hex_[3:5], 16); b = int(hex_[5:7], 16)
        # Find closest of the four target colors.
        best = None; best_d = 1e9
        for name, (tr, tg, tb) in COLOR_TARGETS.items():
            d = abs(r - tr) + abs(g - tg) + abs(b - tb)
            if d < best_d:
                best_d = d
                best = name
        return best
    name = piece.get("color_name", "")
    if name in COLOR_TARGETS:
        return name
    return None

def match_piece_to_ref(piece, ref_comps):
    """Pick the ref component for a piece by color and current proximity.

    Heuristic: among components of the same color within a generous
    search radius (3x the piece's current radius), score each by
    `distance / sqrt(area)`. This biases toward large components
    (actual rings, not fragments) and only within reach. Falls back
    to the closest component if nothing matches in radius.
    """
    color = piece_color(piece)
    if color is None or not ref_comps.get(color):
        return None
    px = float(piece.get("x", 0.0))
    py = float(piece.get("y", 0.0))
    cur_r = float(piece.get("radius", 60.0))
    search_r = max(120.0, cur_r * 3.0)
    scored = []
    for c in ref_comps[color]:
        if c["area"] <= 0: continue
        d = math.hypot(c["cx"] - px, c["cy"] - py)
        # Lower is better: distance / sqrt(area) — larger components
        # win at the same distance.
        scored.append((d / math.sqrt(c["area"]), d, c))
    if not scored:
        return None
    # Prefer components within the search radius first; if none, fall
    # back to the global best.
    in_range = [s for s in scored if s[1] <= search_r]
    chosen = in_range if in_range else scored
    chosen.sort(key=lambda t: t[0])
    return chosen[0][2]

def align_level(n, dry_run=False):
    ref_path = os.path.join(REF_DIR, f"{n}.jpeg")
    lvl_path = os.path.join(LEVELS_DIR, f"{n}.json")
    if not os.path.exists(ref_path):
        return {"level": n, "ok": False, "error": f"missing {ref_path}"}
    if not os.path.exists(lvl_path):
        return {"level": n, "ok": False, "error": f"missing {lvl_path}"}
    ref = measure_reference(ref_path)
    with open(lvl_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    pieces = data.get("pieces", [])
    if not pieces:
        return {"level": n, "ok": True, "changed": 0, "note": "no pieces"}

    ref_comps = ref["components"]
    changes = []
    moved_pieces: dict = {}  # id -> (new_x, new_y, new_r)
    for p in pieces:
        target = match_piece_to_ref(p, ref_comps)
        if target is None:
            continue
        # Target bbox extent in viewport units: the piece's radius is
        # half the bbox width (or height, whichever fits a ring). Match
        # against the reference component bbox.
        cur_r = float(p.get("radius", 60.0))
        target_r = max(target["w"], target["h"]) * 0.5
        new_r = max(8.0, min(400.0, target_r))
        # Center alignment.
        dx = target["cx"] - float(p.get("x", 0.0))
        dy = target["cy"] - float(p.get("y", 0.0))
        # If the radius change is small, leave it; otherwise update.
        if abs(dx) > 0.5 or abs(dy) > 0.5 or abs(new_r - cur_r) > 0.5:
            p["x"] = float(target["cx"])
            p["y"] = float(target["cy"])
            p["radius"] = new_r
            p["radius_y"] = new_r
            moved_pieces[p.get("id", "?")] = (float(target["cx"]), float(target["cy"]), new_r)
            changes.append({
                "id": p.get("id", "?"),
                "dx": round(dx, 2),
                "dy": round(dy, 2),
                "r_old": cur_r,
                "r_new": round(new_r, 2),
            })

    # Re-derive link collar_angle_deg and stem_distance_from_piece for
    # any link that touches a moved piece. Otherwise the connector
    # points to the old position and the validator reports gap violations.
    links = data.get("links", [])
    if moved_pieces and links:
        piece_pos = {p.get("id", "?"): (float(p.get("x", 0.0)), float(p.get("y", 0.0)),
                                              float(p.get("radius", 60.0))) for p in pieces}
        for l in links:
            fid = l.get("from_id", ""); tid = l.get("to_id", "")
            from_moved = fid in moved_pieces
            to_moved = tid in moved_pieces
            if not (from_moved or to_moved):
                continue
            if fid not in piece_pos or tid not in piece_pos:
                continue
            fx, fy, fr = piece_pos[fid]
            tx, ty, tr = piece_pos[tid]
            # The link's start is the from-piece's cuff. The vector from
            # from to to in world space is the new connector axis.
            dx = tx - fx
            dy = ty - fy
            dist = math.hypot(dx, dy)
            if dist < 1.0:
                continue
            # Collar angle = world vector angle - from.start_angle_deg.
            from_start = 0.0
            for pp in pieces:
                if pp.get("id", "") == fid:
                    from_start = float(pp.get("start_angle_deg", 0.0))
                    break
            collar = math.fmod(math.degrees(math.atan2(dy, dx)) - from_start, 360.0)
            if collar < 0: collar += 360.0
            l["collar_angle_deg"] = collar
            l["stem_distance_from_piece"] = dist
            # Also update legacy stem_dist if present.
            if "stem_dist" in l:
                l["stem_dist"] = dist

    if changes and not dry_run:
        with open(lvl_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2)
    return {
        "level": n,
        "ok": True,
        "changed": len(changes),
        "n_pieces": len(pieces),
        "changes": changes[:6],
    }

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--levels", nargs="*", type=int, default=None,
                    help="Specific level numbers; default = 2..100")
    ap.add_argument("--dry-run", action="store_true",
                    help="Don't write the user_levels JSONs")
    args = ap.parse_args()

    if args.levels:
        targets = args.levels
    else:
        targets = list(range(2, 101))
    total_changed = 0
    total_pieces = 0
    failures = []
    for n in targets:
        r = align_level(n, dry_run=args.dry_run)
        if not r.get("ok"):
            failures.append(r)
            print(f"  [L{n:>3}]  ERR: {r.get('error')}")
            continue
        total_changed += r.get("changed", 0)
        total_pieces  += r.get("n_pieces", 0)
        if r.get("changed"):
            chg = r["changes"][0]
            print(f"  [L{n:>3}]  {r['changed']:>2}/{r['n_pieces']:>2} pieces aligned  "
                  f"first: {chg['id']:<14} dx={chg['dx']:>7.2f} dy={chg['dy']:>7.2f}  r: {chg['r_old']:.0f}->{chg['r_new']:.0f}")
        else:
            print(f"  [L{n:>3}]  no change")
    print()
    print(f"Summary: {total_changed} piece changes across {len(targets) - len(failures)} levels "
          f"({len(failures)} failures)")
    if args.dry_run:
        print("(dry run: no files written)")
    if failures:
        print("Failures:")
        for f in failures:
            print(" -", f)

if __name__ == "__main__":
    main()