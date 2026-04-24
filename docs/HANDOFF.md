# Handoff (edit me)

Short, factual notes so the next session—human or agent—starts aligned.

## Current focus

- Core movement tuning: implemented variable jump height via jump-cut on button release.

## Recent decisions

- Jump release now applies an explicit jump-cut while rising (`velocity.y = config.gravity * delta`) so releasing jump transitions into falling immediately.
- Kept the existing `jump_release_gravity_mult` behavior for additional fall acceleration after release.

## Done recently

- Added variable jump behavior in `scripts/player/player.gd` using `Input.is_action_just_released("jump")` while ascent is active.
- Verified behavior with a headless probe run (short hold: `7.57px`, long hold: `48.38px`, release-to-fall: `1` frame, PASS).

## Next steps

1. Playtest in-editor with gamepad/keyboard and tune `jump_velocity`, `gravity`, and `jump_release_gravity_mult` for desired feel.
2. Add a permanent automated movement regression test scene/script if we want CI-level coverage for jump behavior.

## Open questions / risks

- Current validation was headless/runtime only due cloud keyboard injection limits in Godot desktop window; do a local manual feel pass for final balancing.

## Pointers

- Latest plan file: `docs/plans/` — _(none yet)_
- Related chat summary: `docs/agent-chats/` — _(none added for this change)_
