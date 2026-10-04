# LOOPSHIFT — COMPLETE 2D ROTATE RINGS GAME BLUEPRINT

> **Document type:** Master Game Design + Technical Architecture + UI/UX + Content + Production Blueprint  
> **Engine:** Godot 4.7+  
> **Primary language:** GDScript  
> **Workflow:** Claude Code + Godot AI MCP  
> **Target platforms:** iOS + Android  
> **Orientation:** Portrait  
> **Game type:** 2D tactile ring-unlocking puzzle  
> **Visual style:** Premium 2D artwork with dimensional / 3D-like glossy enamel treatment  
> **Working title:** LOOPSHIFT  
> **Status:** Authoritative production blueprint

---

# 1. PRODUCT VISION

LOOPSHIFT is a portrait-first 2D mobile puzzle game where the player rotates open rings and loop-shaped pieces until gaps align and pieces can be released from an interlocked structure.

The basic interaction is:

**touch → rotate → align → unlock → release → update puzzle → continue**

The game must feel tactile, readable, premium, calm, and highly polished. It is not enough for the game to technically work. The first drag, the first alignment, the first release, and the first completed level must already feel like a commercial mobile title.

The game is 2D. The supplied assets create a dimensional 3D-like enamel appearance, but gameplay remains entirely in 2D.

The design must be original. Do not copy another title's branding, exact UI, exact level layouts, artwork, source code, store copy, or distinctive visual presentation.

---

# 2. CORE DESIGN PILLARS

## 2.1 Tactile Precision

The player's finger must feel directly connected to the selected ring.

The ring rotates using angular drag around its center, not horizontal mouse movement. No lag, no unexpected snapping, no 0°/360° jumps, and no accidental wrong-piece movement.

## 2.2 Deterministic Puzzle Logic

The game must know exactly why a piece is blocked or free.

Puzzle correctness comes from explicit data:

- gap angles;
- crossing angles;
- link relationships;
- blocker states;
- dependency rules;
- release conditions.

Do not infer puzzle truth from sprite pixels or random physics.

## 2.3 Visual Readability

The player should immediately understand:

- which ring can be touched;
- which ring is selected;
- where the opening is;
- what blocks it;
- when it is near a correct orientation;
- when it is free.

## 2.4 Premium Visual Cohesion

Visual direction: **Soft Enamel + Precision Vector**.

Characteristics:

- saturated body color;
- one controlled soft highlight band;
- darker concave inner shading;
- soft cast shadow;
- rounded end caps;
- clean bold silhouettes;
- consistent art across every piece and UI screen.

## 2.5 Scalable Content

Levels are data. The game must not require custom scripts for every puzzle.

The same systems must support:

- Level 1;
- Level 60;
- new shapes;
- future advanced mechanics.

---

# 3. PLAYER EXPERIENCE GOAL

## First 5 Seconds

The player sees one simple ring, a large readable opening, and a subtle gesture hint.

The player drags around the ring.

The ring follows naturally.

When the opening reaches the valid escape orientation:

1. subtle near-alignment feedback appears;
2. the ring confirms success;
3. the ring escapes smoothly;
4. a clean sound plays;
5. haptic feedback fires;
6. the level completes.

The player should understand the mechanic without reading a paragraph.

## First 3 Levels

**Level 1:** one ring, teach rotation.  
**Level 2:** two linked pieces, teach release order.  
**Level 3:** three pieces, teach reasoning.

After that, tutorials become contextual rather than constant.

---

# 4. COMPLETE APP FLOW

```text
Launch
  ↓
Boot
  ↓
Home
  ├── Continue
  ├── Levels
  └── Settings
       ↓
Level Select
  ↓
Gameplay
  ├── Restart
  ├── Hint
  ├── Pause
  └── Back
       ↓
Puzzle Solved
  ↓
Completion
  ├── Next Level
  ├── Replay
  └── Level Select
```

Future optional systems:

- Daily Puzzle;
- Challenge Mode;
- Themes;
- Achievements;
- Events.

Do not add them before the core game is excellent.

---

# 5. SCREEN-BY-SCREEN BLUEPRINT

# 5.1 BOOT

## Purpose

Initialize app services quickly.

## Visuals

Keep boot short.

Possible content:

- LOOPSHIFT logo;
- chapter-neutral background;
- subtle ring motion.

## Systems Initialized

- SaveService;
- AudioService;
- HapticService;
- Settings;
- LevelDatabase;
- SceneRouter.

