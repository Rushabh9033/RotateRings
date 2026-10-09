extends RefCounted
class_name RingVisuals
# === Reference image measurements (1080x675 viewport) ===
# Geometry constants for the rotating ring. Both the gameplay radius/thickness
# (used by PieceDefinition in json_to_gd.py) and the _draw math in ring_piece_2d.gd
# read from this single source so a piece's collision and its render are guaranteed
# to match.
#
# === Geometry values derived from the supplied reference image (315x217) ===
# All ring parameters are stored in REFERENCE units so the gameplay and render
# parameters come from the SAME constants. The reference-level viewer
# (ReferenceLevel.gd) uses these to position the rings at 1:1 with the
# user-supplied 1080x675 sprite, while the test-render in tools/compare_reference.py
# uses the raw reference-space values (315x217) for pixel diffing.
const RING_RADIUS: float = 90.0          # centerline radius (mid-tube)
const RING_THICKNESS: float = 18.0       # tube thickness
const GAP_DEG: float = 60.0              # opening width (matches reference)
const CAP_RADIUS: float = RING_THICKNESS * 0.5
const SEGMENTS: int = 96                 # arc resolution

# Reference viewport: the user-supplied sprite was 315x217; the gameplay
# viewport is 1080x675. The ReferenceLevel.gd scene keeps this aspect ratio
# by anchoring the rings to the upper third of the gameplay viewport.
const REF_VIEW_W: float = 315.0
const REF_VIEW_H: float = 217.0
const GAME_VIEW_W: float = 1080.0
const GAME_VIEW_H: float = 1280.0

# Color palette - sampled from the reference image (warm cream, blue C, orange C).
const BG_COLOR: Color = Color(0.949, 0.910, 0.855, 1.0)  # warm cream
const SHADOW_COLOR: Color = Color(0.165, 0.137, 0.114, 0.18)
const HIGHLIGHT_DELTA: float = 0.16       # +L shift for top highlight
const SHADE_DELTA: float = 0.16          # -L shift for bottom shade
const SHADOW_OFFSET: Vector2 = Vector2(0, 4.0)

# Level 1 reference palette (cyan + orange, sampled from the 2.jpeg image).
# Used by scenes/reference/ReferenceLevel.gd to draw the level-1 reference
# rings and by tools/ref_compare/_capture.gd for pixel diffing.
const REF_L1_PINK_COLOR: Color = Color("#32ADDA")  # blue/cyan C-ring
const REF_L1_PINK_DARK:  Color = Color("#1F5A82")
const REF_L1_PINK_HI:    Color = Color("#A8E0F2")
const REF_L1_ORANGE_COLOR: Color = Color("#EA7829")
const REF_L1_ORANGE_DARK:  Color = Color("#7A3A14")
const REF_L1_ORANGE_HI:    Color = Color("#FFC8A0")
