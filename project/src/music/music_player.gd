extends AudioStreamPlayer


const VOLUME_LOW := -30.0
const VOLUME_HIGH := -15.0

const options: Array[AudioStream] = [
	preload("res://src/music/devotion.mp3"),
	preload("res://src/music/please_stay.mp3"),
	preload("res://src/music/trapped.mp3")
]

var _last: AudioStream


func _ready() -> void:
	set_volume_lerp(1.0)
	finished.connect(_play_random)
	_play_random()


func _play_random() -> void:
	var possible := options.duplicate()
	if _last in possible:
		possible.erase(_last)
	stream = possible.pick_random()
	_last = stream
	play()


func set_volume_lerp(loudness: float) -> void:
	volume_db = lerp(VOLUME_LOW, VOLUME_HIGH, loudness)
