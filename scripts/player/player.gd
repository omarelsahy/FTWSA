class_name Player
extends CharacterBody2D
## Platform-fighter–style movement: Melee-like dash / run / turnaround on ground, coyote + air jumps + parry.

const HitSourceScript := preload("res://scripts/combat/hit_source.gd")
## Must match `HitSource.ParryOutcome` declaration order.
const PARRY_OUTCOME_DEFLECT := 0
const PARRY_OUTCOME_REFLECT := 1
const PARRY_OUTCOME_COUNTER := 2
const PARRY_OUTCOME_NONE := 3

enum MoveState {
	GROUND_IDLE,
	GROUND_DASH,
	GROUND_RUN,
	GROUND_TURNAROUND,
	AIR_RISE,
	AIR_FALL,
}

const _GROUND_STATES: Array[MoveState] = [
	MoveState.GROUND_IDLE,
	MoveState.GROUND_DASH,
	MoveState.GROUND_RUN,
	MoveState.GROUND_TURNAROUND,
]

const _STATE_VISUALS: Dictionary = {
	MoveState.GROUND_IDLE: {"color": Color.WHITE, "scale_y": 1.0},
	MoveState.GROUND_DASH: {"color": Color(0.55, 0.85, 1.0), "scale_y": 0.88},
	MoveState.GROUND_RUN: {"color": Color(0.7, 1.0, 0.75), "scale_y": 1.0},
	MoveState.GROUND_TURNAROUND: {"color": Color(1.0, 0.88, 0.45), "scale_y": 0.95},
	MoveState.AIR_RISE: {"color": Color(0.85, 0.85, 1.0), "scale_y": 1.0},
	MoveState.AIR_FALL: {"color": Color(0.9, 0.9, 0.95), "scale_y": 1.0},
}

@export var config: MovementConfig
@export var parry_window_frames: int = 7
@export var counter_window_frames: int = 48
@export var camera_limit_left: int = -800
@export var camera_limit_right: int = 4400
@export var camera_limit_top: int = -600
@export var camera_limit_bottom: int = 900
@export var parry_offset_x: float = 18.0

var _coyote_frames_left: int = 0
var _jump_buffer_frames_left: int = 0
var _air_jumps_left: int = 0
var _state: MoveState = MoveState.GROUND_IDLE
var _facing: int = 1
var _dash_frames_left: int = 0
var _turnaround_frames_left: int = 0
var _was_on_floor: bool = true

var _parry_frames_left: int = 0
var _parry_hud_snapshot: int = 0
var _counter_frames_left: int = 0
var _combat_log: String = ""
var _synthetic_input_x: Variant = null

@onready var _hurtbox: Area2D = $Hurtbox
@onready var _parry_box: Area2D = $ParryDetector
@onready var _parry_shape: CollisionShape2D = $ParryDetector/CollisionShape2D
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _sprite_base_scale: Vector2 = _sprite.scale


func _ready() -> void:
	if config == null:
		config = MovementConfig.new()
	collision_layer = 2 ## player (project layer_2)
	collision_mask = 1 ## world
	floor_snap_length = 6.0
	up_direction = Vector2.UP

	_hurtbox.collision_layer = 2
	_hurtbox.collision_mask = 4
	_hurtbox.monitorable = true
	_hurtbox.monitoring = true

	_parry_box.collision_layer = 8 ## player_parry (project layer_4)
	_parry_box.collision_mask = 4
	_parry_box.monitorable = true
	_parry_box.monitoring = true
	_parry_shape.disabled = true

	var cam := $Camera2D as Camera2D
	cam.limit_left = camera_limit_left
	cam.limit_right = camera_limit_right
	cam.limit_top = camera_limit_top
	cam.limit_bottom = camera_limit_bottom

	if not is_on_floor():
		_air_jumps_left = config.max_air_jumps

	_sync_facing_visuals()
	_sync_state_visuals()


func _physics_process(delta: float) -> void:
	var on_floor := is_on_floor()

	if on_floor:
		_coyote_frames_left = config.coyote_frames
		_air_jumps_left = config.max_air_jumps
	else:
		_coyote_frames_left = maxi(0, _coyote_frames_left - 1)

	if on_floor and not _was_on_floor:
		_on_landed()

	var jump_pressed := Input.is_action_just_pressed(&"jump")
	var jump_released := Input.is_action_just_released(&"jump")
	if jump_pressed:
		_jump_buffer_frames_left = config.jump_buffer_frames

	if Input.is_action_just_pressed(&"parry"):
		_parry_frames_left = parry_window_frames
	_parry_hud_snapshot = _parry_frames_left

	if _counter_frames_left > 0:
		_counter_frames_left -= 1

	_apply_gravity(delta, on_floor)
	_apply_horizontal(delta, on_floor)

	if _jump_buffer_frames_left > 0 and (on_floor or _coyote_frames_left > 0):
		velocity.y = -config.jump_velocity
		_jump_buffer_frames_left = 0
		_coyote_frames_left = 0
	elif _jump_buffer_frames_left > 0 and _air_jumps_left > 0:
		velocity.y = -config.air_jump_velocity
		_air_jumps_left -= 1
		_jump_buffer_frames_left = 0
		_coyote_frames_left = 0

	if _jump_buffer_frames_left > 0 and not jump_pressed:
		_jump_buffer_frames_left -= 1

	if jump_released and velocity.y < 0.0:
		## Jump cut: releasing jump flips into downward travel immediately.
		velocity.y = config.gravity * delta

	move_and_slide()
	_resolve_combat()
	_refresh_state()

	_parry_shape.disabled = _parry_frames_left <= 0
	if _parry_frames_left > 0:
		_parry_frames_left -= 1

	_was_on_floor = on_floor


