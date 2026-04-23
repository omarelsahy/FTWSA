extends Node2D
## Boot scene: HUD (after physics) + player movement / combat debug.

@onready var _debug: Label = $UI/DebugLabel
@onready var _player: Player = $World/Player


func _ready() -> void:
	_debug.text = "FTWSA — move with stick/D-pad or A/D; Space jump; E / RB parry; Shift/Z dodge"


func _process(_delta: float) -> void:
	var move := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	var fps := Engine.get_frames_per_second()
	var hz := int(ProjectSettings.get_setting("physics/common/physics_ticks_per_second"))
	var player_txt := ""
	if is_instance_valid(_player):
		player_txt = _player.get_debug_overlay_text() + "\n\n"
	_debug.text = (
		player_txt
		+ "Global\n"
		+ "FPS (cap 60): %d\nPhysics ticks/sec: %d\nInput move: (%.2f, %.2f)\n" % [fps, hz, move.x, move.y]
		+ "Jump: %s  Parry: %s  Dodge: %s\n"
		% [
			Input.is_action_pressed(&"jump"),
			Input.is_action_pressed(&"parry"),
			Input.is_action_pressed(&"dodge"),
		]
	)
