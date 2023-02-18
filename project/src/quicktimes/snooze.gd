extends Control


@export var increase_step := 0.25
@export var decrease_speed := 0.35
@export var time := 1.75

@onready var anim: AnimationPlayer = %AnimationPlayer
@onready var shader: ShaderMaterial = %Label.material
@onready var time_label: ProgressBar = %TimeLeft
@onready var alarm: AudioStreamPlayer = %Alarm

var _progress := 0.0
var _time_left := 0.0


func _ready() -> void:
	anim.play("hide")
	anim.animation_set_next("show", "pulse")
	set_process(false)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("snooze") and is_processing():
		_progress += increase_step


func _process(delta: float) -> void:
	_time_left -= delta
	_progress = max(0.0, _progress - decrease_speed * delta)
	if _progress >= 1.0:
		finish_success()
	if _time_left <= 0.0:
		finish_fail()
	time_label.value = _time_left / time
	alarm.volume_db = lerp(-80.0 , 0.0, min((1.0 - _time_left / time) * 5.0, 1.0))
	shader.set_shader_parameter("progress", _progress)


func start() -> void:
	_progress = 0.0
	_time_left = time
	shader.set_shader_parameter("progress", 0.0)
	time_label.value = 0.0
	alarm.volume_db = -80.0
	alarm.play()
	anim.play("show")
	set_process(true)


func finish_success() -> void:
	_progress = 2.0
	alarm.stop()
	anim.play("success")
	set_process(false)


func finish_fail() -> void:
	_progress = 2.0
	alarm.stop()
	anim.play("fail")
	set_process(false)
