# MEMORY.md — Live Snapshot

## Current State (updated: 2026-10-14)
- **Project:** LOOPSHIFT (RotateRings) — Godot 4.7.2
- **Status:** Hammer Powerup Fully Upgraded (Dark Smoke Backdrop, Popout Shapes, Exact Hammer Prompt Banner, Random 1-to-Multiple Ring Breakage, Realistic Small Colored Rock Shattering); 6K Ultra-Crisp Rendering Enforced; All Automated Tests Green.

#### Hammer Tool & Visual Polish Upgrade (2026-10-14):
1. **Atmospheric Dark Smoke Backdrop & Popout (`gameplay/hammer_animator.gd`):**
   - When Hammer tool is activated (`start_targeting`), the background smoothly cross-fades into rich dark smoke charcoal (`#121017`, 94% opacity).
   - Puzzle controller and active shapes dynamically pop out (`z_index = 65`, spring scale 1.035, brightness modulate `(1.18, 1.18, 1.14)`), giving high-contrast focus on the rings.
   - Smoothly restores to normal gameplay background upon strike or cancellation.
2. **Exact Hammer Prompt Banner:**
   - Displays a sleek floating frosted pill centered above the puzzle area (`y = 136.0`).
   - Contains the exact 3D hammer icon (crisp 36x36px render from tool card) and text: `"Tap any object to smash it"`.
   - Polished with amber glowing rim, gentle spring entrance, subtle idle breathing bob, and seamless exit fade.
3. **Random Breakage (Single vs Multiple Rings):**
   - Strike now rolls weighted random breakage:
     - ~45% chance: Single ring (only the tapped ring breaks).
     - ~35% chance: Double rings (tapped ring + 1 adjacent/connected ring).
     - ~20% chance: Triple rings (tapped ring + 2 adjacent/connected rings).
4. **Physical Colored Rocks Shattering (`ColoredRockChunk`):**
   - The intact victim rings vanish instantly on impact (`v.visible = false`), replaced by bursting small colored rocks matching the ring's exact color.
   - Each rock is rendered as a 5-7 vertex irregular polygon with 4-layer shading: soft drop shadow, dark stone rim, vibrant rock face, and top specular chiseled facet.
   - Spawns 16-20 rock chunks + 8-10 micro-gravel crumbs per victim ring, blasting radially outward away from the hammer impact point with upward arc lift, 1350 px/s² gravity, and tumbling angular spin.
5. **6K Visual Clarity & Rendering Settings (`project.godot`):**
   - Added `textures/canvas_textures/default_texture_filter=2` (Linear Mipmap for razor-sharp textures without downsampling pixelation).
   - Added `gui/theme/default_font_subpixel_positioning=3` (One Quarter of a Pixel for ultra-sharp typography on high-DPI displays).
   - Enabled `anti_aliasing/quality/msaa_2d=3` (8x MSAA) for smooth anti-aliased geometry curves.
6. **Automated Verification:**
   - `tools/test_hammer_live_interaction.gd` passed 100%.
   - `tools/test_hammer_tool_runtime.gd` passed 100%.
   - Visual verification screenshots captured: `hammer_targeting_smoke.png`, `hammer_strike_impact.png`, `hammer_colored_rocks.png`.


#### Exhaustive Codebase & 100-Level Audit (2026-10-14):
1. **Full 100-Level Deep Audit (`tools/audit_all_levels_deep.gd` & `tools/test_all_100_levels_runtime.gd`):**
   - Fixed zero-radius bar pieces in Levels 27, 28, and 29 (`campaign_board.gd` and `tools/extracted_levels/levels_11_to_30.gd`), replacing `0` with standard radius `56.0` / `68.0`.
   - Fixed duplicate piece IDs (`ring_14`, `ring_15`, `ring_16`) in Level 71 root construction (`campaign_board.gd`).
   - Fixed index out-of-bounds in `campaign_board.gd` `_walk()` on pairs with length < 2.
   - Fixed `green_pin_inner` radius in `data/user_levels/10.json` from `0.0` to `90.5`.
   - Result: **0 Fatal Errors** across all 100 campaign levels; 100/100 levels successfully instantiated in `PuzzleController` runtime.
2. **Level 18 Deep Playthrough & Verification (`tools/simulate_level_18_gameplay.gd`):**
   - 100% winnable: zero initial collisions, 4 sliders slide and release, 10 rings rotate and release sequentially, anchor hubs release. `IS LEVEL 18 WON: true`.
   - Rendered with OpenGL compatibility driver: crisp antialiased polyline contours (`segs = 160`), darker outer contour rim, compact 34x29mm sleeve connectors.
3. **Engine-Wide Bug Fixes:**
   - `gameplay/puzzle_rules.gd`: Fixed logic bug in `cuff_world_angle_deg` where `if _is_gone(parent_p) and parent_p == null:` was corrected to `if parent_p == null or _is_gone(parent_p): return 0.0`.
   - `gameplay/puzzle_controller.gd`: Added guard in `load_level` to invoke `_ready()` if `pieces_container` is null (prevents crash on manual instantiation); added `if is_inside_tree() and get_tree():` to prevent engine null tree warning.
   - `app/scene_router.gd` & `app/app.gd`: Added `restore_screen()` so toggling F2 returns exclusively to the active screen without opening multiple overlapping screens.
   - `gameplay/connector_runtime.gd`: Synchronized `TANGENTIAL_WIDTH = 34.0` with `puzzle_controller.gd`.
4. **All Screen Screenshots Updated in `screenshots/`:**
   - `01_HomeScreen.png`
   - `02_LevelSelect_Map.png`
   - `03_Gameplay_Level4.png`
   - `04_SettingsModal.png`
   - `05_PauseModal.png`
   - `06_VictoryModal.png`
   - `07_Level18_Gameplay.png`

#### All Screen UI Overhaul (2026-10-14):
1. **Home Screen Exact Match (`media_1791964682461_54554d01.png`):**
   - Built custom `HomeTitleLogo` widget rendering `R [Orange 3D C-Ring] TATE   RINGS` in bold warm chocolate brown (`#543324`), matching the user's reference image typography.
   - Removed obsolete underline rule and tagline to achieve clean, uncluttered layout.
   - Centered breathe and spin hero animation, prominent 3D coral primary PLAY button.
2. **Level Select / Journey Map Exact Match (`media_1791964742447_5e8e52ed.png`):**
   - Built custom `LevelMapTitle` header rendering `LEVEL [Cyan 3D C-Ring] MAP` and subtitle `✦ X / Y Cleared`.
   - Replaced old line path in `journey_path_drawer.gd` with two-tone 3D path:
     - Unlocked/cleared segments rendered as emerald green 3D tubes (`#27AE60`) with double golden bead pairs along each pipe.
     - Locked segments rendered as ivory/cream rail tracks (`#FAF7F2` / `#E2D6C6`).
   - Replaced level node UI in `level_node_ui.gd` with true 3D porcelain C-rings:
     - Cleared levels: Amber/Green C-rings with 3 golden beads inside the gap and level number in cream center disc.
     - Current frontier level: Vibrant orange C-ring, solid dark terracotta center disc with bold white number, and animated pulsing halo ring.
     - Locked levels: Frosted silver C-rings with vector padlock icons.
     - Milestone levels (`lvl % 5 == 0`): Orange circular badge with `+5` connected by a stem line on the right side of the node.
