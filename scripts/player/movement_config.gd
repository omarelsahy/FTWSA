class_name MovementConfig
extends Resource
## Tunable movement knobs (Melee-like: dash, run, turnaround, air control, buffers).

@export_group("Dash / Run")
## Burst speed during the initial dash (pixels/sec).
@export var dash_speed: float = 450.0
## Dash duration in physics frames at 60 Hz (~14 ≈ 0.23s).
@export var dash_frames: int = 14
## Sustained run speed after dash completes with direction held.
@export var run_speed: float = 300.0
## Acceleration toward `run_speed` while in run state.
@export var run_accel: float = 2600.0
## Horizontal speed threshold to enter run from a skid instead of a fresh dash.
@export var run_enter_speed: float = 80.0

@export_group("Turnaround")
## Locked turnaround duration in physics frames.
@export var turnaround_frames: int = 12
## Deceleration applied during turnaround.
@export var turnaround_friction: float = 3600.0

@export_group("Ground")
@export var ground_friction: float = 2800.0

@export_group("Air")
@export var air_accel: float = 1800.0
@export var air_turn_accel: float = 3200.0
@export var air_friction: float = 520.0
@export var air_speed_max: float = 320.0

@export_group("Jump / Gravity")
@export var jump_velocity: float = 900.0
## Extra jumps while airborne (1 = double jump). Refreshes on landing.
@export var max_air_jumps: int = 1
## Impulse for air jumps; ground/coyote jump still uses `jump_velocity`.
@export var air_jump_velocity: float = 900.0
@export var gravity: float = 3700.0
@export var fall_gravity_mult: float = 1.38
@export var max_fall_speed: float = 1400.0
## Extra gravity while rising if jump is released (variable jump height).
@export var jump_release_gravity_mult: float = 2.35

@export_group("Coyote / Buffer")
@export var coyote_frames: int = 6
@export var jump_buffer_frames: int = 7
