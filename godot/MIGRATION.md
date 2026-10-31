# S.u.G WORLD | Godot-first migration

Decision: Godot 4 is the canonical engine for WORLD going forward. Three.js remains an archived technical prototype, not the production target. S.u.G QUEST Unity remains untouched.

## Source of truth
- Formal 16 screens: 01 WORLD HOME, 02 MY AVATAR, 03 MY STORY, 04 MIND PATH, 05 MEMORY ITEMS, 06 PEOPLE, 07 FEELING, 08 BABY STEP, 09 CHALLENGE, 10 REFRAME, 11 CAN / CANNOT, 12 SELF CARE, 13 AI PARTNER, 14 COMMUNITY, 15 SAFE, 16 SETTINGS.
- MY WORLD is the 3D play space, not a 17th formal screen.
- SAFE must be reachable without login, AI, connectivity or payment.
- Gameplay position and unfinished interactions must survive opening/closing overlays.
- Official character art/logo must use approved originals, not generated replacements.
- Game theme: the player decides what they carry; overlooked experiences and relationships have meaning.
- First release: high-quality 10-minute exploration, fishing, garden and NPC experience.

## Migration matrix
| Existing subsystem | Godot target | Status |
|---|---|---|
| Three.js terrain/camera | Node3D + Camera3D | comparison placeholder only |
| Three.js movement | CharacterBody3D | code authored, untested |
| Gameplay fishing/garden | GDScript interactions | rudimentary authored, untested |
| State and event dedup | world_state.gd | authored, untested |
| 16 screen IDs | navigation.gd | registry authored, no UI |
| Official GLB characters | Godot imported assets | not started |
| AI PARTNER | offline-safe opt-in service | not started |
| iOS | Godot iOS export, signing, TestFlight | not started |

## Hard blockers
Godot executable and native iOS build environment have not been verified available. No current runtime test, real scene screenshot, iPhone build, or App Store submission. Do not call this completed.

## Protection
No Unity QUEST changes; no C/D drive operations; no paid asset purchase; no release/deployment or overwrite of Three.js production.
