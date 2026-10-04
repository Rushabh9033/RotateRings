# LOOPSHIFT — COMPLETE 2D GAME DESIGN & PRODUCTION DOCUMENT

> Working title: **LOOPSHIFT**
> Genre: Premium-feeling 2D tactile puzzle
> Platform: iOS + Android
> Engine: Godot 4.7+ / GDScript
> Orientation: Portrait-first
> Development workflow: Claude Code + Godot AI MCP
> Product goal: A genuinely shippable, original rotate/unlink puzzle with exceptional game feel, art cohesion, and level readability.

---

# 1. EXECUTIVE VISION

LOOPSHIFT is a portrait-mobile 2D puzzle game about manipulating open rings and linked shapes.

The player touches a ring, drags around its center, and rotates it with direct 1:1 angular control. Rings overlap and form a puzzle network. Each ring has one or more openings. By rotating openings into useful positions, links can be cleared and rings can escape the structure.

The basic action is deliberately simple:
**touch → rotate → align → release → satisfyingly detach.**

The depth comes from:
- interlocking relationships;
- multiple ring shapes;
- rotation restrictions;
- linked/gear relationships;
- locks and dependencies;
- layered puzzles;
- carefully authored solution order;
- high-quality tactile feedback.

This project is inspired by the broad “rotate/unlink rings” puzzle category, but it must be independently designed. Do not copy another game's exact art, UI, level layouts, branding, store copy, or proprietary assets.

The shipping target is not “functional.”
The shipping target is:
**clean enough to publish, polished enough to advertise, and tactile enough that the first drag feels premium.**

---

# 2. PRODUCT PILLARS

## 2.1 Tactile Before Complex
The player's finger must feel directly connected to the selected ring.

If rotation feels floaty, jerky, imprecise, or artificially damped, the game fails even if the puzzle logic is correct.

## 2.2 Instantly Readable
A player should understand:
- what can be touched;
- which ring is selected;
- where its gap is;
- what is blocking it;
- when it becomes free.

Readability must survive small phones.

## 2.3 Satisfying Every Few Seconds
The game should constantly reward correct manipulation through:
- micro motion;
- soft sound;
- haptic hooks;
- glow;
- snap response;
- detach animation;
- restrained particles;
- beautiful completion choreography.

## 2.4 Original Art System
Avoid asset-store collage aesthetics and AI-generated inconsistency.

The game uses one coherent vector/procedural art system:
- mathematically clean shapes;
- controlled color palettes;
- consistent stroke weights;
- consistent shadows/highlights;
- consistent icon geometry;
- deliberate animation curves.

## 2.5 Scalable Content
The first ring and the fiftieth level should run on the same core architecture.

Levels are data, not bespoke scripts.

---

# 3. TARGET AUDIENCE

Primary:
- casual puzzle players;
- ages roughly 10+;
- short mobile sessions;
- players who enjoy sorting, untangling, screw/bolt, pin, rope, ring, and tactile logic puzzles.

Desired session:
- 2–8 minutes;
- 1–6 levels;
- easy to stop and resume.

Desired onboarding:
- understand core input within 10 seconds;
- no tutorial paragraph;
- teach by motion and level design.

---

# 4. CORE GAME LOOP

1. Enter a puzzle.
2. Read the ring arrangement.
3. Touch a ring.
4. Drag around its center to rotate it.
5. Align the opening with a blocking/crossing relationship.
6. When all required blockers are cleared, the ring becomes releasable.
7. Ring performs a premium detach animation.
8. The puzzle state updates.
9. Newly accessible rings become available.
10. Repeat.
11. Complete the final release.
12. Receive a concise result:
   - Clear
   - Perfect if move/par criteria are met and no hint was used
13. Continue immediately to the next level.

No forced timer in the core campaign.

---

# 5. CONTROL MODEL

## 5.1 Direct Angular Drag

The touch point is interpreted relative to the selected ring center.

On pointer-down:
- determine selected ring from hit area;
- cache center;
- convert pointer position to a normalized vector from center;
- cache initial pointer angle;
- cache current ring angle.

During drag:
- calculate new pointer angle;
- derive shortest signed angular delta;
- apply delta around ring center;
- accumulate angle safely;
- respect rotation rules.

This avoids naïve:
`rotation += mouse_delta.x`

The ring should follow the finger naturally even when the finger moves vertically or diagonally.

