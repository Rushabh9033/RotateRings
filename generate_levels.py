import random
import math

COLORS = ["#32ADDA", "#EA7829", "#8228D9", "#C8202F", "#62C73E", "#29B6F6", "#F38224", "#7D2AD4", "#4361CF", "#CB2336"]
RADII = [40.0, 76.0, 115.0, 150.0]

def collides(p, r, rings):
    for rp, rr, _, _ in rings:
        dist = math.hypot(p[0]-rp[0], p[1]-rp[1])
        if dist < 10.0: # Concentric
            if abs(r - rr) < 30.0:
                return True
        else: # Non-concentric
            if dist < r + rr + 10.0:
                return True
    return False

def generate_level(lvl_id):
    random.seed(lvl_id * 1000)
    num_rings = min(4 + lvl_id // 5, 12)
    
    rings = [] # (pos, radius, color_idx, initial_rot)
    
    for _ in range(num_rings):
        for _ in range(100):
            if random.random() < 0.25 and rings: # Concentric
                rp, _, _, _ = random.choice(rings)
                p = rp
                r = random.choice(RADII)
            else:
                p = (random.randint(200, 520), random.randint(350, 900))
                r = random.choice(RADII)
            
            if not collides(p, r, rings):
                rings.append((p, r, random.randint(0, len(COLORS)-1), random.uniform(0, 360)))
                break
                
    if len(rings) < 2:
        return ""

    links = []
    gaps = [[] for _ in range(len(rings))]
    
    nodes = list(range(len(rings)))
    random.shuffle(nodes)
    
    anchors = [nodes[0]]
    children = nodes[1:]
    
    steps = []
    
    for c in children:
        num_parents = 1 if random.random() < 0.8 else 2
        num_parents = min(num_parents, len(anchors))
        
        parents = random.sample(anchors, num_parents)
        for p in parents:
            cx, cy = rings[c][0]
            px, py = rings[p][0]
            
            angle_rad = math.atan2(py - cy, px - cx)
            angle_deg = math.degrees(angle_rad) % 360.0
            
            target_rot = random.uniform(0, 360)
            gap_rel = (angle_deg - target_rot) % 360.0
            
            gaps[c].append(gap_rel)
            links.append((p, c))
            steps.append((c, target_rot))
            
        anchors.append(c)
        
    steps.reverse()
    
    gd_str = f"\t\t{lvl_id}:\n"
    gd_str += f"\t\t\tdef.title = \"Level {lvl_id}\"\n"
    gd_str += f"\t\t\tdef.instruction = \"Clear the rings!\"\n"
    gd_str += f"\t\t\tdef.par_moves = {len(steps) + 1}\n"
    
    for i, (pos, r, c_idx, initial_rot) in enumerate(rings):
        gap_strs = []
        for gap_rel in gaps[i]:
            gap_strs.append(f"GapDefinitionScript.new({gap_rel:.1f}, 56.0, 16.0)")
        
        gaps_arr = "[" + ", ".join(gap_strs) + "]"
        gd_str += f"\t\t\tvar r{i} = PieceDefinitionScript.new(&\"ring_{i}\", Vector2({pos[0]:.1f}, {pos[1]:.1f}), {r:.1f}, 24.0, Color(\"{COLORS[c_idx]}\"), {initial_rot:.1f}, {gaps_arr})\n"
        
    gd_str += "\t\t\tdef.pieces = [" + ", ".join([f"r{i}" for i in range(len(rings))]) + "]\n"
    
    gd_str += "\t\t\tdef.links = [\n"
    for idx, (p, c) in enumerate(links):
        gd_str += f"\t\t\t\tLinkDefinitionScript.new(&\"link_{idx}\", &\"ring_{p}\", &\"ring_{c}\", Color(\"{COLORS[rings[p][2]]}\"))"
        if idx < len(links) - 1:
            gd_str += ",\n"
        else:
            gd_str += "\n"
    gd_str += "\t\t\t]\n"
    
    gd_str += "\t\t\tdef.canonical_steps = [\n"
    for idx, (c, target_rot) in enumerate(steps):
        gd_str += f"\t\t\t\tSolutionStepScript.new(&\"ring_{c}\", {target_rot:.1f}, true)"
        if idx < len(steps) - 1:
            gd_str += ",\n"
        else:
            gd_str += "\n"
    gd_str += "\t\t\t]\n\n"
    
    return gd_str

with open('levels_13_to_50.gd', 'w') as f:
    for i in range(13, 51):
        f.write(generate_level(i))
