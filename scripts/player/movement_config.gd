class_name MovementConfig
extends Resource
## Tunable movement knobs (Melee-like: separate ground/air, turnaround, buffers).

@export_group("Ground")
@export var ground_accel: float = 2600.0
@export var ground_turn_accel: float = 4200.0
@export var ground_friction: float = 2800.0
@export var ground_speed_max: float = 300.0

@export_group("Air")
@export var air_accel: float = 1800.0
@export var air_turn_accel: float = 3200.0
@export var air_friction: float = 520.0
@export var air_speed_max: float = 320.0

@export_group("Jump / Gravity")
@export var jump_velocity: float = 450.0
@export var gravity: float = 1850.0
@export var fall_gravity_mult: float = 1.38
@export var max_fall_speed: float = 1400.0
## Extra gravity while rising if jump is released (variable jump height).
@export var jump_release_gravity_mult: float = 2.35

@export_group("Coyote / Buffer")
@export var coyote_frames: int = 6
@export var jump_buffer_frames: int = 7
