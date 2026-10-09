extends Node2D
# Pixel-accurate reconstruction of the supplied reference image: two C-shaped rings
# (blue left, orange right) joined by a small rectangular cuff.
#
# All geometry parameters are pulled from data/ring_visuals.gd so the gameplay
# math and the rendered visual are derived from a single source.

const RingVisuals = preload("res://data/ring_visuals.gd")
const Database = preload("res://data/level_database.gd")

# Reference-space centers (taken from tools/measure_geom.py) re-projected into
# the gameplay 1080x675 viewport by anchoring the bottom-right of the reference
# image to the gameplay viewport's top region.
const PINK_REF_X: float = 117.0
const PINK_REF_Y: float = 103.0
const ORANGE_REF_X: float = 158.0
const ORANGE_REF_Y: float = 104.0
const CUFF_REF_X: float = 160.0
const CUFF_REF_Y: float = 105.0

# Scale: 1 reference unit -> 1 game pixel. The reference is 315x217 which is
# roughly 0.46 of the gameplay's top 480 pixels, so we offset it down a bit.
const REF_SCALE: float = 2.6

const PINK_X: float = (PINK_REF_X - RingVisuals.REF_VIEW_W * 0.5) * REF_SCALE + RingVisuals.GAME_VIEW_W * 0.5
const PINK_Y: float = (PINK_REF_Y - RingVisuals.REF_VIEW_H * 0.5) * REF_SCALE + 280.0
const ORANGE_X: float = (ORANGE_REF_X - RingVisuals.REF_VIEW_W * 0.5) * REF_SCALE + RingVisuals.GAME_VIEW_W * 0.5
const ORANGE_Y: float = (ORANGE_REF_Y - RingVisuals.REF_VIEW_H * 0.5) * REF_SCALE + 280.0
const CUFF_X: float = (CUFF_REF_X - RingVisuals.REF_VIEW_W * 0.5) * REF_SCALE + RingVisuals.GAME_VIEW_W * 0.5
const CUFF_Y: float = (CUFF_REF_Y - RingVisuals.REF_VIEW_H * 0.5) * REF_SCALE + 280.0

const R: float = RingVisuals.RING_RADIUS
const T: float = RingVisuals.RING_THICKNESS
const GAP_DEG: float = RingVisuals.GAP_DEG
const CAP_R: float = RingVisuals.CAP_RADIUS
const SEG: int = RingVisuals.SEGMENTS

const CUFF_W: float = 22.0
const CUFF_H: float = 16.0
const CUFF_COLOR: Color = Color(0.078, 0.420, 0.690, 1.0)
const CUFF_DARK:  Color = Color(0.043, 0.235, 0.435, 1.0)
const CUFF_HI:    Color = Color(0.290, 0.640, 0.890, 1.0)

const SHADOW_OFFSET: Vector2 = RingVisuals.SHADOW_OFFSET
const SHADOW_ALPHA: float = RingVisuals.SHADOW_COLOR.a
const SHADOW_RGBA: Color = Color(RingVisuals.SHADOW_COLOR.r, RingVisuals.SHADOW_COLOR.g, RingVisuals.SHADOW_COLOR.b, SHADOW_ALPHA)

const CUFF_INSET_W: float = 1.5
const CUFF_INSET_H: float = 1.0

var pink_angle: float = 0.0
var orange_angle: float = 0.0

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	# Drop shadow under both rings and the cuff.
	_draw_ring_shadow(PINK_X, PINK_Y)
	_draw_ring_shadow(ORANGE_X, ORANGE_Y)
	_draw_cuff_shadow()

	# Rings (lower-shade, main body, upper-highlight).
	_draw_ring(PINK_X, PINK_Y, pink_angle, false)
	_draw_ring(ORANGE_X, ORANGE_Y, orange_angle, true)

	# Central cuff.
	_draw_cuff()

func _draw_ring_shadow(cx: float, cy: float) -> void:
	# Slightly fatter, fully-closed ring offset by (0, 4) with low alpha.
	var pts := PackedVector2Array()
	var rr: float = R + T * 0.45
	for i in range(SEG + 1):
		var theta: float = TAU * float(i) / float(SEG)
		pts.append(Vector2(cx, cy + SHADOW_OFFSET.y) + Vector2(cos(theta), sin(theta)) * rr)
	draw_polyline(pts, SHADOW_RGBA, T * 1.7, true)

