# Handoff (edit me)

Short, factual notes so the next session—human or agent—starts aligned.

## Current focus

- Melee-style ground movement with Fantasy Knight sprite animations wired to the FSM.

## Recent decisions

- Player uses `AnimatedSprite2D` + `FantasyKnightSpriteFrames` (idle, dash, run, turn_around, jump, fall) keyed off `MoveState`.
- Greybox tint/scale visuals removed; dash animation loops during dash state and restarts on dash dance reversal.

## Done recently

- Implemented dash/run/turnaround FSM in `scripts/player/player.gd` with tunables in `scripts/player/movement_config.gd`.
- Sprite facing + parry box now flip with movement direction.
- Added `scripts/tests/ground_movement_probe.gd` (5 checks, ALL PASS headless).

## Next steps

1. Playtest dash/run/turnaround feel in-editor; tune `dash_speed`, `dash_frames`, `run_speed`, `turnaround_frames`.
2. Replace greybox tint/scale with `AnimatedSprite2D` clips keyed off `MoveState`.
3. Wire `dodge` input (still unused) once air/ground dodge design is settled.

## Open questions / risks

- Skidding in `GROUND_IDLE` with high opposing velocity only applies friction (no turnaround) until speed drops below `run_enter_speed`; confirm this matches desired Melee fidelity.
- `ground_accel` / `ground_turn_accel` exports were removed from `MovementConfig`; air tuning unchanged.

## Pointers

- Latest plan file: `docs/plans/` — _(none yet)_
- Movement probe: `res://scenes/tests/ground_movement_test.tscn`
