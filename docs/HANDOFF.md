# Handoff (edit me)

Short, factual notes so the next session—human or agent—starts aligned.

## Current focus

- Development environment bring-up and run validation in Cursor Cloud (Linux).

## Recent decisions

- Use upstream Godot 4.6 Linux binary (matches `project.godot` `config/features` tag).
- Prime imports/classes once with headless editor launch before first run to avoid initial parse/import errors.

## Done recently

- Installed Godot 4.6 to user-local path:
  - binary: `/home/ubuntu/.local/lib/godot/godot`
  - command: `/home/ubuntu/.local/bin/godot`
- Verified engine version: `4.6.stable.official.89cea1439`.
- Verified project startup (headless game run):  
  `/home/ubuntu/.local/bin/godot --headless --path /workspace --quit-after 3`
- Ran one-time import/bootstrap step (headless editor):  
  `/home/ubuntu/.local/bin/godot --headless --editor --path /workspace --quit-after 5`

## Next steps

1. Run GUI playtest via `godot --path /workspace` and confirm debug HUD + controls.
2. If future cloud sessions repeat setup, add a cloud env setup profile to preinstall Godot 4.6.

## Open questions / risks

- Godot is installed per-user in the current VM; fresh VMs may need the same bootstrap until environment setup is automated.

## Pointers

- Latest plan file: `docs/plans/` — _(none added in this session)_
- Related chat summary: `docs/agent-chats/` — _(optional; not added yet)_
