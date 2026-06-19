extends Node2D
## Auto-play visual demo for dash / run / turnaround / dash dance.

@onready var _player: Player = $Player
@onready var _caption: Label = $UI/Caption
@onready var _hint: Label = $UI/Hint
@onready var _state_label: Label = $UI/StateLabel

var _frame := 0

## [duration_frames, input_x, title, hint]
const _SEQUENCE: Array = [
	[20, 0.0, "Melee ground movement", "Greybox demo — watch sprite tint + state label"],
	[18, 1.0, "1/4 — Dash from idle", "Burst right: cyan tint, fixed dash speed"],
	[36, 1.0, "2/4 — Dash → Run", "Hold right: transitions to green run"],
	[30, -1.0, "3/4 — Run → Turnaround", "Reverse while running: yellow pivot (locked)"],
	[36, -1.0, "3/4 — Turnaround → Run", "Pivot completes, run left (green)"],
	[12, 1.0, "4/4 — Dash dance setup", "Fresh dash right…"],
	[54, 0.0, "4/4 — Dash dance", "Tap opposite mid-dash — instant reversals"],
]

var _seq_index := 0
var _seq_frame := 0


func _ready() -> void:
	_player.camera_limit_left = -200
	_player.camera_limit_right = 1600
	_apply_sequence_step()


func _physics_process(_delta: float) -> void:
	if not _player.is_on_floor() and _frame < 30:
		_frame += 1
		_player.set_synthetic_input_x(0.0)
		_update_state_label()
		return

	var step: Array = _SEQUENCE[_seq_index]
	var duration: int = step[0]
	var input_x: float = step[1]

	if _seq_index == 6:
		input_x = 1.0 if int(_seq_frame / 6.0) % 2 == 0 else -1.0

	_player.set_synthetic_input_x(input_x)
	_update_state_label()

	_seq_frame += 1
	_frame += 1
	if _seq_frame >= duration:
		_seq_index = (_seq_index + 1) % _SEQUENCE.size()
		_seq_frame = 0
		if _seq_index == 0:
			_reset_player()
		_apply_sequence_step()


func _apply_sequence_step() -> void:
	var step: Array = _SEQUENCE[_seq_index]
	_caption.text = step[2]
	_hint.text = step[3]


func _update_state_label() -> void:
	var state_name: String = Player.MoveState.keys()[_player.get_move_state()]
	var facing := "right" if _player.get_facing() > 0 else "left"
	_state_label.text = "state: %s   facing: %s   vel: %.0f" % [state_name, facing, _player.velocity.x]


func _reset_player() -> void:
	_player.set_synthetic_input_x(0.0)
	_player.global_position = Vector2(640, 478)
	_player.velocity = Vector2.ZERO
	_player.set_move_state(Player.MoveState.GROUND_IDLE)