## 5.2 Angle Continuity
No jumps at -PI/PI or 0/360 boundaries.

Use shortest-angle math and accumulated rotation state.

## 5.3 Touch + Mouse
Mouse must emulate touch for desktop development.

Multitouch is not needed for the core game.

## 5.4 Selection Forgiveness
Hit areas should be slightly more generous than visible ring strokes.

Touch should feel accurate without requiring pixel-perfect tapping.

---

# 6. CORE PUZZLE MODEL

## 6.1 Ring/Piece Definition

Each puzzle piece requires:

- `id`
- `piece_type`
- position
- visual radius / size
- base rotation
- current rotation
- rotation rule
- rotation min/max if restricted
- one or more gap angular intervals
- stroke width
- color/material style ID
- z/layer information
- link relationships
- blocked/available state
- release rule
- release vector or authored path
- optional linked-rotation relationships
- hint metadata
- solution metadata

## 6.2 Link Relationship

A link is not inferred purely from sprite overlap.

A deterministic relationship defines:
- piece A
- piece B
- crossing/contact angle on A
- crossing/contact angle on B
- required gap clearance
- optional directional rule
- whether clearing either side breaks the link

A piece becomes releasable only when all required active links are cleared according to puzzle rules.

## 6.3 Gap Check

For a crossing to be clear:
- transform crossing direction into piece-local angular space;
- test whether it lies inside any active gap interval;
- include a controlled tolerance;
- use the same mathematical source of truth for gameplay and debug visualization.

Do not use sprite pixel tests as the main logic.

---

# 7. PIECE TYPES

## V1 Core Types

### Open Ring
Classic circular open loop.

### Dual-Gap Ring
Two openings create alternative solutions.

### D-Loop
Rounded outer shape with one flatter side.

### U-Loop
Open-ended piece with a strong directional gap.

### Triangle Loop
Rounded triangular outline with a gap.

### Rounded Square Loop
Used to change visual reasoning without changing the entire interaction model.

## Later Mechanics

### Locked Ring
Cannot rotate until dependency is cleared.

### One-Way Ring
May rotate only clockwise or only counterclockwise.

### Range-Limited Ring
Rotation is clamped to an authored angular interval.

### Gear Link
Rotating one ring rotates another by a defined ratio/direction.

### Magnetic Pair
Visual attraction state changes only when poles/openings align.

### Freeze State
A ring is visually frozen until another condition is met.

### Switch Ring
Crossing a target angle toggles another puzzle state.

Avoid implementing advanced mechanics before the core release logic is proven.

---

# 8. MOVE MODEL AND SCORING

A move is one completed drag gesture that changes a ring angle meaningfully.

The core campaign does not fail the player for using extra moves.

Each level has:
- par moves;
- best moves;
- hint-used flag;
- completion state.

Result:
- **Clear** — level solved.
- **Perfect** — solved at or under par without using a hint.

Do not use 1/2/3 star clutter on the core gameplay screen.

The level select may show:
- dot = cleared;
- small crown/diamond = perfect.

---

# 9. DIFFICULTY CURVE

Difficulty should come from reasoning, not visual mess.

## Chapter 1 — Learn the Loop
12 levels
- 1–3 rings
- large gaps
- no restricted rotation
- obvious ordering
- teach direct rotation and release

## Chapter 2 — Layers
12 levels
- 3–5 pieces
- nested dependencies
- smaller gaps
- dual-gap pieces introduced
- decoy rotations

## Chapter 3 — Shape Shift
12 levels
- D/U/triangle/square pieces
- different visual centers and gap reading
- multi-step dependencies

## Chapter 4 — Coupled
12 levels
- one-way/range-limited rings
- gear-linked pairs
- more deliberate order planning

## Chapter 5 — Master Loops
12 levels
- 5–8 pieces
- combined mechanics
- multi-stage dependencies
- tighter but fair alignment windows
- final showcase puzzles

V1 campaign target:
**60 handcrafted/validated levels.**

---

# 10. LEVEL DESIGN RULES

Every level must:
- have at least one verified solution;
- visually communicate its structure;
- avoid accidental near-impossible precision;
- avoid invisible rules;
- fit portrait safe area;
- use no more pieces than readability allows;
- be solvable without random trial-and-error;
- have a deliberate teaching or challenge purpose.

Do not generate and ship random levels without validation.

