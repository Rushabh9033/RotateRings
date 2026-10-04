You are the lead developer responsible for taking this Godot project from its current state to a complete, polished, shippable 2D mobile puzzle game.

Your standard is not “prototype complete.” Your standard is a game that can be handed to QA and feels intentionally designed in gameplay, juice, motion, UI, and art.

PROJECT
Working title: LOOPSHIFT
Genre: 2D portrait mobile rotate/unlink puzzle
Engine: the existing Godot 4.x project, with Godot AI MCP
Language: prefer GDScript
Target: iOS + Android
Quality priorities, in order:
1. tactile gameplay
2. coherent art direction
3. animation/juice
4. deterministic puzzle logic
5. level quality
6. responsive mobile UI
7. performance
8. shipping cleanliness

AUTHORITATIVE DESIGN DOCUMENT
Read `LOOPSHIFT_2D_GDD.md` completely before implementing anything.

MANDATORY STARTUP PROCESS

1. Read the root `CLAUDE.md` completely.
2. Inspect all project-specific Claude instructions under `.claude/` if present.
3. Enumerate available skills and read the skills relevant to Godot, game development, UI/art, testing, debugging, and repository work before coding.
4. Inspect the repository before touching it.
5. Inspect `git status` and preserve every pre-existing user change.
6. Locate and inspect `project.godot`.
7. Inspect the current scene/script/resource structure.
8. Inspect existing plugins/autoloads.
9. Verify the existing Godot AI MCP connection to the LIVE editor.
10. Query the live scene tree/editor state through MCP.
11. Inspect current Godot errors/warnings.
12. Determine the actual Godot version and renderer.
13. Do NOT install an alternative competing MCP server if the existing Godot AI integration is healthy.
14. If Godot AI is present but not connected, diagnose and repair the existing setup using its project configuration before starting production.

GODOT AI RULE

Use Godot AI MCP as a real part of the workflow, not as a box to tick.

Use it to inspect scenes, build/edit nodes where appropriate, validate GDScript, inspect editor/runtime state, run relevant scenes/tests, and inspect errors.

Do not say something is verified because a file exists.
Run it and observe it whenever the tools allow.

CONTINUOUS EXECUTION AUTHORIZATION

The user explicitly wants this game built end-to-end without stopping for approval after every milestone.

Once the baseline inspection is complete, proceed automatically through the milestones in `LOOPSHIFT_2D_GDD.md`.

Do NOT pause after a milestone merely to ask “should I continue?”
Continue.

Only stop before completion if there is a REAL blocker that cannot safely be resolved without the user, such as:
- missing credential/signing secret;
- destructive ambiguity involving existing user data;
- unavailable required software that cannot be installed safely;
- a physical-device-only action that blocks further engineering.

If an item merely needs final user visual/feel review, mark it NEEDS USER CHECK and continue with all other work.

NO PLACEHOLDER SHIPPING

You may use temporary debug art only during implementation, but before the final shipping gate you must remove or replace all placeholder-looking content.

Forbidden final-state shortcuts include:
- default Godot buttons/theme;
- generic gray panels;
- random gradients;
- crude circles presented as final art;
- emoji icons;
- inconsistent SVG styles;
- mismatched shadows;
- “TODO” visual screens;
- fake buttons;
- unimplemented settings;
- dead menu items;
- random stock-looking particles;
- unverified level generation;
- screens that are technically functional but visually unfinished.

ART RESPONSIBILITY

You are responsible for creating the complete in-repo art system needed for this version.

Do NOT wait for an external artist.

Create cohesive original art using tools available in the repo/environment, especially:
- SVG/vector assets;
- Godot draw APIs;
- Line2D/Polygon2D/custom drawing;
- procedural gradients/textures;
- CanvasItem shaders;
- procedural particle sprites;
- reusable Godot Theme resources;
- generated audio where feasible.

