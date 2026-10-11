# Level-from-Image Skill

**Purpose**: Auto-detect a RotateRings level from a single screenshot and emit a valid `data/user_levels/N.json`. Eliminates the manual JSON-editing loop that caused the Phase 11 L2 visual mistakes.

## When to use

Use this skill when:
- A user shows you a screenshot of a RotateRings level and asks you to implement it
- A user has a new level design and wants it loaded into the engine
- You need to bulk-process many reference images from `ALL 2to100 levels/`

## How to invoke

```
python tools/level_from_image.py <image_path> [level_id]
```

Defaults:
- `level_id` = 2
- Output path: `data/user_levels/<level_id>.json`
- Verification: runs `tools/test_solvable_l2_l3.gd` after writing

Example:
```bash
python tools/level_from_image.py "D:\AI secound Brain\RotateRings\ALL 2to100 levels\3.jpeg" 3
```

## What the skill does

1. **HSV color segmentation** per RotateRings palette color
   - Palette: orange #EA7829, cyan #32ADDA, purple #7B61FF, red, green, yellow, pink, cuff_blue #1F5A82
   - Hue tolerance 18°, saturation floor 0.30, value tolerance 0.45
   - Reuses `tools/color_segmentation.py`

2. **Per-color connected-component extraction**
   - Largest component per color is the ring body
   - Rejects components smaller than 30 pixels

3. **Per-ring geometry** (RANSAC + radial histogram)
   - `cx, cy`: ring center (RANSAC circle fit)
   - `r_inner, r_outer`: inner/outer radius from radial histogram
   - `thickness = r_outer - r_inner`

4. **Per-ring gap direction** (polar histogram, 72 bins)
   - Finds the angular bin with the lowest ring-body occupancy
   - Reports `gap_center_deg` and `gap_width_deg`

5. **Cuff detection** (small dark-blue rectangles between rings)
   - HSV-segments the cuff color
   - Finds connected components
   - For each cuff, finds the two nearest ring centers and reports the parent→child link

6. **Link geometry** (auto-derived)
   - `collar_angle_deg` = atan2(child.center - parent.center) in Godot screen convention
   - Gap direction at the link = OPPOSITE of collar_angle (gap faces away from connected ring, matching the original reference where gaps face the OUTER edge of the triangle)
   - Cuff color = parent color (orange↔blue connector is orange, etc.)

7. **Coordinate conversion** (ref → canonical)
   - Multiplies x by 720/685 and y by 1280/1170
   - 685×1170 reference images map to 720×1280 canonical canvas

8. **Verification** (optional, on by default)
   - Calls `godot --headless --script res://tools/test_solvable_l2_l3.gd`
   - Reports whether the level BFS-solves
   - If it doesn't, the user can iterate

## Output format

Modern RotateRings schema (read by `LevelDatabase.get_level(N)`):
- Top-level `pieces[]`: each ring with `id`, `color_hex`, `x`, `y`, `radius`, `thickness`, `gaps[]`
- Top-level `links[]`: each connector with `from_id`, `to_id`, `collar_angle_deg`, `joint_color_hex`, `cuff_*`, `stem_*`

## Limitations

- **Color confusion**: if the input image has shadows or unusual lighting, the HSV segmentation may group wrong pixels. The skill tries `build_color_masks_hsv` which handles highlights and shadows to some extent, but very dark or bright images may need manual review.
- **Touching rings**: if two rings overlap, RANSAC will fit a single circle to the combined blob. The skill picks the largest component per color, so overlapping same-color rings would be one piece. For the L2 example this is fine.
- **Non-palette colors**: if the screenshot uses a color not in the 8-color palette, the skill will snap to the closest palette entry via Euclidean distance in RGB. This is the same fallback the engine's `color_name_static` was supposed to do.
- **Cuff orientation**: the cuff is placed at the geometric midpoint between the two ring edges. The original RotateRings reference images show cuffs at the rings' gap positions, not at the midpoint. The current skill does NOT replicate the "cuff-in-gap" effect — that would require an engine change.

## Examples

### Example 1: implement a new level from a screenshot

```bash
# User shows you 5.jpeg and asks for level 5
python tools/level_from_image.py "ALL 2to100 levels/5.jpeg" 5
# Output: data/user_levels/5.json
# Verification: PASS / FAIL line from Godot solver
```

### Example 2: bulk-process a folder

```bash
# For all jpegs in ALL 2to100 levels/, save as user_levels/<filename>_index.json
for f in "ALL 2to100 levels/"*.jpeg; do
  name=$(basename "$f" .jpeg)
  python tools/level_from_image.py "$f" --out "data/user_levels/_auto_${name}.json"
done
```

## Files

- `tools/level_from_image.py` — the skill implementation
- `tools/LEVEL_FROM_IMAGE_SKILL.md` — this file
- `tools/color_segmentation.py` — reused for HSV segmentation
- `tools/test_solvable_l2_l3.gd` — reused for verification

## Version

- Skill created: Phase 12 (Oct 2026)
- Tested on: L2 reference image (`2.jpeg`)
- Output: `data/user_levels/2.json` re-generated from image
