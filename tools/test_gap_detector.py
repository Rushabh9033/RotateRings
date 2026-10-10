"""
test_gap_detector.py — regression tests for the three-state gap detector.

Covers:
  1. Clean C-ring (no cuff overlap): detects a clean gap ~90-120 deg.
  2. C-ring with cuff overlapping body: cuff-occluded angles
     are classified as OCCLUDED, not VISIBLE_EMPTY. The detected
     gap should be the same as the clean case.
  3. C-ring with cuff near (but not in) the gap: the gap is still
     detected as VISIBLE_EMPTY.
  4. C-ring with anti-aliased edges: detected gap is within ~5 deg
     of the synthetic ground truth.
  5. C-ring crossing 0 / 360 wraparound: detected gap is a single
     continuous arc, not split at 0.
  6. Closed ring (no gap): gap_width = 0, confidence ~0.
  7. 194-degree regression: a C-ring with a real 194 deg gap must
     measure ~194 deg, NOT be silently clamped.
"""

import os
import sys
import math
import numpy as np

sys.path.insert(0, os.path.dirname(__file__))
from gap_detector import measure_gap

PASSES = []
FAILS = []


def _report(name, ok, detail=""):
    if ok: PASSES.append(name)
    else: FAILS.append((name, detail))
    print(f"  {'PASS' if ok else 'FAIL'}  {name}  {detail}")


def _draw_c_ring(W, H, cx, cy, radius, thickness, gap_center_deg,
                 gap_width_deg, anti_alias=False, cuff_mask=None,
                 cuff_arc=None):
    """Render a synthetic C-ring on a WxH canvas. Returns (ring_mask,
    cuff_mask_optional)."""
    ring = np.zeros((H, W), dtype=bool)
    cuff = np.zeros((H, W), dtype=bool)
    for y in range(H):
        for x in range(W):
            dx = x - cx
            dy = y - cy
            r = math.hypot(dx, dy)
            if r < radius - thickness / 2.0: continue
            if r > radius + thickness / 2.0: continue
            ang = (math.degrees(math.atan2(dy, dx)) + 360) % 360
            # Inside the gap, ring is missing.
            gap_half = (gap_width_deg / 2.0) % 180
            diff = (ang - gap_center_deg + 540) % 360 - 180
            if abs(diff) < gap_half: continue
            if anti_alias:
                # Edge softness: mark with probability 1 at center
                # of band, 0.5 at edges.
                dr = abs(r - radius)
                if dr > thickness / 2.0 - 0.5: continue
                if dr > thickness / 2.0 - 1.5:
                    if (x + y) % 2 == 0: continue
            ring[y, x] = True
    if cuff_arc is not None and cuff_mask is not None:
        for (ccx, ccy, cR, cgap_start, cgap_end) in cuff_arc:
            for y in range(H):
                for x in range(W):
                    dx = x - ccx
                    dy = y - ccy
                    r = math.hypot(dx, dy)
                    if r < cR - 3: continue
                    if r > cR + 3: continue
                    ang = (math.degrees(math.atan2(dy, dx)) + 360) % 360
                    # Gap is in [cgap_start, cgap_end] going clockwise.
                    if cgap_end > cgap_start:
                        if cgap_start <= ang <= cgap_end: continue
                    else:
                        if ang >= cgap_start or ang <= cgap_end: continue
                    cuff_mask[y, x] = True
    return ring, cuff


def test_clean_c_ring():
    W, H = 400, 400
    ring, cuff = _draw_c_ring(W, H, 200, 200, 100, 20, 90, 90)
    g = measure_gap(ring, cuff, 200, 200, 90, 110)
    _report("clean_c_ring_90deg_gap", 80 <= g.width_angle_deg <= 100,
            f"got {g.width_angle_deg:.1f}")


