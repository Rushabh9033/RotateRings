extends SceneTree

const Board = preload("res://data/campaign_board.gd")
const Rules = preload("res://gameplay/puzzle_rules.gd")

func _init():
    Board._defer_solve = true
    for level_id in range(1, 51):
        var def = Board.build(level_id)
        var built = Board._spawn(def)
        for piece in built.pieces:
            if piece.gaps.is_empty():
                continue
            for link in built.links:
                var contact = -999.0
                if link.def.to_piece_id == piece.piece_id:
                    contact = Rules.cuff_world_angle_deg(piece, link, built.pieces)
                elif link.def.from_piece_id == piece.piece_id:
                    var child = Rules.get_piece_by_id(link.def.to_piece_id, built.pieces)
                    contact = rad_to_deg((child.position - piece.position).angle())
                
                if contact > -999.0:
                    for gap in piece.gaps:
                        var mouth = fposmod(piece.rotation_degrees + float(gap.center_angle_deg), 360.0)
                        var off = absf(wrapf(mouth - float(contact), -180.0, 180.0))
                        var need = float(gap.width_deg) * 0.5 + 35.0
                        if off < need - 0.01:
                            print("L%d %s contact=%.1f off=%.1f need=%.1f" % [level_id, piece.piece_id, contact, off, need])
    quit()