No fake loading delay.

---

# 5.2 HOME SCREEN

## Layout

Portrait.

Top-right:

- Settings.

Center:

- LOOPSHIFT logo;
- decorative ring composition.

Lower-middle:

- large **CONTINUE** button.

Below:

- **LEVELS**.

## Continue Logic

Load:

```text
highest unlocked incomplete level
```

If everything unlocked is completed, load the latest completed level or the next content target according to progression rules.

## Motion

Ambient rings may rotate or drift very slowly.

Do not create distracting continuous motion.

---

# 5.3 LEVEL SELECT

## Header

- Back;
- Chapter name;
- Progress.

## Body

Use a clean chapter selector plus a level grid.

Each level tile has one of four states:

```text
LOCKED
AVAILABLE
CLEARED
PERFECT
```

Visual markers should be custom assets, not emoji.

A tile may show:

- level number;
- clear marker;
- perfect marker.

---

# 5.4 GAMEPLAY SCREEN

This is the most important screen in the game.

## Layout

```text
┌──────────────────────┐
│ Back    LEVEL 12  ⚙  │
│                      │
│                      │
│      PUZZLE AREA     │
│                      │
│                      │
│                      │
│ Restart        Hint  │
└──────────────────────┘
```

Use custom UI icons in the real build.

## Top HUD

Left:
- Back.

Center:
- current level.

Right:
- pause/settings.

## Puzzle Area

Use roughly the central 70–75% of the usable portrait screen.

Requirements:

- puzzle centered;
- all active pieces readable;
- no HUD overlap;
- large enough for accurate touch;
- automatic scaling for different level bounds.

## Bottom HUD

Left:
- Restart.

Right:
- Hint.

Optional center:
- move count.

Do not fill gameplay with unrelated progression, shop, currency, or ad UI.

---

# 5.5 PAUSE OVERLAY

Pause should not unload the puzzle.

Contents:

- Resume;
- Restart;
- Sound;
- Haptics;
- Reduced Motion;
- Level Select;
- Home.

Background gameplay is dimmed.

---

# 5.6 SETTINGS SCREEN

Settings:

- Sound;
- Music if used;
- Haptics;
- Reduced Motion;
- Reset Progress;
- Privacy;
- About.

Reset Progress requires confirmation.

---

# 5.7 COMPLETION OVERLAY

Completion happens after the final required ring finishes releasing.

Sequence:

1. final release finishes;
2. center pulse;
3. small completion VFX;
4. title appears;
5. move result appears;
6. action buttons enter.

Possible titles:

```text
CLEAR!
PERFECT!
```

Show:

- moves;
- par;
- best moves.

Buttons:

- Next;
- Replay;
- Levels.

Total animation should usually remain under about 1.5 seconds.

---

# 6. CORE GAMEPLAY LOOP

```text
Load LevelDefinition
↓
Instantiate pieces
↓
Create links
↓
Resolve initial blocker states
↓
Enable input
↓
Player selects a piece
↓
Player rotates it
↓
Rules reevaluate relevant crossings
↓
Piece becomes releasable if all required links are clear
↓
Player completes gesture
↓
Piece escapes
↓
Links involving that piece are removed/deactivated
↓
Remaining states update
↓
Check completion
↓
Repeat or finish
```

---

# 7. RING VISUAL SYSTEM

Every production puzzle piece uses approved 2D art.

Example production assets:

```text
ring_open_cobalt_wide_01.png
ring_open_coral_01.png
ring_open_jade_01.png
ring_open_amber_01.png
ring_open_violet_01.png
ring_open_cyan_01.png
ring_d_shape_cobalt_01.png
ring_u_shape_cobalt_01.png
ring_square_cobalt_01.png
ring_triangle_cobalt_01.png
ring_dual_gap_cobalt_01.png
```

The sprite is visual presentation only.

The gameplay source of truth is separate geometry metadata.

Do not use rendered pixels to determine whether a gap is aligned.

---

# 8. RING GEOMETRY SYSTEM

V1 shape types:

```text
OPEN_CIRCLE
D_SHAPE
U_SHAPE
ROUNDED_SQUARE
ROUNDED_TRIANGLE
DUAL_GAP_CIRCLE
```

Future shapes:

```text
S_LINK
HEX_LOOP
SPIRAL
GEAR_RING
LOCK_RING
PORTAL_RING
```