## Level Validation Metadata

Each level should include an authored canonical solution:
- ordered piece IDs;
- target rotations or release conditions;
- expected state transition.

A validation tool should be able to simulate/verify the canonical path.

This is not necessarily the only valid solution.

---

# 11. HINT SYSTEM

A hint should guide, not auto-complete.

Hint sequence:
1. softly pulse the recommended ring;
2. after a brief delay, show a curved ghost arrow;
3. optionally reveal a target angle arc.

Visual hint:
- low-opacity ghost arc;
- clean arrow head;
- no giant text.

Using a hint prevents Perfect status for that completion.

---

# 12. RESTART / STATE

Restart:
- restores the complete authored initial level state.

Progress save:
- highest unlocked level;
- completion state;
- perfect state;
- best moves;
- audio setting;
- haptic setting.

Use a versioned local save format.

Do not make game progression dependent on network access.

---

# 13. SCREEN FLOW

## Boot
- minimal;
- fast;
- no unnecessary splash delay.

## Home
- logo/title;
- large Continue button;
- Level Select;
- Settings;
- subtle ambient ring motion.

## Level Select
- chapter tabs/cards;
- compact level grid;
- clear completed/perfect markers;
- locked future chapter states.

## Gameplay
Top:
- back
- level number
- restart
- hint

Center:
- puzzle only

Bottom:
- optional tiny move count / status
- otherwise keep open for visual breathing room

## Completion
- brief non-blocking celebration;
- “Perfect” or “Clear”
- move result
- Next Level
- replay icon

Avoid full-screen noisy reward pages after every 20-second puzzle.

## Settings
- sound
- haptics
- reduced motion
- reset progress behind confirmation
- privacy/about placeholder section if later needed

---

# 14. ART DIRECTION

## 14.1 Overall Identity

Style:
**Soft Enamel + Precision Vector**

The game should look designed, not generated.

Characteristics:
- bold smooth ring forms;
- premium enamel-like surfaces;
- warm soft shadows;
- restrained highlights;
- elegant negative space;
- off-white / deep-ink environments rather than pure white/black;
- 1–2 accent colors per level;
- subtle texture/noise to avoid sterile flatness.

No:
- random neon rainbow gradients;
- default Godot gray buttons;
- inconsistent corner radii;
- clip-art icons;
- excessive bloom;
- fake 3D bevels everywhere;
- asset pack mismatches.

## 14.2 Core Palette

Neutral Light:
- Background: #F5F2EB
- Panel: #FFFDF8
- Ink: #17202A
- Muted Ink: #67727E

Primary Accents:
- Cobalt: #3157D5
- Coral: #F25B50
- Jade: #2FA57C
- Amber: #E8A33A
- Violet: #8A63D2

Dark chapter palette:
- Background: #11151D
- Panel: #1A202B
- Soft Ink: #E9EEF4
- Cyan Accent: #4FD9E7

The exact combinations should be curated by chapter rather than randomly selected.

## 14.3 Ring Rendering

Rings should be vector/procedural where possible.

Recommended rendering stack:
1. soft outer shadow stroke;
2. main colored stroke;
3. narrow top highlight stroke or shader;
4. selected glow overlay;
5. optional tiny grain/noise in material/shader.

Use rounded caps and joins.

Stroke width must scale consistently.

Gap endpoints should be visibly rounded and intentional.

## 14.4 Background
Use:
- restrained radial/linear gradients;
- subtle grain/noise shader;
- optional soft ambient circles/lines;
- extremely slow parallax only if it improves life without distraction.

Never compete with the puzzle.

---

# 15. ORIGINAL CHAPTER ART THEMES

## Chapter 1 — Porcelain
Cream background, cobalt/coral/jade rings, soft warm shadow.

## Chapter 2 — Midnight
Deep navy/ink background, cyan/violet/coral enamel, soft glow accents.

## Chapter 3 — Garden
Warm sage/cream background, jade/amber/stone accents, subtle botanical curve motifs.

## Chapter 4 — Signal
Dark graphite background, controlled electric cyan + amber, precise technical line motifs.

## Chapter 5 — Gallery
Premium ivory/charcoal presentation with richer accent rotations and elegant gold-like completion highlight.

These are visual systems, not unrelated themes pasted together.

---

# 16. UI SYSTEM

