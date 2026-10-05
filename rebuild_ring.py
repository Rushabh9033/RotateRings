with open("old_ring_piece.gd", "r", encoding="utf-8") as f:
    old_text = f.read()

with open("D:/AI secound Brain/RotateRings/gameplay/ring_piece_2d.gd", "r", encoding="utf-8") as f:
    new_text = f.read()

# new_text only has up to _draw_poly_arc. We will append the missing methods from old_text.
# Find where get_distance_to_ring starts in old_text
import re
match = re.search(r'func get_distance_to_ring\(', old_text)
if match:
    missing_methods = old_text[match.start():]
    
    # We must also inject `shape_type` into setup()
    # Let's write a fully patched ring_piece_2d.gd
    
    # First, fix `def.shape_type` in new_text to `shape_type`
    new_text = new_text.replace('def.shape_type', 'shape_type')
    
    # Inject shape_type property
    new_text = new_text.replace(
        'var thickness: float = 24.0',
        'var thickness: float = 24.0\nvar shape_type: int = 0'
    )
    
    # In setup():
    setup_old = 'thickness = float(def.get("thickness")) if def.get("thickness") != null else 24.0'
    setup_new = setup_old + '\n\tshape_type = def.shape_type if "shape_type" in def else 0'
    new_text = new_text.replace(setup_old, setup_new)
    
    # In missing_methods, replace `radius` with `PieceGeometry.get_world_boundary_distance(shape_type, radius, global_rotation, target_world_angle_deg)` where appropriate!
    # Wait, get_distance_to_ring uses `global_pt`
    # old: `var dist_from_center: float = (global_pt - global_position).length()`
    # old: `return absf(dist_from_center - (radius * global_scale.x))`
    dist_old = 'return absf(dist_from_center - (radius * global_scale.x))'
    dist_new = 'var angle = (global_pt - global_position).angle()\n\tvar b_dist = PieceGeometry.get_world_boundary_distance(shape_type, radius, global_rotation, angle)\n\treturn absf(dist_from_center - (b_dist * global_scale.x))'
    missing_methods = missing_methods.replace(dist_old, dist_new)
    
    final_text = new_text + "\n" + missing_methods
    
    with open("D:/AI secound Brain/RotateRings/gameplay/ring_piece_2d.gd", "w", encoding="utf-8") as f:
        f.write(final_text)