3. **Settings Button Bug Fix (`GameplayScreen.gd`, `GameplayScreen.tscn`):**
   - Eliminated the double-rendered emoji cog: removed legacy `text = "⚙"` font emoji and set `text = "settings"` for `squircle_button`.
   - Rendered single, smooth, 4x supersampled 6-tooth anti-aliased gear icon inside the porcelain squircle.
4. **Global Theme & Modals (`app/ui_theme.gd`, `VictoryModal.gd`, `SettingsModal.gd`, `PauseModal.gd`):**
   - Added procedural vector icons: `star`, `star_empty`, `play`, `pause`, `hint`, `settings`, `map`, `replay`, `home`, `lock`, `close`, `check`.
   - Implemented mobile iOS-style pill toggle switches with green active track and porcelain thumb.
   - Victory modal with celebratory banner, 3 animated golden stars, moves-vs-par pill, and primary Next Level button.
4. **Gameplay Screen (`scenes/gameplay/GameplayScreen.gd`):**
   - Top-left level badge, center score pill with "Game Rush" subtitle.
   - Squircle Settings button with centered gear icon.
   - Bottom powerup cards: Rocket booster with count badge (`5`), and Hammer with gray lock badge (`🔒`) matching reference screenshots.
5. **Victory Modal (`scenes/components/VictoryModal.gd`, `VictoryModal.tscn`):**
   - Celebratory title ("PERFECT!" or "LEVEL COMPLETE!").
   - 3-star rating row with sequential pop-in animations (`star_gold` vs `star_empty`).
   - Moves vs Par summary pill.
   - Primary "NEXT LEVEL ▶" button and horizontal "Replay" / "Level Map" button row.
6. **Settings & Pause Modals (`scenes/components/SettingsModal.gd`, `PauseModal.gd`):**
   - Tactile modal panels with smooth modal entrance animation.
   - Mobile toggle switches for Sound Effects, Haptics, and Reduced Motion.
   - Confirmation safety for "Reset Progress" (requires second tap).
   - Clean action buttons with matching vector icons.

#### Levels 22–26 Completed and Fully Verified (2026-10-14):
1. **Level 22 (`22.jpeg`):**
   - 18 pieces: 8 rings, 10 sliders, 9 links (`data/user_levels/22.json`).
   - Symmetrical twin-wing layout with giant red center arch and diagonal slider sleeves.
   - Zero initial tube collisions, 100% winnable in simulation (`tools/simulate_level_22_gameplay.gd`, exit code 0).
   - Side-by-side comparison verified (`_godot_test_out/side_by_side_22.png`). No yellow acorns.
2. **Level 23 (`23.jpeg`):**
   - 21 rings: 2 closed anchor hubs (`purple_hub_tl`, `blue_hub_mid`), 8 concentric pairs, 3 single C-rings, 19 links, 0 sliders (`data/user_levels/23.json`).
   - Exact circle centers and radii fitted to reference.
   - Zero initial tube collisions, 100% winnable in simulation (`tools/simulate_level_23_gameplay.gd`, exit code 0).
   - Side-by-side comparison verified (`_godot_test_out/side_by_side_23.png`). No yellow acorns.
3. **Level 24 (`24.jpeg`):**
   - 22 pieces: 15 rings (4 closed hubs: `cyan_r2`, `green_r4`, `red_r4`, `cyan_r5`; 11 C-rings), 7 rectilinear sliders, 22 links (`data/user_levels/24.json`).
   - Sliders use `shape_type: 5` (PATH / RECTILINEAR_PATH) with relative `path_points` and sleeve definitions.
   - Zero initial tube collisions, 100% winnable in simulation (`tools/simulate_level_24_gameplay.gd`, exit code 0).
   - Side-by-side comparison verified (`_godot_test_out/side_by_side_24.png`). No yellow acorns.
4. **Level 25 (`25.jpeg`):**
   - 20 pieces: 15 C-rings, 5 sliders (3 inverted-L sliders, 1 diagonal bent slider, 1 horizontal L-slider), 15 links (`data/user_levels/25.json`).
   - Exact silver and colored metallic sleeves on rings, custom blockers, and 100% clearance.
   - Zero initial tube collisions, 100% winnable in simulation (`tools/simulate_level_25_gameplay.gd`, exit code 0).
   - Side-by-side comparison verified (`_godot_test_out/side_by_side_25.png`). No yellow acorns.
5. **Level 26 (`26.jpeg`):**
   - 17 pieces: 1 central closed cyan hub (`cyan_hub`, 6 radiating spokes), 6 inner C-rings in hexagonal symmetry, 10 outer perimeter C-rings, 22 links, 0 sliders (`data/user_levels/26.json`).
   - Scaled to true reference radius ($R = 38.0$, $R_{hub} = 42.0$) with perfect clearances.
   - Zero initial tube collisions, 100% winnable in simulation (`tools/simulate_level_26_gameplay.gd`, exit code 0).
   - Side-by-side comparison verified (`_godot_test_out/side_by_side_26.png`). No yellow acorns.

#### Levels 17–21 Completed and Fully Verified (2026-10-13):
1. **Level 17 (`17.jpeg`):** 13-ring pyramidal configuration with inward radial blockers (`data/user_levels/17.json`). 100% winnable in simulation.
2. **Level 18 (`18.jpeg`):** 10-ring loop with 4 sliding rods/hooks (`data/user_levels/18.json`).
   - Red U-arch rendered with smooth rounded-corner bezier tubes and accurate leg extensions.
   - Metallic silver cuffs scaled to exact reference proportions ($20 \times 18\text{ px}$ with realistic chrome bevel and lips).
   - Inverted stem suppression for sleeves sitting inside rings/cuffs.
   - Orange center sleeve calibrated to orange color with snug stem attachment.
   - Sleeve-holder release protection in `puzzle_rules.gd` ensuring holder rings do not release before their sliders.
   - Yellow acorn fruits removed completely as requested.
   - Bottom green diagonal slider hook extended to pass through and protrude past the silver cuff matching reference.
   - 100% winnable in full simulation (`tools/simulate_level_18_gameplay.gd`).
3. **Level 19 (`19.jpeg`):** Rectilinear slide labyrinth with 9 C-rings and 11 sliders (`data/user_levels/19.json`). 100% winnable in simulation.
4. **Level 20 (`20.jpeg`):** Animal face layout with giant head ring ($R=210$), 2 eye rings, 2 nostril rings, snout C-ring, and 8 angled horn/cheek sliders (`data/user_levels/20.json`). 100% winnable in simulation.
5. **Level 21 (`21.jpeg`):** 23 rectilinear sliding pipes and sleeve collars (`data/user_levels/21.json`). 100% winnable in simulation.

#### Overall UI Transformation — Authentic Casual Hit "Game Look":
1. **Top Header HUD:**
   - Stacked warm dark roast cocoa "Level" and level number labels (`font_size = 18` and `32`, `UiTheme.WARM_INK`).
   - Warm golden/peach inset moves counter capsule (`UiTheme.warm_pill()`), large cocoa moves count ("0"), and centered red "Game Rush" subtitle.
   - Tactile porcelain squircle Settings button with bottom 3D bevel and cocoa gear icon (`UiTheme.squircle_button`).
