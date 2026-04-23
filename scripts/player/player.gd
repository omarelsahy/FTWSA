class_name Player
extends CharacterBody2D
## Platform-fighter–style horizontal control with coyote time + jump buffer + parry window.

const HitSourceScript := preload("res://scripts/combat/hit_source.gd")
## Must match `HitSource.ParryOutcome` declaration order.
const PARRY_OUTCOME_DEFLECT := 0
const PARRY_OUTCOME_REFLECT := 1
const PARRY_OUTCOME_COUNTER := 2
const PARRY_OUTCOME_NONE := 3

enum MoveState { GROUND_IDLE, GROUND_RUN, AIR_RISE, AIR_FALL }

@export var config: MovementConfig
@export var parry_window_frames: int = 7
@export var counter_window_frames: int = 48
@export var camera_limit_left: int = -800
@export var camera_limit_right: int = 4400
@export var camera_limit_top: int = -600
@export var camera_limit_bottom: int = 900

var _coyote_frames_left: int = 0
var _jump_buffer_frames_left: int = 0
var _state: MoveState = MoveState.GROUND_IDLE

var _parry_frames_left: int = 0
var _parry_hud_snapshot: int = 0
var _counter_frames_left: int = 0
var _combat_log: String = ""

@onready var _hurtbox: Area2D = $Hurtbox
@onready var _parry_box: Area2D = $ParryDetector
@onready var _parry_shape: CollisionShape2D = $ParryDetector/CollisionShape2D


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


func _physics_process(delta: float) -> void:
	var on_floor := is_on_floor()

	if on_floor:
		_coyote_frames_left = config.coyote_frames
	else:
		_coyote_frames_left = maxi(0, _coyote_frames_left - 1)

	var jump_pressed := Input.is_action_just_pressed(&"jump")
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

	if _jump_buffer_frames_left > 0 and not jump_pressed:
		_jump_buffer_frames_left -= 1

	move_and_slide()
	_resolve_combat()
	_refresh_state()

	_parry_shape.disabled = _parry_frames_left <= 0
	if _parry_frames_left > 0:
		_parry_frames_left -= 1


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
	var input_x := Input.get_axis(&"move_left", &"move_right")
	var target_speed: float = input_x * (config.ground_speed_max if on_floor else config.air_speed_max)
	var accel := _pick_accel(on_floor, input_x)
	var fric: float = config.ground_friction if on_floor else config.air_friction

	if is_zero_approx(input_x):
		velocity.x = move_toward(velocity.x, 0.0, fric * delta)
	else:
		velocity.x = move_toward(velocity.x, target_speed, accel * delta)


func _pick_accel(on_floor: bool, input_x: float) -> float:
	var turning := (
		not is_zero_approx(velocity.x)
		and not is_zero_approx(input_x)
		and signf(velocity.x) != signf(input_x)
	)
	if on_floor:
		return config.ground_turn_accel if turning else config.ground_accel
	return config.air_turn_accel if turning else config.air_accel


func _refresh_state() -> void:
	if is_on_floor():
		if absf(velocity.x) < 12.0:
			_state = MoveState.GROUND_IDLE
		else:
			_state = MoveState.GROUND_RUN
	elif velocity.y < 0.0:
		_state = MoveState.AIR_RISE
	else:
		_state = MoveState.AIR_FALL


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
	var counter_line := ""
	if _counter_frames_left > 0:
		counter_line = "counter window: %d\n" % _counter_frames_left
	var combat := _combat_log if not _combat_log.is_empty() else "(no combat event)"
	return (
		"Player\n"
		+ "state: %s\n" % state_name
		+ "vel: (%.1f, %.1f)\n" % [velocity.x, velocity.y]
		+ "floor: %s\n" % str(is_on_floor())
		+ "coyote: %d  jump_buf: %d\n" % [_coyote_frames_left, _jump_buffer_frames_left]
		+ "parry_frames: %d\n" % _parry_hud_snapshot
		+ counter_line
		+ "combat: %s\n" % combat
	)
