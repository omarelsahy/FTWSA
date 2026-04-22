# FTWSA

PC-first 2D sidescroller: platform-fighter–inspired movement, parry-centric combat (Expedition 33–style inspiration), high-lethality encounters, controller-first input. Godot 4 (2D).

**Repo:** [github.com/omarelsahy/FTWSA](https://github.com/omarelsahy/FTWSA)

## Run

1. Install [Godot 4.3+](https://godotengine.org/download) (Forward Plus renderer is set in the project).
2. **Import** this folder as a project (or open `project.godot`).
3. Press **F5** — you should see a debug HUD: movement vectors, jump/parry/dodge flags, FPS capped at **60** and physics at **60 Hz**.

Default bindings are registered at runtime if missing (see `autoload/game_input.gd`): **WASD** + arrows, **Space** jump, **E** parry, **Shift/Z** dodge; gamepad uses **left stick + D-pad**, **A** jump, **LB** parry, **B** dodge.