2. **Bottom Power-up Tray:**
   - Floating tactile squircle cards (104x104 px) with golden rims and 3D bottom bevels (`UiTheme.powerup_card`).
   - Integrated high-fidelity 3D Rocket Booster and 3D Star Hammer Mallet icons.
   - Vivid circular notification badges (30x30 px, `UiTheme.red_badge`) with bold white counts ("5" and "3").
   - Satisfying tactile spring squash-and-stretch press animations (`scale = 0.92` on press, spring release).
1. **Level 14 (data/user_levels/14.json):**
   - 1:1 match to reference screenshot (14.jpeg).
   - 12 Rings ( = 60.0$, thickness .0$), 16 connector links arranged in a symmetrical  \times 3$ grid.
   - Dual- and multi-held ring mechanics: leaf rings (purple_r1c0, 
ed_r1c2, cyan_r2c1) held by multiple cuffs rotate sequentially through their holding cuffs, clearing each cuff upon gap alignment until fully detached.
   - Verified 100% winnable in headless simulation (	ools/simulate_level_14_gameplay.gd).
   - Captured in-engine screenshot level14_root.png and generated side_by_side_14.png.

2. **Level 15 (data/user_levels/15.json):**
   - 1:1 match to reference screenshot (15.jpeg) and user pixel-by-pixel feedback.
   - **Soft Edges & 2D Porcelain Shading:** Stripped away harsh dark polygon bevel ridges and specular lines across `_draw_ring_arc()` and `_draw_l_shape()`. Shading now matches the reference copy-to-copy: vibrant plastic/porcelain tube body with anti-aliasing, soft smooth drop shadows, and soft ambient top sheen.
   - **Slider Geometry & Umbrella Handles:** Replaced jagged multi-segment slider polylines with smooth parametric splines. `blue_slider` and `orange_slider` now curve smoothly into rounded umbrella handle J-hooks with exact curvature and round caps.
   - **Sleeve Alignment & Cuffs:** Corrected slider sleeve anchors to sit directly on the slider rods with 0px offset. Sleeves and connectors now match parent ring color cleanly with soft ambient drop shadows and anti-aliased rounded rect cuffs.
   - Verified 100% winnable in headless simulation (`tools/simulate_level_15_gameplay.gd`).
   - Captured in-engine screenshot `level15_root.png` and generated `side_by_side_15_v3.png`.

3. **Level 16 (data/user_levels/16.json):**
   - 1:1 match to reference screenshot (16.jpeg).
   - 13 Rings: 1 central closed red anchor hub (
ole: 1) emitting 6 radial stems, and 12 surrounding open rings (
ole: 0).
   - Symmetric top structure with dual-held acorns (orange_top), bottom-left and bottom-right branches.
   - Verified 100% winnable in headless simulation (	ools/simulate_level_16_gameplay.gd).
   - Captured in-engine screenshot level16_root.png and generated side_by_side_16.png.

#### Level 13 Pixel-Perfect Recreation & Dual-Held Central Chain (2026-10-12):
1. **Geometry & Topology Authored (`data/user_levels/13.json`):**
   - Exact 1:1 match to reference screenshot (`13.jpeg` / `media_1791818132207_98655fb7.jpg`).
   - 12 Rings ($R = 60.0$, thickness $20.0$), 3 closed root anchors (`role: 1`) and 9 playable open rings (`role: 0`), 9 connector links:
     - `blue_top_left`: $(199.7, 315.6)$, bowl opening down (gap at $90.0^\circ$, width $110.0^\circ$). Held by `green_top_mid`.
     - `green_top_mid`: $(364.7, 282.0)$, bowl opening up (gap at $270.0^\circ$, width $105.0^\circ$). Held by `red_top_right`, holds `blue_top_left`.
     - `red_top_right`: $(533.9, 310.4)$, closed circle (Root Anchor, `role: 1`). Holds `green_top_mid`.
     - `cyan_mid_top`: $(295.4, 423.8)$, bowl opening up (gap at $270.0^\circ$, width $105.0^\circ$). Held by `orange_mid_right`, holds `green_mid_left`.
     - `orange_mid_right`: $(461.4, 460.6)$, open ring opening right (gap at $0.0^\circ$, width $105.0^\circ$). Blocker arm at $251.0^\circ$, length $48.0\text{ px}$, width $14.0\text{ px}$. Held by `purple_mid_right`, holds `cyan_mid_top`.
     - `purple_mid_right`: $(486.6, 625.6)$, open ring opening down-left (gap at $140.0^\circ$, width $110.0^\circ$). Holds `orange_mid_right`. Cascades upon child release.
     - `green_mid_left`: $(171.3, 532.1)$, open ring opening left (gap at $180.0^\circ$, width $105.0^\circ$). Held by `cyan_mid_top`, holds `cyan_center`.
     - `cyan_center`: $(332.1, 579.4)$, open ring opening right (gap at $0.0^\circ$, width $105.0^\circ$). Dual-held by `green_mid_left` and `red_lower`.
     - `red_lower`: $(253.3, 729.7)$, open ring opening left (gap at $180.0^\circ$, width $105.0^\circ$). Held by `green_bot_left`, holds `cyan_center`.
     - `green_bot_left`: $(257.5, 897.8)$, closed circle (Root Anchor, `role: 1`). Holds `red_lower`.
     - `orange_lower_mid`: $(412.0, 707.6)$, bowl opening up (gap at $270.0^\circ$, width $105.0^\circ$). Blocker arm at $129.0^\circ$, length $48.0\text{ px}$, width $14.0\text{ px}$. Held by `purple_bot_right`.
     - `purple_bot_right`: $(411.0, 876.8)$, closed circle (Root Anchor, `role: 1`). Holds `orange_lower_mid`.
2. **Verification (L3 Behavioral & L4 End-to-End Simulation):**
   - Headless test `tools/simulate_level_13_gameplay.gd`:
     - Zero initial tube collisions across non-linked rings.
     - Zero initial blocker overlaps.
     - `blue_top_left` and `green_top_mid` release cleanly.
     - `cyan_center` clears both cuffs (`green_mid_left` and `red_lower`) and releases.
     - `red_lower` clears and releases.
     - `green_mid_left` and `cyan_mid_top` clear and release.
     - `orange_mid_right` clears and releases, allowing `purple_mid_right` to cascade.
     - `orange_lower_mid` clears and releases.
     - All 3 root anchors release and level is won (`IS LEVEL 13 WON: true`, exit code 0).
   - In-engine render `_godot_test_out/level13_root.png` and `side_by_side_13.png` visually verified pixel-by-pixel against `13.jpeg`.

