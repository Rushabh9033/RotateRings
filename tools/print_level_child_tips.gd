extends SceneTree

const Board = preload("res://data/campaign_board.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")

func _init():
    Board._defer_solve = true
    for level_id in range(6, 12):
        var def = Board.build(level_id)
        var built = Board._spawn(def)
        for link in built.links:
            var child = Rules.get_piece_by_id(link.def.to_piece_id, built.pieces)
            if child == null or child.gaps.is_empty():
                continue
            
            var contact = Rules.cuff_world_angle_deg(child, link, built.pieces)
            for gap in child.gaps:
                var mouth = fposmod(child.rotation_degrees + float(gap.center_angle_deg), 360.0)
                var off = absf(wrapf(mouth - contact, -180.0, 180.0))
                var need = float(gap.width_deg) * 0.5 + 35.0
                print("L%d child %s off=%.1f need=%.1f turn=%.1f" % [level_id, child.piece_id, off, need, Board._authored_turn(def, child.piece_id)])
    quit()
