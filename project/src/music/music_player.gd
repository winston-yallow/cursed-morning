extends AudioStreamPlayer


const VOLUME_LOW := -15.0
const VOLUME_HIGH := -5.0


func _ready() -> void:
	set_volume_lerp(1.0)


func set_volume_lerp(loudness: float) -> void:
	volume_db = lerp(VOLUME_LOW, VOLUME_HIGH, loudness)
