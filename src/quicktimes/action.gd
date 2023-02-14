class_name Action
extends Resource


enum DIRECTION {
	HORIZONTAL,
	VERTICAL,
}
enum KEYS {
	W = KEY_W,
	A = KEY_A,
	S = KEY_S,
	D = KEY_D,
	SPACE = KEY_SPACE,
}
const STRING_MAP := {
	KEY_W: "W",
	KEY_A: "A",
	KEY_S: "S",
	KEY_D: "D",
	KEY_SPACE: "]",
}
const DIRECTION_MAP := {
	KEY_W: DIRECTION.HORIZONTAL,
	KEY_A: DIRECTION.HORIZONTAL,
	KEY_S: DIRECTION.HORIZONTAL,
	KEY_D: DIRECTION.HORIZONTAL,
	KEY_SPACE: DIRECTION.VERTICAL,
}

var finished := false


func _process(_delta: float) -> void:
	pass


func get_direction() -> DIRECTION:
	return DIRECTION.HORIZONTAL


func get_text() -> String:
	return ""