Reference design grid:
- 8 px base spacing
- 16/24/32/48 common spacing units
- 16–20 px phone safe side padding depending scale
- consistent corner radii
- minimum touch target 44 logical px equivalent

Buttons:
- rounded but not pill-everything
- subtle elevation
- clear pressed state
- short press scale: about 0.96–0.98
- fast spring back

Typography:
- use a legally shippable included/open font if available;
- if no verified font asset exists, use Godot's reliable embedded default and build hierarchy through size/weight/spacing;
- never silently download an unverified-license font.

Icons:
- create as coherent SVG/vector geometry;
- matching stroke/optical weight;
- restart, hint, settings, back, sound, haptic, next.

No emoji used as product UI icons.

---

# 17. MOTION / JUICE BIBLE

The game's quality bar lives here.

## Selection
Duration: ~80–120 ms
- selected ring lifts visually through scale 1.00 → ~1.025
- shadow opens slightly
- highlight intensity rises
- soft selection tick
- light haptic hook

No giant bounce.

## Rotation
- direct finger tracking
- tiny highlight shift based on angular velocity
- optional restrained micro tick at meaningful authored sectors
- no camera shake during normal rotation

## Near Valid Alignment
When a crossing approaches a valid gap:
- subtle 100–160 ms glow pulse
- optional soft pitch-rising tick
- no auto-complete before valid threshold

## Successful Release
Choreography:
1. 40–70 ms anticipation/squash
2. 80–120 ms confirmation glow
3. 250–450 ms curved/spring release path
4. subtle fade/scale only near exit
5. 6–14 small particles, not confetti spam
6. short clean audio pluck
7. medium haptic hook
8. dependency state updates immediately and clearly

## Blocked Interaction
If piece is intentionally locked:
- 70–100 ms tiny rotation resistance/shake
- muted click
- small lock pulse
- never punish with large red flashing

## Level Complete
Total celebration target: 0.8–1.5 s
- final ring release
- center pulse
- background accent sweep
- compact particles
- title appears with eased upward motion
- result buttons enter after visual climax

Do not trap the user in a 4-second animation.

## Motion Curves
Favor:
- ease-out cubic/quart;
- spring with low overshoot;
- back-out only for playful release moments.

Avoid:
- linear UI transitions;
- excessive elastic bounce;
- random animation durations.

---

# 18. PARTICLE SYSTEM

Create a coherent tiny-particle language.

Particle families:
- release flecks;
- alignment spark;
- perfect-complete glint.

Use simple circles/diamonds/streaks generated procedurally or as vector textures.

Avoid:
- generic firework emitters;
- dozens of different particle shapes;
- full-screen confetti every level.

---

# 19. AUDIO DIRECTION

Create a small procedural/synthesized original sound pack if no audio assets are supplied.

Required sounds:
- UI tap
- ring select
- subtle rotation tick
- invalid/blocked tap
- valid alignment
- ring release
- level clear
- perfect clear
- hint reveal

Sound character:
- soft glass/wood/pluck;
- clean transient;
- minimal tail;
- no harsh mobile-game casino sounds;
- no copyrighted samples.

If generating WAVs:
- normalize sensibly;
- avoid clipping;
- keep file sizes small;
- test on phone speaker-like volume.

---

# 20. HAPTIC ABSTRACTION

Implement one service interface.

Events:
- `selection_light`
- `alignment_light`
- `release_medium`
- `perfect_success`

Actual platform implementation can use available Godot/mobile support or a later plugin.

The game must still function when haptics are unavailable.

---

# 21. TECHNICAL ARCHITECTURE

Recommended root structure:

```text
res://
  app/
    app.gd
    save_service.gd
    audio_service.gd
    haptic_service.gd
    scene_router.gd

  gameplay/
    puzzle_controller.gd
    ring_piece_2d.gd
    ring_renderer_2d.gd
    drag_rotation_controller.gd
    puzzle_rules.gd
    link_relationship.gd
    release_animator.gd
    hint_controller.gd
    level_runtime.gd

  data/
    piece_definition.gd
    link_definition.gd
    level_definition.gd
    chapter_definition.gd
    levels/

  scenes/
    boot/
    home/
    level_select/
    gameplay/
    completion/
    settings/
    components/

  ui/
    theme/
    icons/
    components/

  art/
    procedural/
    backgrounds/
    particles/

  audio/
    generated/

  shaders/

  tools/
    level_validator/
    level_preview/

  tests/
```

