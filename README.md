# FTWSA

PC-first 2D sidescroller: platform-fighter–inspired movement, parry-centric combat (Expedition 33–style inspiration), high-lethality encounters, controller-first input. Godot 4 (2D).

**Repo:** [github.com/omarelsahy/FTWSA](https://github.com/omarelsahy/FTWSA)

## Run

1. Install [Godot 4.6+](https://godotengine.org/download) (Forward Plus renderer is set in the project; 4.6 matches the current `config/features` tag).
2. **Import** this folder as a project (or open `project.godot`).
3. Press **F5** — you should see a debug HUD: movement vectors, jump/parry/dodge flags, FPS capped at **60** and physics at **60 Hz**.

### Godot on `PATH` (Windows)

WinGet’s Godot package often **does not** add a `godot` command unless WinGet can create aliases (commonly needs an elevated install). Put a folder on your **user** `PATH` that contains either `Godot_*_win64.exe` or a tiny shim named `godot.cmd` that launches it.

On this machine, `F:\Projects\bin` is already on user `PATH` and includes `godot.cmd` plus the portable editor exe. If `godot` is still “not recognized” inside Cursor, **restart Cursor** (or open a new Windows terminal after a PATH change) so the process picks up the updated user environment.

Default bindings are registered at runtime if missing (see `autoload/game_input.gd`): **WASD** + arrows, **Space** jump, **E** parry, **Shift/Z** dodge; gamepad uses **left stick + D-pad**, **A** jump, **LB** parry, **B** dodge.

## Cross-device and AI context

Plans, session summaries, and a short **handoff** log live in Git under `docs/` so you can continue on another machine without relying on local Cursor history. See `docs/README.md`, keep `docs/HANDOFF.md` current, and use `AGENTS.md` for agent-facing pointers.
