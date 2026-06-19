# Handoff (edit me)

Short, factual notes so the next session—human or agent—starts aligned.

## Current focus

- Environment reliability after snapshot expiry fallback in Cursor Cloud (Linux).

## Recent decisions

- Use upstream Godot 4.6 Linux binary (matches `project.godot` `config/features` tag).
- Prime imports/classes once with headless editor launch before first run to avoid initial parse/import errors.

## Done recently

- Added idempotent cloud startup/update script plan: if `godot` is missing, download/install Godot 4.6, restore `/home/ubuntu/.local/bin/godot`, and restore `/usr/local/bin/godot`.
- Verified update script behavior and engine command output (`4.6.stable.official.89cea1439`).
- Re-validated project startup via headless run after script execution.

## Next steps

1. Keep startup script as source-of-truth for dependency refresh when snapshot fallback happens.
2. If setup time becomes costly, move Godot installation into base cloud environment provisioning.

## Open questions / risks

- Download/install step depends on GitHub release availability during startup.

## Pointers

- Latest plan file: `docs/plans/` — _(none added in this session)_
- Related chat summary: `docs/agent-chats/` — _(optional; not added yet)_