func _draw_cuff_shadow() -> void:
	var shadow_rect := Rect2(
		CUFF_X - CUFF_W * 0.5 + SHADOW_OFFSET.x - CUFF_INSET_W * 0.5,
		CUFF_Y - CUFF_H * 0.5 + SHADOW_OFFSET.y + 1.0,
		CUFF_W + CUFF_INSET_W,
		CUFF_H + CUFF_INSET_H
	)
	draw_rect(shadow_rect, SHADOW_RGBA, true)

func _draw_ring(cx: float, cy: float, start_angle_deg: float, is_orange: bool) -> void:
	# Pick the matching palette.
	var c_main: Color
	var c_dark: Color
	var c_hi: Color
	if is_orange:
		c_main = RingVisuals.REF_L1_ORANGE_COLOR
		c_dark = RingVisuals.REF_L1_ORANGE_DARK
		c_hi   = RingVisuals.REF_L1_ORANGE_HI
	else:
		c_main = RingVisuals.REF_L1_PINK_COLOR
		c_dark = RingVisuals.REF_L1_PINK_DARK
		c_hi   = RingVisuals.REF_L1_PINK_HI

	# The visible arc spans (gap center - half) to (gap center + half) going
	# around the LONG way (so the visible arc covers 360 - gap_deg).
	#   blue  ring  : world gap center = 180° (gap opens left)
	#   orange ring  : world gap center = 0°   (gap opens right)
	var local_gap_center_deg: float = 180.0 if not is_orange else 0.0
	var gap_half: float = GAP_DEG * 0.5
	var world_gap_center: float = start_angle_deg + local_gap_center_deg
	var a_start: float = deg_to_rad(world_gap_center + gap_half)
	var a_end:   float = deg_to_rad(world_gap_center - gap_half) + TAU  # long way

	var pts_dark := PackedVector2Array()
	var pts_main := PackedVector2Array()
	var pts_hi   := PackedVector2Array()
	var off_dark: Vector2 = Vector2(0.0, 2.4)
	var off_hi:   Vector2 = Vector2(-1.0, -2.0)
	var step: float = (a_end - a_start) / float(SEG)
	for i in range(SEG + 1):
		var theta: float = a_start + step * float(i)
		var unit := Vector2(cos(theta), sin(theta))
		var on_arc: Vector2 = Vector2(cx, cy) + unit * R
		pts_dark.append(on_arc + off_dark)
		pts_main.append(on_arc)
		pts_hi.append(on_arc + off_hi)
	# Lower-edge darker stroke.
	draw_polyline(pts_dark, c_dark, T * 1.05, true)
	# Main body stroke.
	draw_polyline(pts_main, c_main, T * 0.95, true)
	# Upper highlight (thinner).
	draw_polyline(pts_hi, c_hi, T * 0.42, true)

	# Round caps at the two ends of the visible arc.
	var end_a := Vector2(cx, cy) + Vector2(cos(a_start), sin(a_start)) * R
	var end_b := Vector2(cx, cy) + Vector2(cos(a_end),   sin(a_end))   * R
	draw_circle(end_a, CAP_R, c_main)
	draw_circle(end_a + off_dark, CAP_R * 0.65, c_dark)
	draw_circle(end_b, CAP_R, c_main)
	draw_circle(end_b + off_dark, CAP_R * 0.65, c_dark)
	draw_circle(end_a + off_hi, CAP_R * 0.45, c_hi)
	draw_circle(end_b + off_hi, CAP_R * 0.45, c_hi)

func _draw_cuff() -> void:
	var rect_main := Rect2(CUFF_X - CUFF_W * 0.5, CUFF_Y - CUFF_H * 0.5, CUFF_W, CUFF_H)
	var rect_dark := Rect2(rect_main.position + Vector2(0, 1.5), rect_main.size)
	var rect_hi   := Rect2(rect_main.position + Vector2(-0.5, -1.0), rect_main.size - Vector2(1.0, 2.0))
	draw_rect(rect_dark, CUFF_DARK, true)
	draw_rect(rect_main, CUFF_COLOR, true)
	draw_rect(rect_hi, CUFF_HI, true)
