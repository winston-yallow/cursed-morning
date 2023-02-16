extends ColorRect


const TIME_NEEDED := 1.0
var _time_hold := 0.0

@onready var _progress: ProgressBar = %ProgressBar


func _process(delta: float) -> void:
	
	if Input.is_action_pressed("ui_cancel"):
		_time_hold += delta
	else:
		_time_hold = max(_time_hold - delta, 0.0)
	_progress.value = _time_hold
	
	if _time_hold > TIME_NEEDED:
		load_menu()


func load_menu() -> void:
	set_process(false)
	print("TODO: Actually forward to menu")
