def clamp_ring_rotation(current_rot, target_rot, cuff_world_angle, gap_center, gap_width, cuff_half_width=12.0):
    # A ring has a gap [gap_center - gap_width/2, gap_center + gap_width/2]
    # Solid body is [gap_center + gap_width/2, gap_center + 360 - gap_width/2]
    # In local space, cuff angle is: alpha = (cuff_world_angle - rot) % 360
    # The valid range of alpha is:
    # From (gap_center - gap_width/2) to (gap_center + 360 - gap_width/2)
    # Notice: the whole 360 is covered except the exterior of the gap!
    # Wait, the gap is [G - W/2, G + W/2], which is an arc of width W (e.g. 56 deg).
    # The solid body is width 360 - W (e.g. 304 deg).
    # Together, the gap AND the solid body cover ALL 360 degrees of the circle!
    # But wait! If the ring is threaded through the cuff:
    # Can the cuff exit the gap and re-enter from the other side?
    # No! If the ring is rotated so the cuff enters the gap, it reaches the unlock orientation!
    # But if the ring rotates AWAY from the gap:
    # The cuff traverses the 304 deg of solid body until it reaches the other edge of the gap!
    pass

print("Testing blocker logic")