Each shape defines visual asset + gameplay geometry.

---

# 9. HOW RINGS ARE CREATED IN GODOT

Use one reusable runtime scene.

```text
RingPiece2D
├── VisualRoot
│   └── Sprite2D
├── SelectionFX
├── HintFX
├── TouchArea
└── DebugOverlay
```

## Creation Sequence

```text
LevelRuntime reads PieceDefinition
↓
instantiate RingPiece2D
↓
assign asset_id
↓
assign geometry metadata
↓
assign gap definitions
↓
set start position
↓
set start rotation
↓
configure hit region
↓
register with PuzzleRules
```

---

# 10. PUZZLE PIECE DATA MODEL

Conceptual Godot Resource:

```gdscript
class_name PieceDefinition
extends Resource

@export var id: StringName
@export var piece_type: PieceType
@export var asset_id: StringName

@export var normalized_position: Vector2
@export var start_angle_deg: float

@export var geometry_radius: float
@export var hit_width: float

@export var gaps: Array[GapDefinition]

@export var rotation_mode: RotationMode
@export var min_angle_deg: float
@export var max_angle_deg: float

@export var z_index: int

@export var release_direction: Vector2
@export var release_distance: float

@export var initially_locked: bool
```

Additional fields may include:

- shape dimensions;
- pivot correction;
- chapter style;
- dependency IDs;
- linked-rotation information;
- release path.

---

# 11. GAP DEFINITION

```gdscript
class_name GapDefinition
extends Resource

@export var center_angle_deg: float
@export var width_deg: float
@export var tolerance_deg: float
```

A ring may have one or multiple gaps.

Examples:

```text
Open circle: 1 gap
Dual-gap circle: 2 gaps
U shape: one large top opening
```

---

# 12. LINK / INTERLOCK MODEL

A link describes why two pieces interact.

```gdscript
class_name LinkDefinition
extends Resource

@export var piece_a_id: StringName
@export var piece_b_id: StringName

@export var angle_on_a_deg: float
@export var angle_on_b_deg: float

@export var clearance_tolerance_deg: float
@export var rule_type: LinkRule
```

Possible rules:

```text
EITHER_GAP_CLEARS
A_GAP_REQUIRED
B_GAP_REQUIRED
BOTH_GAPS_REQUIRED
DEPENDENCY_ONLY
```

The system should not guess a link merely because two sprites overlap.

---

# 13. GAP MATH

For each active crossing:

```text
crossing angle in world/puzzle space
↓
convert to local piece angle
↓
compare to each gap interval
↓
inside a valid gap?
    yes → this crossing is clear
    no  → this crossing blocks
```

## Recommended Angle Convention

Use degrees normalized to:

```text
0 ≤ angle < 360
```

Use one convention everywhere.

## Shortest Angle

```gdscript
func shortest_angle_delta(a: float, b: float) -> float:
    return wrapf(b - a, -180.0, 180.0)
```

## Gap Test

```gdscript
func angle_inside_gap(local_angle: float, gap: GapDefinition) -> bool:
    var delta := abs(wrapf(local_angle - gap.center_angle_deg, -180.0, 180.0))
    return delta <= gap.width_deg * 0.5 + gap.tolerance_deg
```

This automatically handles gaps that cross 0°.

---

# 14. TOUCH ROTATION SYSTEM

This interaction must be excellent.

Never use final logic like:

```gdscript
rotation += mouse_delta.x
```

## Pointer Down

1. resolve top-most eligible piece under pointer;
2. store selected piece;
3. determine its puzzle-space center;
4. calculate pointer angle with `atan2`;
5. cache previous pointer angle;
6. cache current piece rotation.

## Pointer Move

```text
new_pointer_angle = angle from center to current pointer
angular_delta = shortest signed difference
piece_angle += angular_delta
previous_pointer_angle = new_pointer_angle
```

## Pointer Up

1. end drag;
2. count move if angle changed enough;
3. check release state;
4. start release if eligible;
5. otherwise return piece to idle state.

## Mouse + Touch

Core math is shared.

Desktop mouse is only development input.

Shipping UX is mobile touch-first.

---

# 15. HIT TESTING

Touch should be forgiving.

Example:

```text
visible ring thickness ≈ 120 px
logical touch width ≈ 160–180 px
```

Hit geometry is invisible.

When pieces overlap:

1. ignore released pieces;
2. apply lock rules;
3. sort candidates by z-index;
4. select top-most valid hit;
5. if necessary use distance to piece centerline.

