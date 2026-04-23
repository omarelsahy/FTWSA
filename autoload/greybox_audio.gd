extends Node
## Plays optional greybox music if `res://assets/audio/explore_loop.ogg` exists (non-positional).

const DEFAULT_EXPLORE := "res://assets/audio/explore_loop.ogg"

var _player: AudioStreamPlayer


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.name = "GreyboxMusicPlayer"
	_player.volume_db = -10.0
	add_child(_player)
	if ResourceLoader.exists(DEFAULT_EXPLORE):
		var stream: Resource = load(DEFAULT_EXPLORE)
		if stream is AudioStream:
			_player.stream = stream
			_player.play()
