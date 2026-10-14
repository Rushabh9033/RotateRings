import json
import numpy as np

# Coordinates mapping from 14.jpeg (685x1170) to Godot (720x1280)
def to_godot(rx, ry, img_w=685, img_h=1170):
    gx = (rx / img_w) * 720.0
    gy = (ry / img_h) * 1280.0
    return round(gx, 1), round(gy, 1)

# Raw centers in 14.jpeg
cols_raw = [176.0, 342.0, 507.0]
rows_raw = [315.0, 477.0, 642.0, 807.0]

# Standard colors
COLORS = {
    "orange": {"name": "orange", "hex": "#EA7829"},
    "green":  {"name": "green",  "hex": "#27AE60"},
    "purple": {"name": "purple", "hex": "#7B61FF"},
    "blue":   {"name": "blue",   "hex": "#2F80ED"},
    "cyan":   {"name": "cyan",   "hex": "#32ADDA"},
    "red":    {"name": "red",    "hex": "#E63946"},
}

# Grid definition: 4 rows x 3 columns = 12 rings
# [row][col]
grid_rings = [
    # Row 0:
    [
        {"id": "orange_r0c0", "color": "orange", "gap": 270.0, "width": 90.0, "has_acorn": False},
        {"id": "green_r0c1",  "color": "green",  "gap": 270.0, "width": 90.0, "has_acorn": False},
        {"id": "purple_r0c2", "color": "purple", "gap": 270.0, "width": 90.0, "has_acorn": True},
    ],
    # Row 1:
    [
        {"id": "purple_r1c0", "color": "purple", "gap": 195.0, "width": 90.0, "has_acorn": False},
        {"id": "orange_r1c1", "color": "orange", "gap": 270.0, "width": 90.0, "has_acorn": False},
        {"id": "red_r1c2",    "color": "red",    "gap": 345.0, "width": 90.0, "has_acorn": False},
    ],
    # Row 2:
    [
        {"id": "blue_r2c0",   "color": "blue",   "gap": 168.0, "width": 90.0, "has_acorn": False},
        {"id": "cyan_r2c1",   "color": "cyan",   "gap": 90.0,  "width": 90.0, "has_acorn": False},
        {"id": "green_r2c2",  "color": "green",  "gap": 25.0,  "width": 90.0, "has_acorn": True},
    ],
    # Row 3:
    [
        {"id": "green_r3c0",  "color": "green",  "gap": 90.0,  "width": 90.0, "has_acorn": True},
        {"id": "cyan_r3c1",   "color": "cyan",   "gap": 90.0,  "width": 90.0, "has_acorn": False},
        {"id": "red_r3c2",    "color": "red",    "gap": 90.0,  "width": 90.0, "has_acorn": False},
    ],
]

# Calculate Godot positions
positions = {}
pieces = []

for r_idx in range(4):
    for c_idx in range(3):
        r_info = grid_rings[r_idx][c_idx]
        rx = cols_raw[c_idx]
        ry = rows_raw[r_idx]
        gx, gy = to_godot(rx, ry)
        positions[r_info["id"]] = (gx, gy)
        
        # Release directions:
        # Top row releases UP (-Y)
        # Bottom row releases DOWN (+Y)
        # Row 1 releases UP/SIDE
        # Row 2 releases DOWN/SIDE
        if r_idx == 0:
            rel_dir = {"x": 0.0, "y": -1.0}
        elif r_idx == 3:
            rel_dir = {"x": 0.0, "y": 1.0}
        elif c_idx == 0:
            rel_dir = {"x": -1.0, "y": 0.0}
        elif c_idx == 2:
            rel_dir = {"x": 1.0, "y": 0.0}
        else:
            rel_dir = {"x": 0.0, "y": -1.0}
            
        pieces.append({
            "id": r_info["id"],
            "color_name": r_info["color"],
            "color_hex": COLORS[r_info["color"]]["hex"],
            "x": gx,
            "y": gy,
            "start_angle_deg": 0.0,
            "radius": 60.0,
            "radius_y": 60.0,
            "thickness": 20.0,
            "shape_type": 0,
            "piece_type": 1,
            "role": 0,
            "z_index": 1,
            "initially_locked": False,
            "locked": False,
            "property_locks": {},
            "release_direction": rel_dir,
            "target_exit_angle_deg": 0.0,
            "motion_model": 0,
            "gaps": [
                {
                    "center_angle_deg": r_info["gap"],
                    "width_deg": r_info["width"],
                    "tolerance_deg": 16.0
                }
            ]
        })

# Define the 16 links: (parent_id, child_id)
# Parent emits the stem and grips child with collar
links_def = [
    # Row 0 parents:
    ("orange_r0c0", "green_r0c1"),
    ("orange_r0c0", "purple_r1c0"),
    ("green_r0c1",  "purple_r1c0"),
    ("green_r0c1",  "red_r1c2"),
    ("purple_r0c2", "red_r1c2"),
    # Row 1 parent:
    ("orange_r1c1", "purple_r1c0"),
    ("orange_r1c1", "red_r1c2"),
    ("orange_r1c1", "cyan_r2c1"),
    # Row 2 parents:
    ("blue_r2c0",   "purple_r1c0"),
    ("green_r2c2",  "red_r1c2"),
    # Row 3 parents:
    ("green_r3c0",  "blue_r2c0"),
    ("green_r3c0",  "cyan_r2c1"),
    ("red_r3c2",    "cyan_r2c1"),
    ("red_r3c2",    "green_r2c2"),
    ("cyan_r3c1",   "green_r3c0"),
    ("cyan_r3c1",   "red_r3c2"),
]

links = []
for p1, p2 in links_def:
    x1, y1 = positions[p1]
    x2, y2 = positions[p2]
    d = np.hypot(x2 - x1, y2 - y1)
    # angle on parent pointing towards child:
    ang = np.degrees(np.arctan2(y2 - y1, x2 - x1)) % 360
    
    # joint color matches parent ring
    col_name = next(p["color_name"] for p in pieces if p["id"] == p1)
    col_hex = COLORS[col_name]["hex"]
    
    links.append({
        "id": f"link_{p1}_to_{p2}",
        "from_id": p1,
        "to_id": p2,
        "from_piece_id": p1,
        "to_piece_id": p2,
        "collar_angle_deg": round(ang, 1),
        "stem_dist": round(d, 1),
        "joint_color": col_name,
        "joint_color_name": col_name,
        "joint_color_hex": col_hex
    })

level_14 = {
    "id": 14,
    "title": "Level 14",
    "instruction": "",
    "par_moves": 16,
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
    "links": links
}

with open("data/user_levels/14.json", "w") as f:
    json.dump(level_14, f, indent=2)

print("Generated data/user_levels/14.json successfully with 12 rings and 16 links!")
