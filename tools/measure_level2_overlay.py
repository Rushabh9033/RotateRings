"""
Render the measured bboxes + centers on top of the reference image.
Confirms we are correctly identifying each piece.
"""
from PIL import Image, ImageDraw, ImageFont
import json

img = Image.open(r'D:\AI secound Brain\RotateRings\ALL 2to100 levels\2.jpeg').convert('RGB')
W, H = img.size
draw = ImageDraw.Draw(img)

d = json.load(open(r'D:\AI secound Brain\RotateRings\tools\measure_level2.json', 'r'))

# Combined bbox of orange (arc1 + arc2)
o1 = d['orange'][0]
o2 = d['orange'][1]
orange_bbox = (min(o1['x0'], o2['x0']), min(o1['y0'], o2['y0']),
               max(o1['x1'], o2['x1']), max(o1['y1'], o2['y1']))
orange_cx = (orange_bbox[0] + orange_bbox[2]) / 2
orange_cy = (orange_bbox[1] + orange_bbox[3]) / 2

# Same for cyan
c1 = d['cyan'][0]
c2 = d['cyan'][1]
cyan_bbox = (min(c1['x0'], c2['x0']), min(c1['y0'], c2['y0']),
             max(c1['x1'], c2['x1']), max(c1['y1'], c2['y1']))
cyan_cx = (cyan_bbox[0] + cyan_bbox[2]) / 2
cyan_cy = (cyan_bbox[1] + cyan_bbox[3]) / 2

p = d['purple'][0]
purple_cx = (p['x0'] + p['x1']) / 2
purple_cy = (p['y0'] + p['y1']) / 2

print(f"ORANGE: bbox={orange_bbox}  center=({orange_cx:.0f},{orange_cy:.0f})")
print(f"CYAN:   bbox={cyan_bbox}    center=({cyan_cx:.0f},{cyan_cy:.0f})")
print(f"PURPLE: bbox=({p['x0']},{p['y0']})-({p['x1']},{p['y1']})  center=({purple_cx:.0f},{purple_cy:.0f})")
print(f"PUZZLE bbox: {d['puzzle_bbox']}")

# Draw rectangles and labels
def draw_piece(label, bbox, cx, cy, color):
    draw.rectangle(bbox, outline=color, width=3)
    draw.ellipse((cx-6, cy-6, cx+6, cy+6), fill=color)
    draw.text((cx + 8, cy - 8), label, fill=color)

draw_piece("ORANGE", orange_bbox, orange_cx, orange_cy, (255, 0, 0))
draw_piece("CYAN",   cyan_bbox,   cyan_cx,   cyan_cy,   (0, 0, 255))
draw_piece("PURPLE", (p['x0'], p['y0'], p['x1'], p['y1']), purple_cx, purple_cy, (128, 0, 128))

# Mark all cuff dark-blue pixels by drawing small dots over them.
for cuff in d['cuff']:
    cx, cy = cuff['cx'], cuff['cy']
    draw.ellipse((cx-4, cy-4, cx+4, cy+4), fill=(0, 200, 0))

img.save(r'D:\AI secound Brain\RotateRings\tools\measure_level2_overlay.png')
print("\nSaved tools/measure_level2_overlay.png")