func _resolve_combat() -> void:
	if _parry_frames_left > 0:
		for a in _parry_box.get_overlapping_areas():
			if a.get_script() != HitSourceScript:
				continue
			var outcome: Variant = (a as Area2D).call(&"try_apply_parry", self)
			var oi := int(outcome)
			if oi != PARRY_OUTCOME_NONE:
				_combat_log = "PARRY -> %s" % _parry_outcome_label(oi)
				if oi == PARRY_OUTCOME_COUNTER:
					_counter_frames_left = counter_window_frames
				return

	for a in _hurtbox.get_overlapping_areas():
		if a.get_script() != HitSourceScript:
			continue
		var can_hit: Variant = (a as Area2D).call(&"can_damage_player")
		if bool(can_hit):
			_combat_log = "HIT (lethal later)"
			return


func _apply_gravity(delta: float, on_floor: bool) -> void:
	if on_floor and velocity.y >= 0.0:
		velocity.y = 0.0
		return

	var g: float = config.gravity
	if velocity.y > 0.0:
		g *= config.fall_gravity_mult
	if velocity.y < 0.0 and not Input.is_action_pressed(&"jump"):
		g *= config.jump_release_gravity_mult
	velocity.y = minf(config.max_fall_speed, velocity.y + g * delta)


func _apply_horizontal(delta: float, on_floor: bool) -> void:
	var input_x := _get_input_x()
	if on_floor:
		if _state == MoveState.AIR_RISE or _state == MoveState.AIR_FALL:
			_state = MoveState.GROUND_IDLE
		_apply_ground_horizontal(delta, input_x)
	else:
		_apply_air_horizontal(delta, input_x)


func _apply_ground_horizontal(delta: float, input_x: float) -> void:
	match _state:
		MoveState.GROUND_IDLE:
			_tick_ground_idle(delta, input_x)
		MoveState.GROUND_DASH:
			_tick_ground_dash(input_x)
		MoveState.GROUND_RUN:
			_tick_ground_run(delta, input_x)
		MoveState.GROUND_TURNAROUND:
			_tick_ground_turnaround(delta, input_x)


func _tick_ground_idle(delta: float, input_x: float) -> void:
	if absf(velocity.x) >= config.run_enter_speed:
		if not is_zero_approx(input_x) and signf(input_x) == signf(velocity.x):
			_facing = int(signf(velocity.x))
			_enter_run()
			_sync_facing_visuals()
			return
		velocity.x = move_toward(velocity.x, 0.0, config.ground_friction * delta)
		return

	if not is_zero_approx(input_x):
		_start_dash(int(signf(input_x)))
		return

	velocity.x = move_toward(velocity.x, 0.0, config.ground_friction * delta)


func _tick_ground_dash(input_x: float) -> void:
	if not is_zero_approx(input_x) and signf(input_x) != float(_facing):
		## Dash dance: reverse instantly while still in dash.
		_start_dash(int(signf(input_x)))
		return

	_dash_frames_left -= 1
	velocity.x = float(_facing) * config.dash_speed

	if _dash_frames_left > 0:
		return

	if not is_zero_approx(input_x) and signf(input_x) == float(_facing):
		_enter_run()
	else:
		_state = MoveState.GROUND_IDLE


func _tick_ground_run(delta: float, input_x: float) -> void:
	if is_zero_approx(input_x):
		_state = MoveState.GROUND_IDLE
		velocity.x = move_toward(velocity.x, 0.0, config.ground_friction * delta)
		return

	if signf(input_x) != float(_facing):
		_start_turnaround()
		return

	velocity.x = move_toward(
		velocity.x,
		float(_facing) * config.run_speed,
		config.run_accel * delta
	)


func _tick_ground_turnaround(delta: float, input_x: float) -> void:
	_turnaround_frames_left -= 1
	velocity.x = move_toward(velocity.x, 0.0, config.turnaround_friction * delta)

	if _turnaround_frames_left > 0:
		return

	_facing *= -1
	_sync_facing_visuals()

	if not is_zero_approx(input_x) and signf(input_x) == float(_facing):
		_enter_run()
	elif not is_zero_approx(input_x):
		_start_dash(int(signf(input_x)))
	else:
		_state = MoveState.GROUND_IDLE


