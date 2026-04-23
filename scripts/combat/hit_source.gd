class_name HitSource
extends Area2D
## Authored attack volume with phased timing and parry metadata.

enum Phase { STARTUP, ACTIVE, RECOVERY }

enum ParryPolicy { PARRYABLE, UNPARRYABLE }

enum ParryOutcome { DEFLECT, REFLECT, COUNTER_WINDOW, NONE }

@export var startup_frames: int = 10
@export var active_frames: int = 5
@export var recovery_frames: int = 18
@export var parry_policy: ParryPolicy = ParryPolicy.PARRYABLE
@export var outcome_on_parry: ParryOutcome = ParryOutcome.DEFLECT
@export var loop_attack: bool = true
@export var travel_velocity: Vector2 = Vector2.ZERO

var _phase: Phase = Phase.STARTUP
var _phase_frames_left: int = 0
var _parry_consumed: bool = false


func _ready() -> void:
	monitoring = false
	collision_layer = 4 ## enemy_attack (project layer_3)
	collision_mask = 0
	_begin_startup()


func _physics_process(delta: float) -> void:
	if travel_velocity.length_squared() > 0.0001:
		global_position += travel_velocity * delta

	if _phase_frames_left > 0:
		_phase_frames_left -= 1
	if _phase_frames_left > 0:
		return
	_advance_phase()


func _begin_startup() -> void:
	_phase = Phase.STARTUP
	_phase_frames_left = startup_frames
	_parry_consumed = false
	monitoring = false
	set_deferred(&"monitorable", true)


func _advance_phase() -> void:
	match _phase:
		Phase.STARTUP:
			_phase = Phase.ACTIVE
			_phase_frames_left = active_frames
			monitoring = true
		Phase.ACTIVE:
			_phase = Phase.RECOVERY
			_phase_frames_left = recovery_frames
			monitoring = false
		Phase.RECOVERY:
			if loop_attack:
				_begin_startup()
			else:
				queue_free()


func is_damage_active() -> bool:
	return _phase == Phase.ACTIVE and not _parry_consumed


func is_parryable_now() -> bool:
	return parry_policy == ParryPolicy.PARRYABLE and is_damage_active()


func can_damage_player() -> bool:
	return is_damage_active()


## Returns NONE if the parry did not apply.
func try_apply_parry() -> ParryOutcome:
	if parry_policy == ParryPolicy.UNPARRYABLE:
		return ParryOutcome.NONE
	if _phase != Phase.ACTIVE:
		return ParryOutcome.NONE

	if outcome_on_parry == ParryOutcome.REFLECT:
		travel_velocity.x *= -1.0
		return ParryOutcome.REFLECT

	if _parry_consumed:
		return ParryOutcome.NONE

	_parry_consumed = true
	monitoring = false
	_phase = Phase.RECOVERY
	_phase_frames_left = recovery_frames
	return outcome_on_parry
