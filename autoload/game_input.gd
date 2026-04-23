extends Node
## Registers default actions once if they are missing (controller-first, KBM fallbacks).

const STICK_DEADZONE := 0.22


func _ready() -> void:
	if not InputMap.has_action(&"move_left"):
		_register_all()


func _register_all() -> void:
	_add_action(&"move_left", STICK_DEADZONE)
	_add_action(&"move_right", STICK_DEADZONE)
	_add_action(&"move_up", STICK_DEADZONE)
	_add_action(&"move_down", STICK_DEADZONE)
	_add_action(&"jump", 0.2)
	_add_action(&"parry", 0.2)
	_add_action(&"dodge", 0.2)

	# Keyboard — movement
	_add_key(&"move_left", KEY_A)
	_add_key(&"move_left", KEY_LEFT)
	_add_key(&"move_right", KEY_D)
	_add_key(&"move_right", KEY_RIGHT)
	_add_key(&"move_up", KEY_W)
	_add_key(&"move_up", KEY_UP)
	_add_key(&"move_down", KEY_S)
	_add_key(&"move_down", KEY_DOWN)

	# Gamepad — D-pad + left stick (SDL indices via @GlobalScope constants)
	_add_joy_button(&"move_left", JOY_BUTTON_DPAD_LEFT)
	_add_joy_button(&"move_right", JOY_BUTTON_DPAD_RIGHT)
	_add_joy_button(&"move_up", JOY_BUTTON_DPAD_UP)
	_add_joy_button(&"move_down", JOY_BUTTON_DPAD_DOWN)
	_add_joy_axis(&"move_left", JOY_AXIS_LEFT_X, -1.0)
	_add_joy_axis(&"move_right", JOY_AXIS_LEFT_X, 1.0)
	_add_joy_axis(&"move_up", JOY_AXIS_LEFT_Y, -1.0)
	_add_joy_axis(&"move_down", JOY_AXIS_LEFT_Y, 1.0)

	# Jump / parry / dodge — Xbox-like layout as default reference
	_add_key(&"jump", KEY_SPACE)
	_add_joy_button(&"jump", JOY_BUTTON_A)

	_add_key(&"parry", KEY_E)
	_add_joy_button(&"parry", JOY_BUTTON_LEFT_SHOULDER)

	_add_key(&"dodge", KEY_SHIFT)
	_add_key(&"dodge", KEY_Z)
	_add_joy_button(&"dodge", JOY_BUTTON_B)


func _add_action(action: StringName, deadzone: float) -> void:
	InputMap.add_action(action, deadzone)


func _add_key(action: StringName, keycode: Key) -> void:
	var ev := InputEventKey.new()
	ev.physical_keycode = keycode
	InputMap.action_add_event(action, ev)


func _add_joy_button(action: StringName, button_index: int) -> void:
	var ev := InputEventJoypadButton.new()
	ev.button_index = button_index
	InputMap.action_add_event(action, ev)


func _add_joy_axis(action: StringName, axis_index: int, axis_value: float) -> void:
	var ev := InputEventJoypadMotion.new()
	ev.axis = axis_index
	ev.axis_value = axis_value
	InputMap.action_add_event(action, ev)