---

# 16. PIECE STATE MACHINE

```text
IDLE
SELECTED
ROTATING
NEAR_VALID
RELEASABLE
RELEASING
RELEASED
LOCKED
```

## IDLE

Normal selectable state.

## SELECTED

Visual lift/glow.

## ROTATING

Pointer owns angle.

## NEAR_VALID

A relevant link is close to being cleared.

## RELEASABLE

Every required active blocker is clear.

## RELEASING

Input disabled. ReleaseAnimator owns transform.

## RELEASED

No longer participates in gameplay.

## LOCKED

Cannot rotate until dependency resolves.

---

# 17. PUZZLE STATE MACHINE

```text
LOADING
INTRO
PLAYING
PIECE_RELEASING
CHECKING
COMPLETE
PAUSED
```

No gameplay input while loading or during final completion transition.

---

# 18. RELEASE SYSTEM

Piece becomes eligible when:

```text
all required active links == clear
```

Recommended release trigger:

**on gesture end**

This keeps the player in control.

## Release Choreography

### Confirmation

60–100 ms:

- small scale lift;
- glow increase;
- alignment sound/haptic.

### Escape

250–450 ms:

- move along authored release vector/path;
- slight rotation;
- ease-out.

### Exit

Near end:

- fade;
- release particles;
- disable piece.

Never use uncontrolled rigid-body physics as the authoritative escape system.

---

# 19. LAYERING AND OVERLAP

2D depth is represented by:

- z-index;
- cast shadow;
- overlap order;
- optional masks for advanced crossings.

Each link may optionally store which piece visually passes over the other.

V1 may use full-piece z-order if readability remains strong.

---

# 20. LEVEL COMPLETION LOGIC

A level completes when every required puzzle piece has reached `RELEASED`.

Level data may include:

```text
required_piece_ids
```

Decorative or structural elements can be excluded.

Do not infer completion simply because a container is visually empty.

---

# 21. MOVE COUNTING

A move is one completed drag gesture that changes angle more than a minimum threshold.

Example:

```text
minimum meaningful rotation = 5°
```

Tiny taps or micro-adjustments below threshold do not count.

---

# 22. PERFECT RESULT

Each level has:

```text
par_moves
```

Perfect if:

```text
moves <= par_moves
AND no hint was used
```

Do not clutter gameplay with 3-star systems unless later intentionally chosen.

---

# 23. HINT SYSTEM

Hints must understand the current puzzle state.

The level contains a canonical solution sequence.

HintController uses:

```text
current active state
+
canonical solution metadata
```

to find a useful next action.

## Hint Stages

1. pulse the recommended piece;
2. show curved ghost arrow;
3. show target orientation arc.

Do not automatically solve the puzzle unless a later product decision adds that option.

---

# 24. RESTART / RESET

Restart rebuilds exact initial level state:

- positions;
- rotations;
- links;
- locks;
- piece states;
- move count;
- release state.

Do not try to manually reverse every animation and mutation.

Reload from deterministic LevelDefinition state.

---

# 25. UNDO

Optional later.

Use command history:

```text
MoveCommand
  piece_id
  from_angle
  to_angle
```

Do not implement until the core puzzle system is stable.

---

# 26. LEVEL DATA MODEL

```gdscript
class_name LevelDefinition
extends Resource

@export var level_id: int
@export var chapter_id: int

@export var pieces: Array[PieceDefinition]
@export var links: Array[LinkDefinition]

@export var par_moves: int
@export var canonical_steps: Array[SolutionStep]

@export var theme_id: StringName
@export var hint_steps: Array[HintStep]
```

---

# 27. SOLUTION STEP

Conceptual:

```gdscript
class_name SolutionStep
extends Resource

@export var piece_id: StringName
@export var target_angle_deg: float
@export var expect_release: bool
```

The canonical solution is primarily for:

- validation;
- hints;
- par design.

It does not need to be the only valid solution.

---

# 28. LEVEL AUTHORING PROCESS

For every level:

1. choose learning/challenge objective;
2. choose pieces;
3. place pieces;
4. choose start rotations;
5. define links;
6. define release paths;
7. manually solve;
8. write canonical solution;
9. choose par;
10. validate automatically;
11. inspect portrait readability;
12. play on touch device or touch emulation;
13. approve.

Never ship randomly generated unvalidated content.

---