#### Level 12 Pixel-Perfect Recreation & Bugfixes (2026-10-12):
1. **Geometry & Topology Bugfixes (`data/user_levels/12.json`):**
   - **Blue Ring & Red Slider Sleeve Clipping:** Re-oriented `blue_top_mid` gap center from $270.0^\circ$ to $245.0^\circ$ (width $105.0^\circ$). The left tip of the blue bowl now ends at $192.5^\circ$ ($y = 388.8$), providing **$53.1\text{ px}$ of clear vertical separation** below the red slider's sleeve $(342.2, 335.7)$, completely eliminating the sleeve clipping/intersection glitch.
   - **Middle & Bottom Slider Alignments:** 
     - `blue_slider_mid`: Corrected length from $206\text{ px}$ to true $130\text{ px}$ (from $(249, 572)$ to $(375, 538)$) with exact $-15.3^\circ$ diagonal tilt and `slide_max: 60.0`. Eliminates collision with the right connector stem.
     - `cyan_mid_right`: Re-oriented gap center to $215.0^\circ$ (width $105.0^\circ$), pointing up-left towards the blue slider to match `12.jpeg`.
     - `purple_slider_bot`: Calibrated length to $170\text{ px}$ with natural $+5.1^\circ$ tilt along $(0.996, 0.088)$ from $(300.0, 766.8)$ to $(469.0, 781.8)$, right tip resting inside `orange_bot_right` opening and sliding smoothly rightward upon release.
   - **Top Sliders Clearance:** Re-calibrated `orange_slider_tl` tip to $(299.6, 324.1)$ and `red_slider_top` axis to $(-0.48, -0.88)$ with origin $(378.4, 401.9)$. Exact 31.8px clearance achieved; eliminates the X-crossing/overlap bug.
   - **cyan_top_left Stem Attachment & green_mid_left Cuff Position:** Re-oriented cyan_top_left gap center to .0^\circ$ (width .0^\circ$). Adjusted green_mid_left gap center to .0^\circ$ (width .0^\circ$), ensuring the cyan cuff at .7^\circ$ sits deep on solid continuous tube with .3^\circ$ of green tube extending past it, fixing the edge-clamping glitch.
   - **orange_bot_right Collar Alignment & Cuff Position:** Re-calibrated orange_bot_right gap center to .0^\circ$ (width .0^\circ$), ensuring the cyan cuff at .5^\circ$ sits deep on solid continuous tube with .5^\circ$ of orange tube extending past it, fixing the edge-clamping glitch.
2. **Verification (L3 Behavioral & L4 End-to-End Simulation):**
   - Headless test `tools/simulate_level_12_gameplay.gd`:
     - Zero initial collisions across rings and sliders.
     - `red_slider_top` slides up-left freely and detaches.
     - `orange_slider_tl` slides up-right freely and detaches.
     - `blue_slider_mid` slides up-right and detaches.
     - `cyan_bot_left` rotates and detaches.
     - `orange_bot_right` rotates and detaches without touching `purple_slider_bot`.
     - `purple_slider_bot` slides rightward into empty space and releases.
     - Remaining middle rings cascade and release cleanly (`IS LEVEL 12 WON: true`, exit code 0).
   - In-engine render `_godot_test_out/level12_root.png` and `side_by_side_12.png` visually verified pixel-by-pixel against `12.jpeg`.

#### Level 11 Pixel-Perfect Recreation & Suspended Dual-Holder Mechanics (2026-10-12):
1. **Geometry & Topology Authored (`data/user_levels/11.json`):**
   - Exact 1:1 match to reference screenshot (`11.jpeg` / `media_1791808949465_f37da66e.jpg`).
   - 9 Rings ($R = 60.0$, thickness $20.0$), 2 anchors (`role: 1`) and 7 playable open rings (`role: 0`), 8 connector links:
     - `cyan_top_center`: $(360.0, 458.0)$, closed circle (Root Anchor, `role: 1`, `gaps: []`). Holds `orange_top_left` (at $233.4^\circ$, stem $145.9\text{ px}$) and `purple_top_right` (at $306.6^\circ$, stem $145.9\text{ px}$).
     - `orange_top_left`: $(272.9, 340.9)$, bowl opening up (gap at $270.0^\circ$, width $85.0^\circ$). Held by `cyan_top_center`, holds `red_left` (at $122.4^\circ$, stem $154.7\text{ px}$).
     - `purple_top_right`: $(447.1, 340.9)$, bowl opening up (gap at $270.0^\circ$, width $85.0^\circ$). Held by `cyan_top_center`, holds `green_right` (at $57.6^\circ$, stem $154.7\text{ px}$).
     - `red_left`: $(190.0, 471.5)$, open ring opening left (gap at $180.0^\circ$, width $85.0^\circ$). Held by BOTH `orange_top_left` (orange cuff at top) and `blue_mid` (blue cuff at bottom).
     - `green_right`: $(530.0, 471.5)$, open ring opening right (gap at $0.0^\circ$, width $85.0^\circ$, `#74D13A`). Held by BOTH `purple_top_right` (purple cuff at top) and `blue_mid` (blue cuff at bottom).
     - `blue_mid`: $(360.0, 611.5)$, suspended arch opening down (gap at $90.0^\circ$, width $110.0^\circ$). Holds `red_left` (at $219.5^\circ$, stem $220.2\text{ px}$) and `green_right` (at $320.5^\circ$, stem $220.2\text{ px}$).
     - `orange_bot_center`: $(360.0, 800.1)$, anchor arch opening down (gap at $90.0^\circ$, width $110.0^\circ$, `role: 1`). Holds `cyan_bot_left` (at $210.8^\circ$, stem $147.8\text{ px}$) and `green_bot_right` (at $329.2^\circ$, stem $147.8\text{ px}$).
     - `cyan_bot_left`: $(233.0, 724.5)$, open ring opening left (gap at $180.0^\circ$, width $85.0^\circ$). Held by `orange_bot_center`. Blocker arm at $342.0^\circ$, length $55.0\text{ px}$, width $14.0\text{ px}$, pointing inward/upward below `blue_mid`.
     - `green_bot_right`: $(487.0, 724.5)$, open ring opening right (gap at $0.0^\circ$, width $85.0^\circ$, `#27AE60`). Held by `orange_bot_center`. Blocker arm at $198.0^\circ$, length $55.0\text{ px}$, width $14.0\text{ px}$, pointing inward/upward below `blue_mid`.
2. **Engine Architecture Updates:**
   - `puzzle_rules.gd`: Fixed concentric rotation clearance in `_overlap_contact()`. When rotating a child piece whose targeted connector is in `DETACHED` state, it now correctly allows concentric rotation inside/around the retracted cuff instead of erroneously colliding with its own former holder.
3. **Verification (L3 Behavioral & L4 End-to-End Simulation):**
   - Headless test `tools/simulate_level_11_gameplay.gd`:
     - Zero initial tube collisions across all non-linked rings.
     - Zero initial blocker overlaps.
     - Blocker arm on `cyan_bot_left` prevents premature rotation into `blue_mid` (clamped to $-22.3^\circ$ with `hit_stopper: true`).
     - Dual links on `red_left` and `green_right` cleared independently; both release cleanly once both links reach `DETACHED`.
     - `blue_mid` releases automatically upon child link detachment.
     - `cyan_bot_left` and `green_bot_right` rotate to align gaps, clear orange cuffs, and release.
     - `orange_bot_center` anchor completes and releases.
     - `orange_top_left` and `purple_top_right` clear cyan cuffs and release.
     - `cyan_top_center` root anchor releases and triggers win condition (`IS LEVEL 11 WON: true`, exit code 0).
   - In-engine render `_godot_test_out/level11_root.png` and `side_by_side_11.png` visually verified pixel-by-pixel against `11.jpeg`.

