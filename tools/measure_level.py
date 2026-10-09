"""
measure_level.py — per-color measurement of a reference level image.

Usage:  python -I tools/measure_level.py <level_id>
Reads:  ALL 2to100 levels/<id>.jpeg
Writes: tools/measure_level_<id>.json

Color palette: orange, cyan, purple, red, green, blue, yellow, pink,
cuff_blue, cuff. We measure each color's largest connected component
(after a 4-px morphological close so the ring body and its anti-aliased
inner highlight merge). Returns bbox + center in image coordinates.
"""
import sys
import json
import numpy as np
from PIL import Image
import scipy.ndimage as ndi


def measure(image_path: str, colors: dict, dilate_iterations: int = 4,
            min_area: int = 200):
    img = Image.open(image_path).convert('RGB')
    arr = np.array(img)
    H, W, _ = arr.shape

    def close(c, target, tol=50):
        return all(abs(int(c[i]) - int(target[i])) <= tol for i in range(3))

    masks = {}
    for name, target in colors.items():
        m = np.zeros((H, W), dtype=bool)
        for y in range(H):
            for x in range(W):
                if close(arr[y, x], target):
                    m[y, x] = True
        masks[name] = ndi.binary_closing(m, iterations=dilate_iterations)

    def components(mask):
        lbl, n = ndi.label(mask)
        out = []
        for i in range(1, n + 1):
            ys, xs = np.where(lbl == i)
            if len(ys) < min_area:
                continue
            x0, x1 = int(xs.min()), int(xs.max())
            y0, y1 = int(ys.min()), int(ys.max())
            cx = (x0 + x1) / 2.0
            cy = (y0 + y1) / 2.0
            out.append({
                "x0": x0, "y0": y0, "x1": x1, "y1": y1,
                "cx": cx, "cy": cy,
                "w": x1 - x0 + 1, "h": y1 - y1 + 1,
                "area": int((lbl == i).sum()),
            })
        out.sort(key=lambda d: -d['area'])
        return out

    result = {"image_size": [W, H]}
    for name in colors:
        comps = components(masks[name])
        result[name] = comps[:6]

    puzzle = np.zeros((H, W), dtype=bool)
    for name in masks:
        puzzle |= masks[name]
    ys, xs = np.where(puzzle)
    if len(ys) > 0:
        result["puzzle_bbox"] = {
            "x0": int(xs.min()), "y0": int(ys.min()),
            "x1": int(xs.max()), "y1": int(ys.max()),
            "cx": float((xs.min() + xs.max()) / 2),
            "cy": float((ys.min() + ys.max()) / 2),
        }
    return result


def main():
    if len(sys.argv) < 2:
        print("usage: python -I tools/measure_level.py <level_id>")
        sys.exit(1)
    level_id = int(sys.argv[1])

    # The 8-color palette we use in JSON.
    palette = {
        "orange":     (234, 120, 41),
        "cyan":       (50, 173, 218),
        "purple":     (123, 97, 255),
        "red":        (200, 32, 47),
        "green":      (62, 198, 176),
        "blue":       (31, 90, 130),
        "yellow":     (244, 201, 93),
        "pink":       (242, 166, 181),
    }

    image_path = f"D:\\AI secound Brain\\RotateRings\\ALL 2to100 levels\\{level_id}.jpeg"
    result = measure(image_path, palette)
    out_path = f"D:\\AI secound Brain\\RotateRings\\tools\\measure_level_{level_id}.json"
    with open(out_path, "w") as f:
        json.dump(result, f, indent=2)

    print(f"Reference {level_id}.jpeg: {result['image_size']}")
    for name, comps in result.items():
        if name in ('image_size', 'puzzle_bbox'):
            continue
        if not comps:
            print(f"  {name}: (none)")
            continue
        c = comps[0]
        print(f"  {name}: bbox=({c['x0']},{c['y0']})-({c['x1']},{c['y1']})  "
              f"size={c['w']}x{c['h']}  center=({c['cx']:.0f},{c['cy']:.0f})  area={c['area']}")
    if 'puzzle_bbox' in result:
        b = result['puzzle_bbox']
        print(f"  puzzle: bbox=({b['x0']},{b['y0']})-({b['x1']},{b['y1']})  center=({b['cx']:.0f},{b['cy']:.0f})")
    print(f"Saved {out_path}")


if __name__ == "__main__":
    main()