Adapt to an existing repo instead of blindly moving files.

---

# 22. GODOT NODE DESIGN

Gameplay scene concept:

```text
GameplayScreen (Control)
├── Background (Control/ColorRect/custom draw)
├── SafeArea (MarginContainer)
│   ├── TopHUD
│   └── PuzzleViewport (Control)
│       └── PuzzleRoot (Node2D)
│           ├── Pieces (Node2D)
│           ├── FX (Node2D)
│           └── DebugOverlay (Node2D)
├── CompletionLayer
└── TutorialLayer
```

Ring component concept:

```text
RingPiece2D (Node2D)
├── Shadow
├── MainStroke
├── HighlightStroke
├── SelectionFX
├── TouchArea
└── OptionalDebug
```

Actual renderer may use custom `_draw()`, `Line2D`, Polygon2D, SVG resources, or a hybrid after visual tests.

Choose the approach that produces the cleanest mobile result.

---

# 23. RESPONSIBILITY SEPARATION

## RingPiece2D
Owns:
- piece state
- transform
- local configuration
- visual state calls

Does not own:
- whole puzzle completion
- save system
- screen UI

## DragRotationController
Owns:
- pointer selection
- angular drag calculation
- rotation gesture lifecycle

## PuzzleRules
Owns:
- links
- gap tests
- blocked/releasable state
- dependency resolution

## PuzzleController
Owns:
- runtime orchestration
- signals
- move count
- completion check

## LevelRuntime
Owns:
- instantiating level data
- reset
- deterministic state reconstruction

## ReleaseAnimator
Owns:
- visual release choreography only

---

# 24. DATA RESOURCES

Use typed custom `Resource`s where appropriate.

## PieceDefinition
Fields:
- id
- piece_type
- position normalized or local
- radius/size
- stroke width
- start_angle
- gaps
- rotation_mode
- rotation limits
- palette index
- z_order
- release vector/path
- linked piece config

## LinkDefinition
Fields:
- a_id
- b_id
- angle_on_a
- angle_on_b
- clearance/tolerance
- rule type

## LevelDefinition
Fields:
- id
- chapter
- piece definitions
- link definitions
- par moves
- hint sequence
- canonical solution
- optional art theme override

---

# 25. RESPONSIVE LAYOUT

Design baseline:
1080 × 1920 portrait reference.

Use anchors/containers and normalized puzzle coordinates.

Support:
- 9:16
- 19.5:9
- 20:9
- tablets
- notches/safe areas

Puzzle scale should fit available region dynamically.

Do not position core UI using hardcoded physical device pixels.

---

# 26. PERFORMANCE TARGETS

Target:
- 60 FPS on reasonable modern mobile hardware.

Budgets:
- minimal overdraw;
- no full-screen expensive blur during gameplay;
- few CanvasItem shaders;
- restrained particles;
- no unnecessary `_process` on inactive pieces;
- no per-frame resource creation;
- no repeated filesystem loading during active play;
- no uncontrolled Tween creation leaks.

Profile before claiming performance is solved.

---

# 27. ACCESSIBILITY / COMFORT

- do not depend on color alone for puzzle validity;
- gap geometry remains visible through silhouette;
- reduced-motion setting disables large completion motion and particles;
- sound and haptic toggles;
- touch targets remain comfortable;
- no mandatory time pressure;
- avoid flashing.

---

# 28. CONTENT PACKAGE — V1

Shipping target:
- 60 campaign levels
- 5 visual chapters
- 6 core shape types
- 3 advanced mechanic families
- hint system
- restart
- local progress
- level select
- settings
- sound pack
- haptic hooks
- reduced motion
- full mobile responsive layout
- complete procedural/vector UI
- complete procedural/vector puzzle art
- completion polish
- validation tooling

No ads/IAP in the initial engineering definition unless separately requested.

---

# 29. TUTORIAL

Tutorial should be playable, not textual.

Level 1:
- one ring
- ghost finger/arrow demonstrates rotation
- player rotates gap to target
- immediate release

Level 2:
- two rings
- highlight the ring that can escape first

Level 3:
- player must identify correct order
- hint becomes available

Tutorial overlays disappear as quickly as possible after successful action.

---

# 30. ART PRODUCTION RULES FOR CLAUDE CODE

