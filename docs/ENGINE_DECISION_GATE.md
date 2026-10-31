# S.u.G WORLD — Engine decision gate (2026-11-01)

## Confirmed
- Existing Three.js/Vite app runs as a protected Vercel deployment and has rendered on iPhone.
- GitHub CI has passed on the valley rebuild branch.
- Current 3D art does not meet approved WORLD reference images.
- Windows C drive is capacity constrained; D is a FAT32 USB holding protected QUEST backups.
- No new storage purchase, no destructive changes, no extra paid services.

## Candidate comparison
| Engine | Immediate workflow | Native iOS release | Constraint |
|---|---|---|---|
| Three.js | Existing GitHub + Vercel | Requires separate iOS packaging/build/signing | 3D art and mobile performance still inadequate |
| Godot | Separate feasibility proof of concept only | Godot iOS export requires Apple toolchain (macOS/Xcode) | Editor installation and iOS signing environment unverified |
| Unity | Separate project, QUEST untouched | Apple toolchain required | Editor unavailable and local storage constrained |
| Unreal | Not first choice for current hardware | Apple toolchain required | High local resource requirements |

## Decision
Keep Three.js as the only currently verified display path. Do NOT migrate production to Godot or Unreal based on marketing claims. Godot can be evaluated only if a runnable environment with no extra charges and no impact on QUEST is verified.

## Acceptance gates for next release
1. Approved reference art compared against an actual iPhone screenshot, not a concept render.
2. Real GLB assets with provenance and license archived and hosted under project control.
3. 10-minute continuous iPhone play session, movement, fishing, gardening, save/reload.
4. Screen navigation consistent with the 16-screen master; no fake active buttons.
5. Performance and thermal measurements on target iPhone.
6. Native iOS signing, TestFlight and App Store review separately validated.

No claim of App Store readiness until all release gates pass.
