class_name Player
extends CharacterBody2D
## Platform-fighter–style horizontal control with coyote time + jump buffer.

enum MoveState { GROUND_IDLE, GROUND_RUN, AIR_RISE, AIR_FALL }

@export var config: MovementConfig

var _coyote_frames_left: int = 0
var _jump_buffer_frames_left: int = 0
var _state: MoveState = MoveState.GROUND_IDLE


func _ready() -> void:
	if config == null:
		config = MovementConfig.new()
	collision_layer = 1
	collision_mask = 1
	floor_snap_length = 6.0
	up_direction = Vector2.UP


func _physics_process(delta: float) -> void:
	var on_floor := is_on_floor()

	if on_floor:
		_coyote_frames_left = config.coyote_frames
	else:
		_coyote_frames_left = maxi(0, _coyote_frames_left - 1)

	var jump_pressed := Input.is_action_just_pressed(&"jump")
	if jump_pressed:
		_jump_buffer_frames_left = config.jump_buffer_frames

	_apply_gravity(delta, on_floor)
	_apply_horizontal(delta, on_floor)

	if _jump_buffer_frames_left > 0 and (on_floor or _coyote_frames_left > 0):
		velocity.y = -config.jump_velocity
		_jump_buffer_frames_left = 0
		_coyote_frames_left = 0

	if _jump_buffer_frames_left > 0 and not jump_pressed:
		_jump_buffer_frames_left -= 1

	move_and_slide()
	_refresh_state()


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


func get_debug_overlay_text() -> String:
	var state_name: String = MoveState.keys()[_state]
	return (
		"Player\n"
		+ "state: %s\n" % state_name
		+ "vel: (%.1f, %.1f)\n" % [velocity.x, velocity.y]
		+ "floor: %s\n" % str(is_on_floor())
		+ "coyote: %d  jump_buf: %d\n" % [_coyote_frames_left, _jump_buffer_frames_left]
	)