func _start_dash(dir: int) -> void:
	_facing = dir
	_state = MoveState.GROUND_DASH
	_dash_frames_left = config.dash_frames
	_turnaround_frames_left = 0
	velocity.x = float(_facing) * config.dash_speed
	_sync_facing_visuals()


func _enter_run() -> void:
	_state = MoveState.GROUND_RUN
	_dash_frames_left = 0
	_turnaround_frames_left = 0


func _start_turnaround() -> void:
	_state = MoveState.GROUND_TURNAROUND
	_turnaround_frames_left = config.turnaround_frames
	_dash_frames_left = 0


func _on_landed() -> void:
	if absf(velocity.x) >= config.run_enter_speed:
		_facing = int(signf(velocity.x)) if not is_zero_approx(velocity.x) else _facing
		_enter_run()
		_sync_facing_visuals()
	else:
		_state = MoveState.GROUND_IDLE
	_dash_frames_left = 0
	_turnaround_frames_left = 0


func _apply_air_horizontal(delta: float, input_x: float) -> void:
	var target_speed: float = input_x * config.air_speed_max
	var accel := _pick_air_accel(input_x)

	if is_zero_approx(input_x):
		velocity.x = move_toward(velocity.x, 0.0, config.air_friction * delta)
	else:
		velocity.x = move_toward(velocity.x, target_speed, accel * delta)
		if not is_zero_approx(velocity.x):
			_facing = int(signf(velocity.x))
			_sync_facing_visuals()


func _pick_air_accel(input_x: float) -> float:
	var turning := (
		not is_zero_approx(velocity.x)
		and not is_zero_approx(input_x)
		and signf(velocity.x) != signf(input_x)
	)
	return config.air_turn_accel if turning else config.air_accel


func _get_input_x() -> float:
	if _synthetic_input_x != null:
		return _synthetic_input_x
	return Input.get_axis(&"move_left", &"move_right")


func _refresh_state() -> void:
	if not is_on_floor():
		if velocity.y < 0.0:
			_state = MoveState.AIR_RISE
		else:
			_state = MoveState.AIR_FALL
	_sync_state_visuals()


func _is_ground_state(state: MoveState) -> bool:
	return state in _GROUND_STATES


func _sync_facing_visuals() -> void:
	_sprite.flip_h = _facing < 0
	_parry_shape.position.x = parry_offset_x * float(_facing)


func _sync_state_visuals() -> void:
	var visual: Dictionary = _STATE_VISUALS.get(_state, _STATE_VISUALS[MoveState.GROUND_IDLE])
	_sprite.modulate = visual["color"]
	_sprite.scale = Vector2(_sprite_base_scale.x, _sprite_base_scale.y * visual["scale_y"])


func get_facing() -> int:
	return _facing


func get_move_state() -> MoveState:
	return _state


## Demo / test harness: override horizontal input for one physics tick chain.
func set_synthetic_input_x(x: float) -> void:
	_synthetic_input_x = x


func clear_synthetic_input() -> void:
	_synthetic_input_x = null


## Test harness hook for headless probes.
func set_move_state(state: MoveState) -> void:
	_state = state
	_dash_frames_left = 0
	_turnaround_frames_left = 0
	_sync_state_visuals()


func get_ground_substate_frames() -> Vector2i:
	return Vector2i(_dash_frames_left, _turnaround_frames_left)


func _parry_outcome_label(outcome: int) -> String:
	match outcome:
		PARRY_OUTCOME_DEFLECT:
			return "DEFLECT"
		PARRY_OUTCOME_REFLECT:
			return "REFLECT"
		PARRY_OUTCOME_COUNTER:
			return "COUNTER_WINDOW"
		_:
			return "NONE"


func get_debug_overlay_text() -> String:
	var state_name: String = MoveState.keys()[_state]
	var substate := ""
	if _state == MoveState.GROUND_DASH:
		substate = "dash_frames: %d\n" % _dash_frames_left
	elif _state == MoveState.GROUND_TURNAROUND:
		substate = "turnaround_frames: %d\n" % _turnaround_frames_left
	var counter_line := ""
	if _counter_frames_left > 0:
		counter_line = "counter window: %d\n" % _counter_frames_left
	var combat := _combat_log if not _combat_log.is_empty() else "(no combat event)"
	return (
		"Player\n"
		+ "state: %s\n" % state_name
		+ "facing: %s\n" % ("right" if _facing > 0 else "left")
		+ substate
		+ "vel: (%.1f, %.1f)\n" % [velocity.x, velocity.y]
		+ "floor: %s\n" % str(is_on_floor())
		+ "coyote: %d  jump_buf: %d  air_jumps: %d\n" % [_coyote_frames_left, _jump_buffer_frames_left, _air_jumps_left]
		+ "parry_frames: %d\n" % _parry_hud_snapshot
		+ counter_line
		+ "combat: %s\n" % combat
	)