Claude must create all required art that can reasonably be authored inside the repo using:
- SVG;
- Godot drawing APIs;
- gradients;
- CanvasItem shaders;
- procedural textures;
- generated tiny particle sprites;
- coherent reusable themes.

The output must be deliberate.

Before producing assets:
1. define palette;
2. define stroke scale;
3. define radius scale;
4. define shadow model;
5. define highlight model;
6. define icon grid;
7. define UI spacing grid;
8. define motion language.

Then reuse those systems consistently.

No “make it colorful” randomness.

---

# 31. NO-AI-SLOP VISUAL CHECKLIST

Reject a screen if any of these are true:

- every element has a different radius;
- gradients are arbitrary;
- too many accent colors compete;
- icons use mismatched line weights;
- text hierarchy is unclear;
- empty space feels accidental;
- particles look stock;
- default Godot controls remain visibly unstyled;
- shadows use inconsistent directions;
- ring thickness changes without design reason;
- selected state depends only on a huge glow;
- tutorial has paragraphs of text;
- screen looks like disconnected generated ideas;
- art has no repeatable design system.

A coherent simpler screen is better than a busier “premium” screen.

---

# 32. GAMEPLAY QUALITY CHECKLIST

Do not ship if:

- drag rotation jumps across angle wrap;
- hit testing frequently selects wrong rings;
- selected ring can rotate off its legal axis/state;
- a release triggers in visually invalid state;
- level can enter an unrecoverable unintended state;
- restart does not exactly reconstruct the level;
- hint points to a non-valid move;
- canonical solution fails;
- touch input behaves differently from mouse in core logic;
- completion fires early;
- ring can be manipulated while its release animation owns it.

---

# 33. LEVEL TOOLING

Create an editor/debug tool or dedicated internal scene capable of:

- loading any level ID;
- displaying piece IDs;
- displaying gaps;
- displaying link crossing angles;
- displaying blockers;
- showing current ring angles;
- reset;
- auto-run canonical solution;
- validate missing references;
- validate duplicate IDs;
- validate invalid radii/gap values;
- report canonical solution success/failure.

This tooling is required before mass-producing all 60 levels.

---

# 34. TESTING STRATEGY

At minimum:

## Script/Parse
All GDScript parses cleanly.

## Runtime Smoke
Boot → Home → Level Select → Gameplay → Complete → Next.

## Input
- mouse drag
- touch emulation
- cancel/release gesture
- drag outside original hit area
- rapid taps

## Puzzle Rules
- valid link clearing
- invalid link remains
- multiple gaps
- locked piece
- linked rotation
- completion

## Save
- save progress
- relaunch
- version migration/default handling

## Level Validation
Run validator across all shipping levels.

## Responsive
Check at multiple portrait sizes.

## Performance
Observe frame behavior with most complex shipping level.

---

# 35. GODOT AI MCP WORKFLOW

Current Godot AI v4 requires Godot 4.7+ and is designed to connect Claude Code to a live Godot editor. Use the Godot AI dock-generated Claude Code configuration rather than inventing an alternate bare HTTP MCP entry.

Expected workflow:

1. Open the correct Godot project.
2. Confirm `addons/godot_ai/plugin.cfg` exists if using Godot AI.
3. Confirm Godot AI plugin is enabled.
4. Confirm Godot AI dock reports server connected.
5. Configure Claude Code from the Godot AI dock if not already configured.
6. Launch Claude Code from the project root.
7. Approve project MCP access if prompted.
8. Verify `/mcp` shows the Godot connection.
9. Query the live scene/editor before making assumptions.
10. Use MCP scene/script/runtime/error operations throughout development.
11. Prefer GDScript for the deepest current Godot AI integration.
12. If MCP fails, diagnose before claiming editor verification.

Do not install a second competing Godot MCP implementation into a working project unless the user explicitly requests it.

---

# 36. CLAUDE CODE PROJECT STARTUP PROCESS

On first run, Claude must:

1. read root `CLAUDE.md`;
2. locate `.claude/` project instructions if present;
3. enumerate available Claude skills relevant to the project;
4. read relevant game/Godot/design/testing skills before implementation;
5. inspect repository structure;
6. inspect `project.godot`;
7. inspect Git status;
8. preserve existing user changes;
9. inspect existing addons/plugins;
10. verify Godot AI MCP connection;
11. inspect the live editor/scene tree;
12. inspect current errors;
13. identify project version and renderer;
14. create a concise baseline note;
15. then begin production automatically.

