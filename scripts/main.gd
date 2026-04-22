extends Node2D
## Boot scene: fixed-step readout and input smoke test. Gameplay sim belongs in `_physics_process`.

@onready var _debug: Label = $UI/DebugLabel


func _ready() -> void:
	_debug.text = "FTWSA boot — connect a controller or use WASD / Space / E / Shift"


func _physics_process(_delta: float) -> void:
	var move := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	var fps := Engine.get_frames_per_second()
	var hz := int(ProjectSettings.get_setting("physics/common/physics_ticks_per_second"))
	_debug.text = (
		"FPS (cap 60): %d\nPhysics ticks/sec: %d\nMove: (%.2f, %.2f)\n"
		% [fps, hz, move.x, move.y]
		+ "Jump: %s  Parry: %s  Dodge: %s\n"
		% [
			Input.is_action_pressed(&"jump"),
			Input.is_action_pressed(&"parry"),
			Input.is_action_pressed(&"dodge"),
		]
		+ "Tip: map Parry to LB; Jump A; Dodge B (Xbox layout)."
	)