#### Level 10 Pixel-Perfect Recreation & Multi-Slider Wrapper Mechanics (2026-10-12):
1. **Geometry & Topology Authored (`data/user_levels/10.json`):**
   - Exact 1:1 match to reference screenshot (`10.jpeg`).
   - 12 Pieces total (Candy / Wrapper motif) centered at $(360.0, 560.0)$ on canonical $720 \times 1280$ canvas:
     - **Central Body & Inner "H":**
       - `cyan_center`: $(360.0, 560.0)$, closed circle (Root Anchor, `role: 1`, radius $154.4\text{ px}$).
       - `cyan_arc_inner`: $(450.0, 555.0)$, radius $185.0\text{ px}$, gap at $0.0^\circ$ ($276.0^\circ$ width). Solid arc centered at $180^\circ$ ($84^\circ$ width) bows left as `(` matching `10.jpeg`. Holds `green_pin_inner` via horizontal crossbar stem (`collar_angle_deg: 180.0^\circ`, `stem_dist: 22.9\text{ px}`).
       - `green_pin_inner`: $(427.1, 555.0)$, straight pin slider (`shape_type: 5, motion_model: 1`, length $181.0\text{ px}$, axis $(0.235, 0.972)$, `slide_max: 40.0\text{ px}`, `sleeves: []`). Held by cyan cuff at $(427.1, 555.0)$.
     - **Top-Right Wrapper:**
       - `orange_arc_tr`: $(595.1, 265.7)$, open arc (radius $105.9\text{ px}$, width $108^\circ$). Held by `cyan_center`'s diagonal cyan stem ($308.6^\circ$, stem $376.7\text{ px}$).
       - `purple_slider_tr`: Purple L-shape slider with silver sleeve on vertical shaft (slides UP, `slide_max: 110.0`).
       - `red_pin_tr`: Red straight pin slider with silver sleeve (slides UP-RIGHT along $(0.910, -0.414)$, `slide_max: 90.0`).
       - `green_slider_tr`: Green L-shape slider with silver sleeve (slides RIGHT along $(0.986, -0.169)$, `slide_max: 90.0`).
     - **Bottom-Left Wrapper:**
       - `orange_arc_bl`: $(140.6, 873.9)$, open arc (radius $106.7\text{ px}$, width $108^\circ$). Held by `cyan_center`'s diagonal cyan stem ($125.0^\circ$, stem $383.0\text{ px}$).
       - `purple_slider_bl`: Purple L-shape slider with silver sleeve on horizontal shaft (slides LEFT, `slide_max: 110.0`).
       - `cyan_pin_bl`: Cyan straight pin slider with silver sleeve (slides DOWN-LEFT along $(-0.997, 0.073)$, `slide_max: 90.0`). Shortened to $X_{ref} = 136.0$ to eliminate spawn collision with diagonal stem.
       - `dg_pin_bl`: Dark green straight pin slider with silver sleeve at $X_{ref} = 174.1$ (cleanly right of diagonal stem, slides DOWN, `slide_max: 90.0`). Zero overlap with `cyan_pin_bl` or `orange_arc_bl`.
       - `lg_l_bl`: Light green L-shape slider with silver sleeve at $X_{ref} = 204.3$ on vertical leg (slides DOWN, `slide_max: 110.0`).
2. **Engine Architecture Updates:**
   - `PuzzleRulesScript.is_piece_releasable()`: Added child slider link release clearance. When a slider held as a child by an engaged connector reaches `slide_max`, it clears the cuff and releases, immediately transitioning the connector link to `DETACHED` and freeing the parent ring.
   - `PuzzleController._on_stems_layer_draw()`: Welds now center directly at `pos_stem_start`, eliminating unsightly outer perimeter bumps on inward-pointing stems.
3. **Verification (L3 Behavioral & L4 End-to-End Simulation):**
   - Headless test `tools/simulate_level_10_gameplay.gd`:
     - All 7 outer sliders slide to `slide_max` and release.
     - Both orange arcs rotate and clear their connector links and release.
     - `green_pin_inner` slides to `slide_max`, clears its connector cuff, and releases.
     - `cyan_arc_inner` releases immediately once child link detaches.
     - `cyan_center` root anchor releases via cascade once all children are cleared.
     - Level 10 win condition confirmed (`IS LEVEL 10 WON: true`, exit code 0).
   - In-engine render `_godot_test_out/level10_root.png` and `side_by_side_10.png` visually verified pixel-by-pixel against `10.jpeg`.


### Level 9 Pixel-Perfect Recreation & Blocker Arm Physics (2026-10-12):
1. **Geometry & Topology Authored (`data/user_levels/9.json`):**
   - Exact 1:1 match to reference screenshot (`media_1791798406390_2ab1aae3.jpg` / `9.jpeg`).
   - 9 Rings ($R=60.0$, thickness $20.0$), with 2 closed root anchors and 7 playable open rings:
     - `cyan_anchor`: $(140.0, 390.0)$, closed circle (Root Anchor, `role: 1`). Holds `purple` (at $9.1^\circ$, stem $177.2\text{ px}$) and `orange_mid` (at $90.0^\circ$, stem $160.0\text{ px}$).
     - `blue_anchor`: $(530.0, 335.0)$, closed circle (Root Anchor, `role: 1`). Holds `light_green` (at $90.0^\circ$, stem $175.0\text{ px}$).
     - `purple`: $(315.0, 418.0)$, bowl facing up (gap at $270.0^\circ$, width $85.0^\circ$). Held by `cyan_anchor` and `red`.
     - `orange_mid`: $(140.0, 550.0)$, inverted U (gap at $90.0^\circ$, width $85.0^\circ$). Held by `cyan_anchor`, holds `cyan_lower` (at $46.3^\circ$, stem $159.1\text{ px}$).
     - `red`: $(380.0, 555.0)$, inverted U (gap at $90.0^\circ$, width $85.0^\circ$). Holds `purple` (at $244.6^\circ$, stem $151.6\text{ px}$).
       - Blocker arm: angle $343.0^\circ$ (pointing up-right towards light green), length $52.0\text{ px}$, width $14.0\text{ px}$, rounded end cap (`has_stopper: false`).
     - `light_green`: $(530.0, 510.0)$, gap facing left/down-left at $190.0^\circ$. Held by `blue_anchor`, holds `dark_green` (at $69.4^\circ$, stem $170.9\text{ px}$).
     - `dark_green`: $(590.0, 670.0)$, backward C opening left (gap at $180.0^\circ$). Held by `light_green`.
     - `cyan_lower`: $(250.0, 665.0)$, inverted U (gap at $90.0^\circ$). Held by `orange_mid`, holds `orange_bot` (at $24.0^\circ$, stem $197.0\text{ px}$).
     - `orange_bot`: $(430.0, 745.0)$, bowl facing up (gap at $290.0^\circ$). Held by `cyan_lower`.
2. **Verification (L3 Behavioral):**
   - Headless test `tools/simulate_level_9_gameplay.gd`:
     - Zero initial tube collisions across all non-linked rings.
     - Blocker arm on `red` has zero initial spawn overlap with `light_green`.
     - Rotating `light_green` CW (+60°) is immediately clamped to $0.0^\circ$ by `red`'s blocker arm (`hit_stopper: true`).
     - Both anchors correctly tagged `role: 1`, unrotatable; all 7 pieces correctly tagged `role: 0`, rotatable.
   - In-engine render `_godot_test_out/level9_root.png` generated and visually verified side-by-side with reference image (`_godot_test_out/comparison_level9.png`).


