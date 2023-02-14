class_name ActionKeyPress
extends Action


@export var key: KEYS = KEYS.W


func _process(_delta):
	if Input.is_key_pressed(key):
		finished = true


func get_direction() -> DIRECTION:
	return DIRECTION_MAP[key]


func get_text() -> String:
	return STRING_MAP[key]
