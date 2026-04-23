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
## After a successful REFLECT parry, ignore further parries and player damage briefly (avoids flip spam while volumes overlap).
@export var reflect_parry_cooldown_frames: int = 14
## REFLECT: if true, escape is horizontal only (sidescroller); if false, use full 2D away from `player`.
@export var reflect_escape_horizontal_only: bool = true
## Minimum speed applied when reflecting if `travel_velocity` is near zero.
@export var reflect_min_speed: float = 260.0
## After REFLECT, set this `Polygon2D` node's fill color (empty name = skip).
@export var reflect_visual_polygon_name: StringName = &"BoltVisual"
@export var reflected_visual_color: Color = Color(0.2, 0.88, 1.0, 1.0)
## Wait this many physics frames before the first startup phase (boss pacing / staggered attacks).
@export var defer_begin_frames: int = 0

var _phase: Phase = Phase.STARTUP
var _phase_frames_left: int = 0
var _parry_consumed: bool = false
var _reflect_parry_cooldown: int = 0
var _waiting_first_begin: bool = false
var _defer_begin_remaining: int = 0


func _ready() -> void:
	monitoring = false
	collision_layer = 4 ## enemy_attack (project layer_3)
	collision_mask = 0
	if defer_begin_frames > 0:
		_waiting_first_begin = true
		_defer_begin_remaining = defer_begin_frames
	else:
		_waiting_first_begin = false
		_begin_startup()


func _physics_process(delta: float) -> void:
	if _waiting_first_begin:
		if _defer_begin_remaining > 0:
			_defer_begin_remaining -= 1
		if _defer_begin_remaining == 0:
			_begin_startup()
			_waiting_first_begin = false
		return

	if travel_velocity.length_squared() > 0.0001:
		global_position += travel_velocity * delta

	if _phase_frames_left > 0:
		_phase_frames_left -= 1
	if _phase_frames_left > 0:
		if _reflect_parry_cooldown > 0:
			_reflect_parry_cooldown -= 1
		return
	_advance_phase()

	if _reflect_parry_cooldown > 0:
		_reflect_parry_cooldown -= 1


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
	if _reflect_parry_cooldown > 0:
		return false
	return is_damage_active()


## Returns NONE if the parry did not apply. Pass `player` for REFLECT so velocity escapes away from them.
func try_apply_parry(player: Node2D = null) -> ParryOutcome:
	if parry_policy == ParryPolicy.UNPARRYABLE:
		return ParryOutcome.NONE
	if _phase != Phase.ACTIVE:
		return ParryOutcome.NONE

	if outcome_on_parry == ParryOutcome.REFLECT:
		if _reflect_parry_cooldown > 0:
			return ParryOutcome.NONE
		if player != null and is_instance_valid(player):
			_set_reflect_velocity_away_from(player)
		else:
			travel_velocity.x *= -1.0
		_apply_reflect_visual()
		_reflect_parry_cooldown = reflect_parry_cooldown_frames
		return ParryOutcome.REFLECT

	if _parry_consumed:
		return ParryOutcome.NONE

	_parry_consumed = true
	monitoring = false
	_phase = Phase.RECOVERY
	_phase_frames_left = recovery_frames
	return outcome_on_parry


func _set_reflect_velocity_away_from(player: Node2D) -> void:
	var rel := global_position - player.global_position
	var speed := travel_velocity.length()
	if speed < 1.0:
		speed = reflect_min_speed

	if reflect_escape_horizontal_only:
		var ax := rel.x
		if absf(ax) < 3.0:
			## Same column as player: move opposite current horizontal travel (still away if we can infer).
			ax = -travel_velocity.x
		var dir_x := signf(ax)
		if dir_x == 0.0:
			dir_x = 1.0
		travel_velocity = Vector2(dir_x * speed, 0.0)
	else:
		if rel.length_squared() < 1.0:
			rel = Vector2(-signf(travel_velocity.x), -signf(travel_velocity.y))
			if rel.length_squared() < 0.0001:
				rel = Vector2.RIGHT
		travel_velocity = rel.normalized() * speed


func _apply_reflect_visual() -> void:
	if reflect_visual_polygon_name.is_empty():
		return
	var vis := get_node_or_null(String(reflect_visual_polygon_name))
	if vis is Polygon2D:
		(vis as Polygon2D).color = reflected_visual_color