# 29. LEVEL VALIDATOR

Validator checks:

- duplicate IDs;
- missing assets;
- broken link references;
- invalid angles;
- invalid gap widths;
- impossible rotation range;
- canonical step references missing piece;
- canonical step cannot produce expected release;
- final canonical state does not complete level.

## Auto-Simulation

```text
load level
↓
apply canonical step
↓
reevaluate links
↓
release if expected
↓
repeat
↓
assert level completed
```

Every shipping level must pass.

---

# 30. DIFFICULTY PROGRESSION

Increase challenge through:

- piece count;
- nested dependency depth;
- smaller but fair gaps;
- multiple possible rotations;
- decoy moves;
- shape variety;
- restricted rotation;
- linked rotation;
- ordered removal.

Do not make difficulty purely about tiny gaps.

---

# 31. V1 CHAPTERS

Recommended:

```text
Chapter 1 — Learn the Loop
Chapter 2 — Layers
Chapter 3 — Shape Shift
Chapter 4 — Coupled
Chapter 5 — Master Loops
```

12 levels per chapter.

Total:

```text
60 levels
```

---

# 32. CHAPTER 1 — LEARN THE LOOP

Focus:

- direct rotation;
- single gap;
- simple release order;
- 1–3 pieces.

No advanced locks.

---

# 33. CHAPTER 2 — LAYERS

Focus:

- 3–5 pieces;
- nesting;
- deeper blocker chains;
- dual-gap ring introduction.

---

# 34. CHAPTER 3 — SHAPE SHIFT

Introduce:

- D shape;
- U shape;
- rounded square;
- rounded triangle.

Teach the player that not every piece is circular.

---

# 35. CHAPTER 4 — COUPLED

Introduce:

- one-way rotation;
- angle-limited pieces;
- gear links;
- dependency locks.

---

# 36. CHAPTER 5 — MASTER LOOPS

Combine learned mechanics.

5–8 pieces where readable.

Create showcase levels, not cluttered chaos.

---

# 37. ADVANCED MECHANICS

## Locked Ring

Cannot rotate until another piece is released.

## One-Way Ring

Only clockwise or counterclockwise.

## Limited Ring

Rotation clamped to authored interval.

## Gear Pair

Rotating A rotates B.

```text
B_delta = A_delta × ratio × direction
```

## Frozen Ring

Visually frozen and unavailable until a dependency resolves.

## Switch Ring

Crossing a target angle toggles another puzzle state.

Do not add all at once.

---

# 38. TUTORIAL SYSTEM

Tutorial should be playable rather than textual.

## Level 1

- ghost finger;
- curved drag arrow;
- no large text block.

## Level 2

Pulse correct starting ring.

## Level 3

Only provide help after inactivity.

## Idle Tutorial Trigger

After approximately 3–5 seconds of no useful interaction:

- pulse;
- arrow;
- optional target arc.

---

# 39. UI DESIGN SYSTEM

Use an 8-point spacing rhythm.

Common values:

```text
8
16
24
32
48
```

Minimum touch target:

```text
44–48 logical px
```

UI must be designed for portrait mobile, not desktop.

---

# 40. BUTTON BEHAVIOR

Press:

```text
scale 1.00 → 0.96–0.98
60–90 ms
```

Release:

- short spring/ease back to 1.0.

Avoid giant bounces.

---

# 41. GAMEPLAY HUD

Keep gameplay clean.

Only core actions:

- Back;
- Level;
- Settings/Pause;
- Restart;
- Hint;
- optional Moves.

Do not place shop/currency UI over the puzzle.

---

# 42. SAVE SYSTEM

Example save schema:

```json
{
  "version": 1,
  "highest_unlocked_level": 14,
  "levels": {
    "1": {
      "cleared": true,
      "perfect": true,
      "best_moves": 2
    }
  },
  "settings": {
    "sound": true,
    "haptics": true,
    "reduced_motion": false
  }
}
```

Save after:

- level completion;
- settings change;
- reset progress.

Do not write every frame.

---

# 43. AUDIO SYSTEM

Required SFX:

```text
ui_tap
piece_select
rotation_tick
near_alignment
blocked
release
level_clear
perfect
hint
```

Use AudioService so gameplay scripts do not manage audio nodes individually.

---

# 44. HAPTICS

Use HapticService.

Events:

```text
selection_light
alignment_light
release_medium
success_medium
perfect_success
```

The game must still function when haptics are unsupported.

