import math

def wrap180(a):
    return (a + 180.0) % 360.0 - 180.0

def fposmod(a, m):
    return a % m

class Ring:
    def __init__(self, id, pos, radius, start_angle, gaps):
        self.id = id
        self.pos = pos
        self.radius = radius
        self.angle = start_angle
        self.gaps = gaps # list of (center, span)
    
    def is_in_gap(self, angle_deg):
        for g_center, g_span in self.gaps:
            rel = (angle_deg - self.angle - g_center + 180.0) % 360.0 - 180.0
            if abs(rel) <= (g_span * 0.5 + 4.0):
                return True
        return False

# Level 5 pieces:
# Coordinates in 720x1280 space
pieces = {
    "orange": Ring("orange", (250, 340), 76.0, 315.0, [(0.0, 56.0)]),
    "cyan": Ring("cyan", (440, 370), 76.0, 0.0, [(0.0, 56.0)]),
    "purple": Ring("purple", (320, 520), 76.0, 270.0, [(0.0, 56.0)]),
    "red": Ring("red", (140, 660), 76.0, 180.0, [(0.0, 56.0)]),
    "lightgreen": Ring("lightgreen", (360, 710), 76.0, 90.0, [(0.0, 56.0)]),
    "blue": Ring("blue", (280, 890), 76.0, 90.0, [(0.0, 56.0)]),
    "darkgreen": Ring("darkgreen", (550, 600), 76.0, 0.0, [(0.0, 56.0)]),
}

# Links:
# 1. cyan -> orange
# 2. purple -> cyan
# 3. purple -> lightgreen
# 4. red -> purple
# 5. darkgreen -> lightgreen
# 6. lightgreen -> blue

links = [
    ("cyan", "orange"),
    ("purple", "cyan"),
    ("purple", "lightgreen"),
    ("red", "purple"),
    ("darkgreen", "lightgreen"),
    ("lightgreen", "blue"),
]

print("=== CHECKING SPAWN CUFF-IN-GAP ===")
any_error = False
for from_id, to_id in links:
    p_from = pieces[from_id]
    p_to = pieces[to_id]
    dx = p_to.pos[0] - p_from.pos[0]
    dy = p_to.pos[1] - p_from.pos[1]
    stem_angle = math.degrees(math.atan2(dy, dx)) % 360.0
    stem_dist = math.hypot(dx, dy)
    
    # Cuff pos:
    cuff_x = p_from.pos[0] + math.cos(math.radians(stem_angle)) * (stem_dist - p_to.radius)
    cuff_y = p_from.pos[1] + math.sin(math.radians(stem_angle)) * (stem_dist - p_to.radius)
    
    # Angle on child piece:
    child_rel_angle = math.degrees(math.atan2(cuff_y - p_to.pos[1], cuff_x - p_to.pos[0])) % 360.0
    in_gap = p_to.is_in_gap(child_rel_angle)
    print(f"Link {from_id} -> {to_id}: cuff on child at {child_rel_angle:.1f}°, child angle {p_to.angle}°, in gap? {in_gap}")
    if in_gap:
        any_error = True

if any_error:
    print("❌ ERROR: Some cuff spawns inside a gap!")
else:
    print("✅ SUCCESS: All cuffs clamp solid ring bodies! Zero cuffs spawn in gaps.")