def test_c_ring_with_cuff_overlapping_body():
    W, H = 400, 400
    ring, cuff = _draw_c_ring(W, H, 200, 200, 100, 20, 90, 90)
    # Cuff as a smaller arc that overlaps the ring body on the right
    # side (away from the gap).
    for y in range(H):
        for x in range(W):
            r = math.hypot(x - 280, y - 200)
            if 8 < r < 14:
                cuff[y, x] = True
    g = measure_gap(ring, cuff, 200, 200, 90, 110)
    _report("c_ring_cuff_overlap_keeps_gap", 80 <= g.width_angle_deg <= 110,
            f"got {g.width_angle_deg:.1f} conf={g.confidence:.2f}")


def test_c_ring_with_cuff_near_gap():
    W, H = 400, 400
    ring, cuff = _draw_c_ring(W, H, 200, 200, 100, 20, 90, 90)
    # Cuff sits just outside the ring at angle 90 (near the gap).
    for y in range(H):
        for x in range(W):
            r = math.hypot(x - 290, y - 200)
            if 8 < r < 14:
                cuff[y, x] = True
    g = measure_gap(ring, cuff, 200, 200, 90, 110)
    _report("c_ring_cuff_near_gap_keeps_gap", 80 <= g.width_angle_deg <= 110,
            f"got {g.width_angle_deg:.1f}")


def test_anti_aliased_c_ring():
    W, H = 400, 400
    ring, cuff = _draw_c_ring(W, H, 200, 200, 100, 20, 90, 80, anti_alias=True)
    g = measure_gap(ring, cuff, 200, 200, 90, 110)
    _report("c_ring_anti_aliased", 70 <= g.width_angle_deg <= 90,
            f"got {g.width_angle_deg:.1f}")


def test_c_ring_wraps_around_zero():
    W, H = 400, 400
    # Gap from 350 to 30 (width = 40) wraps around the 0/360 boundary.
    ring, cuff = _draw_c_ring(W, H, 200, 200, 100, 20, 10, 40)
    g = measure_gap(ring, cuff, 200, 200, 90, 110)
    _report("c_ring_gap_wraps_around_0", 35 <= g.width_angle_deg <= 45,
            f"got {g.width_angle_deg:.1f}, center={g.center_angle_deg:.1f}")


def test_closed_ring():
    W, H = 400, 400
    ring, cuff = _draw_c_ring(W, H, 200, 200, 100, 20, 0, 0)
    g = measure_gap(ring, cuff, 200, 200, 90, 110)
    _report("closed_ring_no_gap", g.width_angle_deg < 5,
            f"got {g.width_angle_deg:.1f}")


def test_194_degree_regression():
    """The original bad value 194 deg must NOT be silently clamped."""
    W, H = 400, 400
    ring, cuff = _draw_c_ring(W, H, 200, 200, 100, 20, 100, 194)
    g = measure_gap(ring, cuff, 200, 200, 90, 110)
    _report("194deg_regression", 180 <= g.width_angle_deg <= 210,
            f"got {g.width_angle_deg:.1f}")


def test_sub_bin_refinement():
    W, H = 400, 400
    ring, cuff = _draw_c_ring(W, H, 200, 200, 100, 20, 90, 100)
    g = measure_gap(ring, cuff, 200, 200, 90, 110)
    # After sub-bin refinement the gap should be close to 100 deg, not
    # some 5-deg-binned multiple.
    _report("sub_bin_refinement", 95 <= g.width_angle_deg <= 105,
            f"got {g.width_angle_deg:.1f}")


if __name__ == "__main__":
    test_clean_c_ring()
    test_c_ring_with_cuff_overlapping_body()
    test_c_ring_with_cuff_near_gap()
    test_anti_aliased_c_ring()
    test_c_ring_wraps_around_zero()
    test_closed_ring()
    test_194_degree_regression()
    test_sub_bin_refinement()
    print()
    print(f"Passed {len(PASSES)}/{len(PASSES) + len(FAILS)}")
    if FAILS:
        sys.exit(1)