Before drawing assets, define and document:
- palette;
- spacing grid;
- stroke system;
- ring thickness scale;
- shadow direction/softness;
- highlight treatment;
- icon grid;
- corner-radius system;
- motion curves.

Then enforce those decisions throughout the product.

The art must look like ONE product.

Never copy the exact UI, art, assets, level layouts, branding, or proprietary presentation of the reference game/category.

GAME FEEL REQUIREMENT

The quality bar is concentrated in the first interaction.

The ring must rotate with proper angular finger tracking around its center, not naïve horizontal-delta control.

Selection, near-alignment, blocked interaction, release, and completion all need restrained but premium feedback.

Tune:
- timing;
- easing;
- scale;
- highlights;
- shadows;
- particles;
- sound;
- haptic hooks.

Do not bury weak input underneath effects.

LEVEL QUALITY

Create the full V1 campaign specified in the GDD.

Do not mass-generate random unverified levels.

Build the data-driven system and validator first.

Every shipping level must:
- load;
- have valid references;
- have a canonical solution;
- pass validation;
- fit the viewport;
- use a deliberate mechanic/difficulty purpose.

Maintain a clear difficulty curve.

TEST/VERIFY LOOP

For every meaningful system:

1. inspect existing implementation;
2. implement narrowly;
3. parse/validate scripts;
4. run the relevant scene/project;
5. inspect errors/output;
6. fix introduced issues;
7. verify behavior with available MCP/runtime evidence;
8. continue.

Create automated/internal validation for level data.

Do not suppress errors just to produce a clean-looking report.

GIT SAFETY

Never use:
- `git reset --hard`
- `git clean -fd`
- destructive checkout/revert of unrelated files

Do not erase pre-existing user changes.

At major checkpoints, inspect Git status.

Do not claim a clean repository if it is not clean.

ARCHITECTURE

Use the architecture in `LOOPSHIFT_2D_GDD.md` as the intended direction, but adapt intelligently to the existing repository.

Keep input, puzzle rules, rendering, animation, level data, UI, saves, audio, and haptics separated.

Do not build one giant script.

Use typed GDScript where practical.

Use Resources/data for levels.

Avoid unnecessary autoloads and per-frame allocations.

PRODUCTION MILESTONES

Execute all milestones from M0 through M12 in the GDD continuously:

M0 baseline + MCP
M1 art language / visual prototype
M2 perfect drag
M3 puzzle logic
M4 polished vertical slice
M5 app shell
M6 data + tooling
M7 first chapter
M8 advanced shapes
M9 advanced rules
M10 full 60-level content
M11 final art/juice/audio polish
M12 shipping QA

At each milestone:
- keep a concise running production note;
- verify the milestone’s quality gate;
- fix regressions before proceeding.

Do not turn the running note into a huge documentation project. The game is the deliverable.

SHIPPING GATE

Do not call the game finished until all requirements under “SHIPPABLE DEFINITION OF DONE” in the GDD are satisfied or explicitly marked as a genuine NEEDS USER CHECK.

Before finalizing:
- run the full level validator;
- run gameplay smoke flow;
- test representative portrait resolutions;
- verify save/reload;
- inspect Godot errors;
- inspect all menus for dead controls;
- verify no debug visualization ships on;
- inspect art consistency;
- inspect audio behavior;
- inspect Git diff/status.

FINAL RESPONSE

When the game reaches the strongest state you can produce in this session, report only useful production evidence:

SHIPPABLE BUILD STATUS
VERIFIED
CONTENT
ART
AUDIO
TESTS
PERFORMANCE
GIT
NEEDS USER CHECK
BLOCKERS

Use exactly these evidence terms:
- VERIFIED
- CLAIMED
- NEEDS USER CHECK

Never state “shippable” if a critical gameplay, data, runtime, or visual blocker remains.

Start now by reading the instructions/GDD/skills and inspecting the repository and live Godot AI MCP state. Then continue automatically into production. Do not wait for a milestone approval.
