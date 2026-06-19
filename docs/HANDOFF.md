# Handoff (edit me)

Short, factual notes so the next session—human or agent—starts aligned.

## Current focus

- Melee-style ground movement with Fantasy Knight sprite animations wired to the FSM.

## Recent decisions

- Player uses `AnimatedSprite2D` + `FantasyKnightSpriteFrames` (idle, dash, run, turn_around, jump, fall) keyed off `MoveState`.
- Greybox tint/scale visuals removed; dash animation loops during dash state and restarts on dash dance reversal.
- Jump release applies an explicit jump-cut while rising (`velocity.y = config.gravity * delta`) so releasing jump transitions into falling immediately.
- Doubled base jump arc scale by raising both `jump_velocity` and `gravity` by 2x, preserving jump timing/feel while increasing all jump heights.

## Done recently

- Implemented dash/run/turnaround FSM in `scripts/player/player.gd` with tunables in `scripts/player/movement_config.gd`.
- Sprite facing + parry box now flip with movement direction.
- Added `scripts/tests/ground_movement_probe.gd` (5 checks, ALL PASS headless).
- Documented Cursor Cloud Godot recovery in `AGENTS.md` (startup script fallback when snapshot expires).

## Next steps

1. Playtest dash/run/turnaround feel in-editor; tune `dash_speed`, `dash_frames`, `run_speed`, `turnaround_frames`.
2. Wire `dodge` input (still unused) once air/ground dodge design is settled.
3. Add a permanent automated movement regression test scene/script if we want CI-level coverage for jump behavior.

## Open questions / risks

- Skidding in `GROUND_IDLE` with high opposing velocity only applies friction (no turnaround) until speed drops below `run_enter_speed`; confirm this matches desired Melee fidelity.
- `ground_accel` / `ground_turn_accel` exports were removed from `MovementConfig`; air tuning unchanged.
- Current validation was headless/runtime only due cloud keyboard injection limits in Godot desktop window; do a local manual feel pass for final balancing.

## Pointers

- Latest plan file: `docs/plans/` — _(none yet)_
- Movement probe: `res://scenes/tests/ground_movement_test.tscn`
- Cloud environment recovery: see `AGENTS.md` → Cursor Cloud specific instructions.