---

# 45. JUICE / MOTION BIBLE

## Selection

80–120 ms:

- scale 1.00 → about 1.025;
- shadow opens slightly;
- subtle highlight response;
- light haptic.

## Rotation

Direct tracking. Never tween gameplay angle behind the finger.

## Near Alignment

100–160 ms:

- small glow pulse;
- soft pitch-up tick.

## Blocked

70–100 ms:

- tiny resistance shake;
- muted click;
- no giant red error flash.

## Release

300–500 ms total.

## Completion

0.8–1.5 seconds total.

---

# 46. VFX SYSTEM

Core VFX:

- selection glow;
- alignment glow;
- release sparks;
- completion pulse;
- perfect glint.

Recommended release particles:

```text
8–14 small particles
```

Avoid generic fireworks and confetti spam.

---

# 47. CHAPTER VISUAL THEMES

## Chapter 1 — Porcelain

- warm cream;
- cobalt/coral/jade.

## Chapter 2 — Midnight

- deep ink;
- cyan/violet accents.

## Chapter 3 — Garden

- warm sage/cream;
- jade/amber.

## Chapter 4 — Signal

- graphite;
- controlled cyan/amber technical accents.

## Chapter 5 — Gallery

- premium charcoal/ivory;
- subtle gold accent.

The central puzzle area remains visually quiet.

---

# 48. RESPONSIVE LAYOUT

Reference layout:

```text
1080 × 1920 portrait
```

Support:

```text
9:16
19.5:9
20:9
tablets
```

Use:

- anchors;
- containers;
- normalized puzzle coordinates;
- safe-area insets.

Puzzle framing is based on available region and puzzle bounds, not hardcoded device pixels.

---

# 49. ACCESSIBILITY

Support:

- Reduced Motion;
- Sound toggle;
- Haptics toggle;
- no required time pressure;
- generous touch regions;
- no color-only communication;
- visible silhouette/gap information.

---

# 50. PERFORMANCE TARGETS

Target:

```text
60 FPS on reasonable modern iOS/Android hardware
```

Avoid:

- expensive full-screen blur;
- excessive transparency;
- large particle counts;
- per-frame allocations;
- repeated tree searching in hot loops;
- uncontrolled Tween creation;
- `_process()` on inactive pieces.

Profile before making performance claims.

---

# 51. GODOT PROJECT STRUCTURE

```text
res://

  CLAUDE.md
  LOOPSHIFT_COMPLETE_GAME_BLUEPRINT.md
  LOOPSHIFT_ASSET_INTEGRATION_CONTRACT.md

  app/
    app.gd
    scene_router.gd
    save_service.gd
    audio_service.gd
    haptic_service.gd

  gameplay/
    puzzle_controller.gd
    puzzle_rules.gd
    ring_piece_2d.gd
    drag_rotation_controller.gd
    release_animator.gd
    hint_controller.gd
    level_runtime.gd

  data/
    piece_definition.gd
    gap_definition.gd
    link_definition.gd
    level_definition.gd
    solution_step.gd
    levels/
      chapter_01/
      chapter_02/
      chapter_03/
      chapter_04/
      chapter_05/

  scenes/
    boot/
    home/
    level_select/
    gameplay/
    settings/
    components/

  assets/
    production/
      puzzle/
        rings/
      ui/
        icons/
        badges/
      vfx/
      backgrounds/
      tutorial/
    debug/

  shaders/
  audio/

  tools/
    level_validator/
    level_preview/
    debug_overlay/

  tests/
```

---

# 52. GAMEPLAY SCENE TREE

```text
GameplayScreen (Control)
├── Background
├── SafeArea
│   ├── TopHUD
│   └── PuzzleArea
│       └── PuzzleRoot (Node2D)
│           ├── Pieces
│           ├── FX
│           └── Debug
├── BottomHUD
├── TutorialLayer
├── PauseLayer
└── CompletionLayer
```

---

# 53. SCRIPT RESPONSIBILITIES

## PuzzleController

Owns:

- high-level runtime state;
- move count;
- level completion;
- high-level signals.

## PuzzleRules

Owns:

- links;
- gap clearance;
- blockers;
- releasable evaluation.

## RingPiece2D

Owns:

- current angle;
- visual state;
- piece state;
- local data.

## DragRotationController

Owns:

- pointer lifecycle;
- angular drag math;
- current selected piece.

## ReleaseAnimator