### Level 8 Pixel-Perfect Recreation & Blocker Arm Physics (2026-10-12):
1. **Geometry & Topology Authored (`data/user_levels/8.json`):**
   - Exact 1:1 match to reference screenshot (`media_1791794738219_7fa78f72.jpg`).
   - 9 Rings with uniform radius $R=60.0$, thickness $20.0$, spaced with generous stem clearance (all center-to-center distances between connected rings expanded from ~140px to 165px–183px):
     - `blue`: $(263.9, 333.9)$, gap at $0.0^\circ$ (facing right towards dark green).
     - `dark_green`: $(455.9, 333.5)$, gap at $180.0^\circ$ (facing left towards blue).
     - `purple`: $(275.3, 508.8)$, gap at $90.0^\circ$ (facing down). Holds Blue (straight up at $266.3^\circ$, stem $175.3\text{ px}$) and Red (straight right at $357.6^\circ$, stem $183.2\text{ px}$).
     - `red`: $(458.3, 501.0)$, gap at $135.0^\circ$. Holds Dark Green (straight up at $269.2^\circ$, stem $167.5\text{ px}$).
     - `cyan`: $(238.5, 689.7)$, gap facing left/up-left at $180.0^\circ$ ($85.0^\circ$ width). Solid continuous right arc holds Orange Center cuff at $46.2^\circ$ and Orange Left cuff at $133.3^\circ$ with generous spacing.
     - `light_green`: $(507.7, 723.5)$, bowl facing up (gap at $270.0^\circ$). Held by Orange Center ($328.7^\circ$, stem $175.0\text{ px}$), holds Orange Right ($48.8^\circ$, stem $165.1\text{ px}$).
     - `orange_left`: $(114.9, 820.9)$, gap at $90.0^\circ$. Holds Cyan at $313.3^\circ$, stem $180.3\text{ px}$.
     - `orange_center`: $(358.2, 814.4)$, gap at $90.0^\circ$. Stopper stem at $50.0^\circ$ with square T-stopper cleanly attached to the solid arc end. Holds Cyan ($226.2^\circ$, stem $172.9\text{ px}$) and Light Green ($328.7^\circ$, stem $175.0\text{ px}$).
     - `orange_right`: $(616.4, 847.8)$, gap at $90.0^\circ$. Held by Light Green.
2. **Blocker Arms Implementation & Physics Collision (`PieceDefinition`, `RingPiece2D`, `PuzzleRules`):**
   - Added `@export var blockers: Array = []` to `PieceDefinition` with full serialization in `to_dict` and `apply_dict`.
   - `RingPiece2D._draw()` renders blocker arms with the exact same 3D shaded plastic bevel style (soft shadow, dark base, main color body, glossy highlight bevel), supporting rounded end caps (Cyan) and perpendicular T-stoppers (Orange Center).
   - In `PuzzleRules`: added `_blockers_hit_ring()` and integrated into `_overlap_contact()`. Blocker arms are now real physical collision obstacles in `clamp_rotation_step()`:
     - Rotating Purple CCW is immediately blocked ($0.0^\circ$ allowed) by Cyan's blocker arm.
     - Rotating Cyan CW is physically clamped when its blocker arm hits Purple ($74.5^\circ$ clamp).
3. **Verification (L3 Behavioral):**
   - Headless test `tools/simulate_level_8_gameplay.gd`: Zero initial tube collisions across all 9 pieces, blocker arm collision physically stops rotation as expected.
   - In-engine render `_godot_test_out/level8_root.png` visually verified against user reference and circled feedback.

### Level 6 Slider Mechanics & Gap Fix (2026-10-12):
1. **Root Cause of Slider Freeze:**
   - In `RingPiece2D.setup(p_def)`, `gaps` was never assigned from `p_def.gaps`, remaining an empty array `[]`.
   - This caused `RingPiece2D` to treat every arc as a fully closed 360° ring (`is_closed = true`).
   - `clamp_slide_step` tested `_point_on_tube()` against `cyan_arc` and `purple_arc`. Because their gaps were treated as non-existent, the sliders immediately collided with the closed ring body at 0.0 distance, completely preventing either slider from moving in any direction.
2. **Silver Connector Drop & Release Lifecycle Fix:**
   - Previously, the silver sleeve was drawn statically via `current_level_def.pieces` at `p_def.position`, meaning it sat pre-rendered on the board before the drop animation, and stayed behind in empty space after the L piece broke.
   - Fixed `PuzzleController._on_cuffs_layer_draw()`:
     - Only iterates `active_pieces`. If the piece is released or destroyed, the sleeve is immediately omitted.
     - During the drop intro animation (`Time.get_ticks_msec() / 1000.0 < _drop_anim_end_time`), the sleeve's position and alpha follow `p.position` and `p.modulate.a`, so it falls from the sky mounted onto the L-piece.
     - Once dropped, it rests at `p_def.position` while the player slides the L-shape through it.
     - In `ReleaseAnimator.animate_release()`, an accompanying metallic shard burst (`Color(0.78, 0.82, 0.86)`) spawns at the sleeve position, shattering the silver sleeve synchronously when the L-shape breaks.
### Level 7 Pixel-Perfect Recreation & Engine Multi-Sleeve Support (2026-10-12):
1. **Level 7 Authored & Configured (`data/user_levels/7.json`):**
   - Exact 1:1 match to reference screenshot (`media_1791791558396_4d5da6e6.jpg`).
   - 7 Rings (radius $60.0$, thickness $20.0$):
     - `cyan_center`: $(384, 450)$, gap at $350.0^\circ$ ($85^\circ$ width).
     - `purple_top`: $(394, 291)$, gap at $270.0^\circ$ ($100^\circ$ width).
     - `blue_topleft`: $(266, 351)$, gap at $165.0^\circ$ ($90^\circ$ width).
     - `red_midleft`: $(276, 561)$, gap at $180.0^\circ$ ($90^\circ$ width).
     - `orange_midright`: $(490, 561)$, gap at $320.0^\circ$ ($90^\circ$ width).
     - `green_bottomleft`: $(276, 703)$, gap at $90.0^\circ$ ($95^\circ$ width).
     - `purple_bottomright`: $(442, 699)$, gap at $90.0^\circ$ ($95^\circ$ width).
   - 2 Slider U-Brackets with 4 Silver Sleeves:
     - `green_bracket`: Spine at $x=168, y=456$, prongs enter Blue and Red rings. Sleeves at $(226, 351)$ and $(236, 561)$, sliding axis `(-1.0, 0.0)`.
     - `red_bracket`: Mathematically exact rectangular U-bracket tilted at $51.5^\circ$, prongs enter Cyan and Orange rings through their gaps. Sleeves at $(451.3, 416.6)$ and $(520.5, 502.1)$, sliding axis `(0.777, -0.629)`. Clean parallel prongs with $90^\circ$ corners.
   - 6 Links with parent-matching cuff colors (Cyan $\times 4$, Red $\times 1$, Orange $\times 1$).