The user has explicitly authorized continuous execution for this build.
Do not stop for milestone approval.
Continue from one milestone into the next unless genuinely blocked by missing credentials, unavailable software, destructive ambiguity, or a manual device-only requirement.

---

# 37. DEVELOPMENT MILESTONES

## M0 — Baseline and MCP
- verify repo/editor/MCP
- capture starting Git state
- do not rewrite unrelated code

## M1 — Visual Prototype
- background system
- vector ring renderer
- one premium ring
- one interaction screen
- prove art language

Quality gate:
the first static gameplay screenshot must already look intentionally designed.

## M2 — Perfect Drag
- selection
- angular drag
- angle continuity
- hit forgiveness
- selection juice
- blocked state

Quality gate:
rotation is direct and stable.

## M3 — Puzzle Logic
- gaps
- links
- releasable state
- deterministic release
- reset

## M4 — Two/Three Piece Vertical Slice
- real puzzle
- premium release animation
- completion sequence
- sound/haptic hooks

Quality gate:
a 15-second recording should look like a real mobile game, not an engine prototype.

## M5 — App Shell
- Boot
- Home
- Level Select
- Settings
- Gameplay
- Completion
- save progress

## M6 — Data/Tooling
- custom Resources
- level loader
- validator
- canonical solution verification
- debug visualizer

## M7 — First 12 Levels
- Chapter 1
- tutorial
- curated difficulty
- validate every level

## M8 — Advanced Shapes
- D/U/triangle/square
- Chapter 2/3 mechanics
- coherent art variants

## M9 — Advanced Rules
- limited rotation
- one-way
- gear pair
- chapters 4/5

## M10 — Full Content
- 60 validated levels
- par values
- hints
- chapter polish

## M11 — Final Art/Juice Pass
- no placeholder UI
- all icons
- final themes
- particles
- audio
- haptic hooks
- animation consistency

## M12 — Shipping QA
- all levels validate
- runtime smoke
- responsive checks
- save/reload
- error cleanup
- performance
- export readiness
- final evidence report

---

# 38. SHIPPABLE DEFINITION OF DONE

The project is not finished until:

- launches without script errors;
- all primary screens are styled;
- no default placeholder art remains;
- core drag interaction feels stable;
- all 60 levels load;
- canonical solution validator passes all 60;
- progression saves and reloads;
- restart is deterministic;
- hint works;
- completion works;
- settings persist;
- portrait layouts work across representative resolutions;
- major animations obey the same motion system;
- audio cues exist and are mixed reasonably;
- reduced motion works;
- no obvious debug UI ships enabled;
- Godot output does not contain recurring project-caused errors;
- Git diff is explainable;
- final report distinguishes VERIFIED / CLAIMED / NEEDS USER CHECK.

---

# 39. FINAL QUALITY BAR

Ask these questions before calling the game done:

### Art
Would a screenshot look intentional if shown without explanation?

### Juice
Does a ring release make the player want to do another one?

### Gameplay
Can a player understand why a ring is blocked or free?

### Input
Does touching and rotating feel better than simply dragging a UI knob?

### Cohesion
Do Home, Level Select, Gameplay and Completion look like the same product?

### Shipping
Could this build be handed to a QA tester without apologizing for placeholder content?

If any answer is no, continue polishing.

---

# 40. EVIDENCE STANDARD

Use only:

**VERIFIED**
Actually run/observed.

**CLAIMED**
Expected by code/docs but not directly verified.

**NEEDS USER CHECK**
Requires physical-device feel, store-side configuration, subjective final review, or something unavailable to the agent.

Never disguise CLAIMED as VERIFIED.

---

# 41. FINAL DELIVERY REPORT

At the end, provide:

## SHIPPABLE BUILD STATUS
What is complete.

## VERIFIED
Exactly what was run and observed.

## CONTENT
Level count, chapters, mechanics.

## ART
Procedural/vector assets created, themes, icons, VFX.

## AUDIO
Generated/integrated cues.

## TESTS
Validator and smoke-test outcomes.

## PERFORMANCE
What was actually profiled/observed.

## GIT
Branch, changed files summary, status.

## NEEDS USER CHECK
Only remaining device/subjective/store checks.

## BLOCKERS
If any.

Do not call the game shippable if a critical blocker remains.