Owns:

- escape animation only.

## LevelRuntime

Owns:

- loading;
- instantiation;
- reset.

## HintController

Owns:

- hint recommendation;
- ghost arrow/target display.

---

# 54. SIGNALS

Recommended typed signals:

```text
piece_selected(piece)
piece_rotation_changed(piece, angle)
piece_near_alignment(piece)
piece_became_releasable(piece)
piece_release_started(piece)
piece_released(piece)
move_completed(piece, from_angle, to_angle)
hint_used()
level_completed()
```

Do not create a giant global event bus unless necessary.

---

# 55. COMPLETE RUNTIME SEQUENCE

1. User selects a level.  
2. SceneRouter loads GameplayScreen.  
3. LevelRuntime loads LevelDefinition.  
4. Pieces instantiate.  
5. PuzzleRules builds relationships.  
6. PuzzleController enters PLAYING.  
7. Player touches a ring.  
8. DragRotationController resolves hit and caches pointer angle.  
9. Player moves finger.  
10. Piece angle updates directly.  
11. PuzzleRules reevaluates links involving that piece.  
12. Near-valid feedback appears where appropriate.  
13. If all required links clear, piece becomes RELEASABLE.  
14. Player ends gesture.  
15. Move count updates.  
16. ReleaseAnimator owns the piece.  
17. Piece becomes RELEASED.  
18. Links involving piece deactivate.  
19. Remaining piece states update.  
20. PuzzleController checks completion.  
21. If incomplete, return to PLAYING.  
22. If complete, enter COMPLETE and run final choreography.

---

# 56. ASSET INTEGRATION PIPELINE

Every supplied production asset is authoritative final art unless explicitly marked otherwise.

Workflow:

1. asset delivered;
2. store under `assets/production`;
3. inspect alpha/transparency;
4. preserve filename;
5. add manifest entry;
6. map filename to asset ID;
7. wire into appropriate PieceDefinition or UI resource;
8. test at real mobile size;
9. inspect style consistency;
10. never silently redesign it.

Claude Code may:

- position;
- uniformly scale;
- rotate;
- animate;
- mask;
- shader;
- integrate.

Claude Code may not:

- recolor final assets;
- non-uniformly stretch;
- flatten;
- redraw;
- regenerate;
- replace with generic Godot shapes.

---

# 57. ASSET MANIFEST

Maintain:

```text
res://assets/production/ASSET_MANIFEST.md
```

For each asset:

```text
Filename
Category
Purpose
Native size
Transparency
Asset ID
Godot usage
Status
Notes
```

---

# 58. DEBUG OVERLAY

Optional debug information:

- piece ID;
- current angle;
- gap intervals;
- link crossing angles;
- blocked/free state;
- hit region;
- release vector;
- z-index.

Debug mode must be easy to disable and must not ship visibly enabled.

---

# 59. LEVEL PREVIEW TOOL

Create an internal Level Preview scene or editor tool.

Functions:

- load any level;
- next/previous level;
- restart;
- show IDs;
- show gaps;
- show links;
- show blockers;
- auto-run canonical solution;
- run validator;
- capture screenshot.

---

# 60. AUTOMATED TESTS

## Angle Tests

- shortest angle;
- wrap at 0°;
- wrap at 360°.

## Gap Tests

- standard gap;
- wraparound gap;
- tolerance.

## Link Tests

- blocked;
- one side clears;
- either side clears;
- both required.

## Completion Tests

- all required pieces;
- decorative pieces ignored.

## Save Tests

- defaults;
- write;
- read;
- migration.

## Level Validation

Run across every shipping level.

---

# 61. MANUAL QA MATRIX

Test on representative portrait layouts:

- small phone;
- tall modern phone;
- large phone;
- tablet.

Verify:

- touch accuracy;
- overlap selection;
- drag continuity;
- safe areas;
- ring readability;
- UI placement;
- pause/resume;
- restart;
- hint;
- save/reload;
- completion.

---

# 62. ERROR HANDLING

Invalid level data in development should produce clear errors.

Use:

```gdscript
push_error()
```

or assertions in tooling.

In release builds:

- avoid hard crash where possible;
- return safely to level select if level cannot initialize;
- log clear diagnostic information.

Never silently run corrupted puzzle data.

---

# 63. ANALYTICS READINESS

Keep gameplay SDK-independent.

Potential future events:

```text
level_start
level_complete
level_restart
hint_used
perfect_earned
session_start
```

