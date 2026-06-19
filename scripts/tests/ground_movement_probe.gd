extends Node2D
## Headless probe for Melee-style dash / run / turnaround. Attach to a scene with a floor + Player.

@onready var _player: Player = $Player

var _phase := -1
var _frame := 0
var _results: PackedStringArray = PackedStringArray()
var _dash_reversals := 0
var _was_dash_right := false


func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	_frame += 1
	match _phase:
		-1:
			if _player.is_on_floor():
				_phase = 0
				_frame = 0
			elif _frame > 30:
				_results.append("FAIL never landed on floor")
				_quit()
		0:
			_simulate_input(1.0)
			if _player.get_move_state() == Player.MoveState.GROUND_DASH:
				_results.append("PASS dash from idle")
				_phase = 1
				_frame = 0
			elif _frame > 5:
				_results.append("FAIL dash from idle (state=%s)" % Player.MoveState.keys()[_player.get_move_state()])
				_quit()
		1:
			_simulate_input(1.0)
			if _player.get_move_state() == Player.MoveState.GROUND_RUN and _frame > _player.config.dash_frames + 2:
				_results.append("PASS dash -> run")
				_phase = 2
				_frame = 0
			elif _frame > 40:
				_results.append("FAIL dash -> run (state=%s)" % Player.MoveState.keys()[_player.get_move_state()])
				_quit()
		2:
			_simulate_input(-1.0)
			if _player.get_move_state() == Player.MoveState.GROUND_TURNAROUND:
				_results.append("PASS run -> turnaround")
				_phase = 3
				_frame = 0
			elif _frame > 30:
				_results.append("FAIL run -> turnaround (state=%s)" % Player.MoveState.keys()[_player.get_move_state()])
				_quit()
		3:
			_simulate_input(-1.0)
			if (
				_player.get_move_state() == Player.MoveState.GROUND_RUN
				and _player.get_facing() < 0
				and _frame > _player.config.turnaround_frames + 2
			):
				_results.append("PASS turnaround -> run (facing left)")
				_phase = 4
				_frame = 0
				_player.velocity = Vector2.ZERO
				_player.set_move_state(Player.MoveState.GROUND_IDLE)
			elif _frame > 40:
				_results.append(
					"FAIL turnaround complete (state=%s facing=%d)"
					% [Player.MoveState.keys()[_player.get_move_state()], _player.get_facing()]
				)
				_quit()
		4:
			_simulate_input(1.0)
			if _player.get_move_state() == Player.MoveState.GROUND_DASH:
				_was_dash_right = _player.get_facing() > 0
				_phase = 5
				_frame = 0
			elif _frame > 10:
				_results.append("FAIL setup dash dance")
				_quit()
		5:
			if _frame == 3:
				_simulate_input(-1.0)
			if _player.get_move_state() == Player.MoveState.GROUND_DASH and _player.get_facing() < 0:
				_dash_reversals += 1
				if _dash_reversals >= 2:
					_results.append("PASS dash dance (instant reversal)")
					_print_and_quit()
			elif _frame > 30:
				_results.append(
					"FAIL dash dance (reversals=%d state=%s facing=%d)"
					% [_dash_reversals, Player.MoveState.keys()[_player.get_move_state()], _player.get_facing()]
				)
				_quit()


func _simulate_input(x: float) -> void:
	Input.action_press(&"move_right" if x > 0.0 else &"move_left")
	if x > 0.0:
		Input.action_release(&"move_left")
	else:
		Input.action_release(&"move_right")


func _print_and_quit() -> void:
	for line in _results:
		print(line)
	print("ALL PASS (%d checks)" % _results.size())
	_quit()


func _quit() -> void:
	for line in _results:
		print(line)
	get_tree().quit()
