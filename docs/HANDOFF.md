# Handoff (edit me)

Short, factual notes so the next session—human or agent—starts aligned.

## Current focus

- Core movement tuning: variable jump height is in and baseline jump arcs were doubled.

## Recent decisions

- Jump release now applies an explicit jump-cut while rising (`velocity.y = config.gravity * delta`) so releasing jump transitions into falling immediately.
- Kept the existing `jump_release_gravity_mult` behavior for additional fall acceleration after release.
- Doubled base jump arc scale by raising both `jump_velocity` and `gravity` by 2x, preserving jump timing/feel while increasing all jump heights.
- Use upstream Godot 4.6 Linux binary (matches `project.godot` `config/features` tag) in Cursor Cloud.
- Prime imports/classes once with headless editor launch before first run to avoid initial parse/import errors.

## Done recently

- Added variable jump behavior in `scripts/player/player.gd` using `Input.is_action_just_released("jump")` while ascent is active.
- Verified behavior with a headless probe run (short hold: `15.07px`, long hold: `96.69px`, release-to-fall: `1` frame, PASS).
- Documented Cursor Cloud Godot recovery in `AGENTS.md` (startup script fallback when snapshot expires).

## Next steps

1. Playtest in-editor with gamepad/keyboard and tune `jump_velocity`, `gravity`, and `jump_release_gravity_mult` for desired feel after the 2x jump scale.
2. Add a permanent automated movement regression test scene/script if we want CI-level coverage for jump behavior.

## Open questions / risks

- Current validation was headless/runtime only due cloud keyboard injection limits in Godot desktop window; do a local manual feel pass for final balancing.
- Cloud Godot install depends on GitHub release availability during VM startup fallback.

## Pointers

- Latest plan file: `docs/plans/` — _(none yet)_
- Related chat summary: `docs/agent-chats/` — _(none added for this change)_
- Cloud environment recovery: see `AGENTS.md` → Cursor Cloud specific instructions.
