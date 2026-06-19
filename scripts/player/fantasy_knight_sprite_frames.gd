class_name FantasyKnightSpriteFrames
extends RefCounted
## Builds `SpriteFrames` for the Fantasy Knight placeholder sheets (120x80 cells).

const FRAME_SIZE := Vector2i(120, 80)
const SHEETS_DIR := "res://assets/characters/fantasy_knight/sheets"


static func build() -> SpriteFrames:
	var frames := SpriteFrames.new()
	_add_strip(frames, &"idle", "idle.png", 10, 10.0, true, 0)
	_add_strip(frames, &"run", "run.png", 10, 12.0, true, 1)
	_add_strip(frames, &"turn_around", "turn_around.png", 3, 14.0, false, 0)
	_add_strip(frames, &"dash", "dash.png", 2, 18.0, true, 0)
	_add_strip(frames, &"jump", "jump.png", 3, 10.0, false, 1)
	_add_strip(frames, &"fall", "fall.png", 3, 8.0, true, 0)
	return frames


static func _add_strip(
	frames: SpriteFrames,
	anim_name: StringName,
	filename: String,
	frame_count: int,
	fps: float,
	loop: bool,
	start_index: int,
) -> void:
	var texture := load("%s/%s" % [SHEETS_DIR, filename]) as Texture2D
	if texture == null:
		push_error("FantasyKnightSpriteFrames: missing texture %s/%s" % [SHEETS_DIR, filename])
		return

	frames.add_animation(anim_name)
	frames.set_animation_loop(anim_name, loop)
	frames.set_animation_speed(anim_name, fps)

	for i in range(start_index, frame_count):
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2i(i * FRAME_SIZE.x, 0, FRAME_SIZE.x, FRAME_SIZE.y)
		frames.add_frame(anim_name, atlas)