Analytics should be accessed through a service abstraction if added later.

---

# 64. MONETIZATION READINESS

Monetization is not part of core gameplay architecture.

Future options:

- rewarded hint;
- carefully paced interstitial;
- cosmetic themes.

Do not make puzzle logic depend on an ad SDK.

---

# 65. BUILD / EXPORT READINESS

## Android

Verify:

- portrait orientation;
- package ID;
- touch input;
- safe area;
- release build.

## iOS

Verify:

- portrait;
- bundle ID;
- safe area;
- haptics;
- signing/export.

A platform is not considered VERIFIED until an actual build/export succeeds.

---

# 66. PRODUCTION MILESTONES

## M0 — Project + Godot AI MCP

- inspect repo;
- inspect Git;
- verify Godot AI MCP;
- inspect live editor.

## M1 — One Perfect Ring

- one production ring;
- correct hit test;
- direct angular drag;
- premium feedback.

## M2 — Gap Logic

- deterministic gap test;
- releasable state.

## M3 — Two-Piece Puzzle

- actual interlock;
- release ordering.

## M4 — Polished Vertical Slice

- 3–5 pieces;
- HUD;
- restart;
- hint proof;
- completion.

## M5 — App Shell

- Boot;
- Home;
- Levels;
- Settings.

## M6 — Data + Tooling

- Resource definitions;
- LevelRuntime;
- validator;
- preview tool.

## M7 — Chapter 1

- 12 levels;
- tutorial.

## M8 — Shape Expansion

- D;
- U;
- square;
- triangle;
- dual-gap.

## M9 — Advanced Rules

- locks;
- one-way;
- limited rotation;
- gear pair.

## M10 — Full Campaign

- 60 validated levels;
- par values;
- hints.

## M11 — Final Polish

- final art;
- VFX;
- audio;
- haptics;
- responsive polish.

## M12 — Shipping QA

- full validator;
- smoke tests;
- performance;
- save/reload;
- debug cleanup;
- export readiness.

---

# 67. SHIPPING DEFINITION OF DONE

Do NOT call the game complete until:

- project launches without script errors;
- all core screens exist and are styled;
- no default placeholder Godot UI remains;
- ring drag feels stable;
- angle wrapping is correct;
- hit testing is reliable;
- gap logic is deterministic;
- all 60 shipping levels load;
- all canonical solutions validate;
- restart reconstructs exact authored state;
- hint points to valid action;
- save/reload works;
- settings persist;
- completion flow works;
- reduced motion works;
- no debug overlay ships enabled;
- all supplied art is used correctly;
- portrait layouts work on representative devices;
- recurring project-caused Godot errors are removed;
- Android/iOS build readiness is checked.

---

# 68. FUTURE EXPANSION

After V1 is stable:

- Daily Puzzle;
- Challenge Mode;
- limited-move mode;
- timed optional mode;
- procedural level generator;
- cosmetic themes;
- new shape families;
- boss puzzles;
- cloud sync;
- achievements.

These must not destabilize the core.

---

# 69. CLAUDE CODE OPERATING RULES

Claude Code must always:

1. read `CLAUDE.md`;
2. read this blueprint;
3. read `LOOPSHIFT_ASSET_INTEGRATION_CONTRACT.md`;
4. inspect the repository before editing;
5. inspect Git status;
6. preserve pre-existing user changes;
7. verify Godot AI MCP;
8. inspect the live editor;
9. use MCP where it provides real evidence;
10. validate GDScript;
11. run scenes/project;
12. inspect debugger/output;
13. fix regressions;
14. maintain the asset manifest;
15. maintain the level validator;
16. never redesign approved art without instruction;
17. never call unverified behavior complete.

Evidence terms:

```text
VERIFIED
CLAIMED
NEEDS USER CHECK
```

---

# 70. FINAL PRODUCT PRINCIPLE

LOOPSHIFT succeeds on four things:

1. **The ring feels excellent under the finger.**
2. **The puzzle always makes logical and visual sense.**
3. **Every screen and asset feels like one premium product.**
4. **Every successful release feels satisfying enough to make the player want another level.**

If input is weak, fix input before adding content.

If puzzle logic is unreliable, fix logic before adding polish.

If art is inconsistent, do not ship.

If levels are not validated, do not ship.

If the game merely runs, it is not finished.

The target is a **commercially shippable 2D mobile puzzle game**.