2. **Engine Architecture Updates:**
   - `PieceDefinition`: Added `@export var sleeves: Array = []` with lossless serialization in `to_dict` and `apply_dict`.
   - `LinkDefinition`: Added flexible `joint_color` / `joint_color_name` / `joint_color_hex` parsing in `apply_dict`.
   - `PuzzleRules`: Fixed polyline pieces in `_cuff_hits_ring` to check segment OBBs rather than circular approximation.
   - `ReleaseAnimator`: Metallic silver shard shatter bursts emit at all sleeve locations upon slider destruction.
3. **Verification (L3 Behavioral):**
   - Headless test `tools/simulate_level_7_gameplay.gd`: Zero spawn overlaps, zero cuff hits, all leaves releasable, both brackets slide freely.
   - In-engine capture `_godot_test_out/level7_root.png` visually verified against user reference image.
   - Strictly followed user constraint: NO APK BUILT.

## Complete System Audit & Professionalism Overhaul:
1. **Full 12-Level Geometry Audit (`tools/audit_levels.py`):**
   - Audited every level for minimum stem lengths (>= 30px) and non-linked ring clearance (>= 15px).
   - Recomputed and spaced all levels with collisions or squished stems:
     - **Level 5:** Re-spaced 7-ring web to match real video reference (`level5_14.png`). Stems increased to 40px–76px (previously 0px squished collisions).
     - **Level 6:** Symmetrical 9-ring clover with central closed O-ring (all stems 53px–116px, zero collisions).
     - **Level 7:** Symmetrical twin pillar Y-arches with 46px stems.
     - **Level 9:** Symmetrical zigzag ribbon with identical 50.5px stems.
     - **Level 10:** Dual-gap center with 44px stems on both sides.
     - **Level 11:** Mathematically regular hexagonal star with 46px stems between all adjacent vertices.
     - **Level 12:** Grand finale master knot with 45px–53px stems.
   - Result: **12 / 12 Levels verified with zero collisions and generous stems**.

2. **Visual & Rendering Polish:**
   - **Rounded Cuff Collar (`puzzle_controller.gd`):** Replaced sharp blocky rectangles with `_draw_rounded_rect` (pill/capsule collar with 5px radius). Encases the 24px tube cleanly with width 28px and span 34px.
   - **Seamless Injection-Molded Stems (`puzzle_controller.gd`):** Separated connector drawing into `stems_layer` (z=0, underneath ring body) and `cuffs_layer` (z=5, above ring tube). The opaque ring body (`pieces_container` at z=2) seamlessly encloses the stem base with a flared fillet, completely eliminating visible seams, cuts, or internal shadows.
   - **Soft Downward Drop Shadow (`ring_piece_2d.gd`):** Replaced shifted oversized arc with dual-layer diffused downward shadow matching tube thickness. Completely eliminated ugly protruding gray halos and top-edge artifacts.
   - **Seamless Round End-Caps:** Hemispherical rounded ends matching the exact ring body color.
   - **Pause / Victory Modal Occlusion:** Set `z_index = 100` and `z_as_relative = false` on `PauseModal` and `VictoryModal`. Modals now 100% cover all gameplay connectors, rings, and HUD without any bleed-through.

3. **Gameplay Mechanics & Physical Stopper Collision:**
   - **Connector-to-Connector Physical Blocker (`puzzle_rules.gd`, `drag_rotation_controller.gd`):** When rotating a ring whose outgoing stem approaches an attached incoming cuff (e.g. Level 2 Orange vs Purple's cuff), rotation is physically clamped at the contact threshold (`24.0°`). The player cannot rotate through the connector, triggers a lock rattle sound and haptic vibration on hit, forcing the player to rotate the other way to reach the gap.
   - **Synchronized Connector Jiggle Vibration (`drag_rotation_controller.gd`):** When tapping a locked ring (e.g. Level 3 Blue holding children), `jiggle_locked_piece` uses `tween_method` to animate the rotation and emit `rotation_changed` on every frame of the vibration. The attached stems and cuffs vibrate in 100% rigid synchronization with the ring before settling back to resting position.
   - **Level 3 Geometry Alignment (`level_database.gd`):** Symmetrical rhombus orientation with Blue top ring opening facing UP (`270.0°`) matching video reference (`level3_play.png`). Independent cuff detachment for Orange across both Blue and Red parents.
   - **Level 4 Symmetrical Constellation & Solvability (`level_database.gd`):** Fixed all piece orientations and solution steps matching video reference (`level4_52.png`). DarkGreen top ring faces UP (`270.0°`), Blue bottom ring faces DOWN (`90.0°`), left rings (Cyan, Red) face LEFT (`180.0°`), and right rings (Orange, LightGreen) face RIGHT (`0.0°`). Solvability verified end-to-end with sequential cuff releases leading to central closed Purple O-ring cascade.
   - **Collision Impact Particles (`gameplay/collision_spark_burst.gd`, `puzzle_rules.gd`, `puzzle_controller.gd`):** When any connector rotates and hits an obstacle / blocker or when a locked piece jiggles upon tap, a high-intensity burst of 18 radial sparks, diamond flash stars, and expanding shockwave ring emits directly at the collision contact point matching the game reference video.
   - **Level 5 Topology & Solvability Alignment (`level_database.gd`):** Synchronized piece start angles and link directions directly with video reference (`lvl5_sec_00.png`):
     - Orange (`ring_0`) starts at 315.0° (opening facing top-right, held on solid body by Cyan).
     - Cyan (`ring_1`) starts at 0.0° (opening facing East, held by Purple).
     - Purple (`ring_2`) starts at 270.0° (opening facing North, held by Red).
     - Red (`ring_3`) starts at 180.0° (opening facing West).
     - LightGreen (`ring_4`) starts at 90.0° (opening facing South, held by Purple & DarkGreen).
     - Blue (`ring_5`) starts at 90.0° (opening facing South, held by LightGreen).
     - DarkGreen (`ring_6`) starts at 0.0° (holding LightGreen, freed via gap alignment cascade).
     - Result: Zero cuffs in gaps at spawn; resolves deadlock on last 3 rings; 100% solvable end-to-end.
   - **All 12 Levels Deep Solvability & Spawn Audit (`tools/test_all_levels_solvability.gd`):** Audited and resolved start angle orientations across Levels 8, 9, 11, and 12:
     - Level 8: r3 start angle corrected to 90.0° (eliminates cuff-in-gap overlap at 270°).
     - Level 9: r3 start angle corrected to 90.0° (eliminates cuff-in-gap overlap with r2 and r4).
     - Level 11: r1 start angle set to 270.0° and r5 to 270.0° (eliminates stopper collisions and cuff-in-gap).
     - Level 12: r3 start angle set to 0.0° (eliminates cuff-in-gap and blocker hit with incoming cuff at 90°).
     - Result: **12 / 12 Levels verified: 0 cuffs inside gaps at start, 100% solvable to 0 pieces**.

4. **Headless & In-Engine Verification:**
   - `test_all_levels_solvability.gd`: PASSED (12 / 12 Levels audited for spawn clearance and full solution paths).
   - `test_lvl5_sim.gd`: PASSED (Level 5 verified end-to-end with 0 remaining pieces).
   - `test_collision_particles.gd`: PASSED (Sparks burst instantiated and processed at contact points).
   - `test_level_4.gd`: PASSED (Level 4 complete 8-step solve sequence and cascade release).
   - `test_jiggle_connectors.gd`: PASSED (98 rotation events emitted during jiggle, connectors vibrate with ring, rests at 270.0°).
   - `test_connector_blocker.gd`: PASSED (Clockwise blocked at +36.9°, counter-clockwise free to -119.0°).
   - `test_gameplay_flow.gd`: PASSED (Levels 2 and 3 end-to-end solve simulations).
   - `audit_levels.py`: 12 / 12 Levels PASSED.
   - In-engine screenshots captured and verified:
     - `verify_level_5.png`: Exact match with video reference `lvl5_sec_00.png` with zero cuffs in gaps.
     - `verify_collision_particles.png`: Real-time impact spark burst and shockwave ring at contact point.
     - `verify_level_4.png`: 100% exact visual match with video reference `level4_52.png`.
     - `jiggle_frame_peak.png`: Both connectors vibrating synchronously with the ring.
     - `verify_level_2.png`: Seamless molded stem-to-ring transitions.
     - `verify_pause_modal.png`: Zero connector leak-through behind Pause modal.
     - `verify_level_3.png`: Correct rhombus alignment and symmetric Blue top ring.
      - `verify_contact_sparkle_crop.png`: Confirmed 4-point golden sparkle star with warm amber glow halo and white core sits precisely at the boundary interface where the rotating connector head meets the other ring's outer rim.

5. **Contact Point Geometry, Golden Sparkle & Touch Sound Overhaul:**
   - **Precise Contact Point Math (`gameplay/puzzle_rules.gd`):** When rotation is clamped by an obstacle, `clamp_rotation_step` computes the exact midpoint between the rotating connector head (`pos_stem_head`) and the colliding ring body's outer circumference (`contact_on_parent`). Eliminated the bug where particles previously showed up on the stationary incoming cuff.
   - **Original 4-Point Golden Star Sparkle (`gameplay/collision_spark_burst.gd`):** Matches `sparkle_crop.png` with a 4-point golden star polygon, 4-point diagonal diamond rays, brilliant white center core, warm radial amber aura, and orbiting glittering star specks. Scaled smoothly from frame 0 with local puzzle coordinates and `z_index = 25`.
   - **Tactile Touch Sound Effect (`app/audio_service.gd`, `gameplay/drag_rotation_controller.gd`):** Synthesized `generate_touch_clack()` (1550Hz click + 460Hz hollow body tap with fast exponential decay). Wired `play_connector_touch()` to fire when pieces bump into each other during rotation.

6. **Premium Transformation Phase 1 - Smart Framing & Physics Drops:**
   - **Smart Puzzle Framing (`GameplayScreen.gd`, `puzzle_controller.gd`):** Added `get_puzzle_bounds()` to calculate the exact spatial requirements of all instantiated rings based on local coordinates. The gameplay screen now uses `_frame_puzzle()` to dynamically scale and center the `PuzzleController` perfectly within the safe UI area, ensuring all levels (whether 2 rings or 20 rings) are beautifully centered and never overlap the top or bottom HUD.
   - **RigidBody2D Physics Drops (`dropped_ring_2d.gd`, `release_animator.gd`):** Replaced the old "scale up and fade out" animation with a real physics implementation. Released rings are now instantiated as a `DroppedRing2D` (a `RigidBody2D`), retaining their exact arc geometry and visual state (thickness, color, gaps, rotation). A random central and torque impulse is applied to create a satisfying, weighty gravity drop off the screen, preparing the ground for mascot interactions in future phases.

7. **Premium Transformation Phase 2 & 3 - Mascot & Journey Map:**
   - **Mascot Companion (`mascot_companion.gd`):** Built a handcrafted 2D procedural ring-sprite mascot (Rayman-style floating hands, soft circle body) using `_draw()`. Implemented a robust state machine (IDLE, WATCHING, REACT_GOOD, REACT_BAD, CATCHING, CELEBRATING).
   - **Gameplay Screen Integration (`GameplayScreen.gd`):** Mascot dynamically spawns on the HUD and reacts to gameplay. When rings unlock, it jumps and celebrates. 
   - **Signature Completion Portal Sequence:** When the final ring drops (`DroppedRing2D`), the Mascot immediately jumps to the center of the screen, freezes the falling ring in mid-air (stops physics), and triggers a massive visual expansion tween transforming the ring into a bright portal to the next level (Variant B from prompt).
   - **Vertical Level Journey Map (`LevelSelectScreen.gd`, `journey_path_drawer.gd`):** Completely tore out the rigid `GridContainer`. Implemented a math-driven S-curve (`sin(lvl)`) vertical scrolling map where levels are placed organically. A custom `_draw()` node renders smooth connecting paths and dotted lines between the journey nodes.

8. **Premium Transformation Phase 4 - Interactive Tutorial:**
   - **Handcrafted Animated Tutorial (`tutorial_hand.gd`, `hint_controller.gd`):** Built a stylized, soft-shaded 2D hand using `_draw()`. Replaced the basic "scale pulse" hint with a full path-following swipe animation that demonstrates exactly how to drag the correct ring to its target angle.
   - **Auto-Trigger & Interrupt:** The tutorial automatically plays when starting Level 1. It smoothly loops the swipe animation, but instantly fades out and destroys itself the moment the player touches a ring (`piece_selected` signal), respecting player agency.

8. **Final Core Stabilization (v1.0.0 Release Pass):**
   - **Multi-Connector Loophole Fixed:** Rewrote is_piece_releasable to require ALL incoming connectors to be perfectly aligned with gaps SIMULTANEOUSLY before a ring can release. Sequential unblocking works naturally.
   - **Connector Visual Retraction:** Retraction animation (where the connector stem shortened before release) was completely removed. When a child ring drops, the parent's connector now remains fully extended pointing into space, satisfying the visual rule 'connector should not break'.
   - **Fragment Lifecycle & Physics Leaks Fixed:** Replaced partial cleanup in puzzle_controller.gd with full pieces_container.get_children() cleanup. Added an out-of-bounds global_position bounds check to dropped_ring_2d.gd to prevent RigidBody2D fragments from simulating infinitely if they fall off screen.
   - **Responsive Puzzle Framing Fixed:** Modified _frame_puzzle() in GameplayScreen.gd to dynamically read the actual Y-bounds of TopHUD and BottomHUD, removing hardcoded pixel margin guesses, ensuring scaling is perfect on any screen size.
   - **Gap Rotation Rendering Fixed:** Removed - deg_to_rad(rotation_degrees) subtraction in RingPiece2D arc drawing, correctly aligning visible gap rendering with world-space logical gaps.
   - **Full 100% BFS Solvability:** Fixed fs_solver.gd crashing when cloning 	arget_exit_angle_deg and had_parents_initially metadata. Re-audited all 12 levels. All 12 are 100% solvable.
   - **Par Moves Tuned:** Adjusted par moves for Level 4 (8), Level 6 (10), and Level 7 (4) based on mathematically optimal BFS solution paths.
   - **Rotation Tunneling Prevented:** Confirmed clamp_rotation_step uses exact clamped angle bounding limits, mathematically preventing high-speed drag events from tunneling through solid blocking rings.

