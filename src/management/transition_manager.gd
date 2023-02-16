extends Control


const DreamViewportScene := preload("dream_viewport.tscn")
const DreamViewport := preload("dream_viewport.gd")
const Snooze := preload("res://src/quicktimes/snooze.gd")

const EIGHT_HOURS := 60.0 * 60.0 * 8.0
const SNOOZE_USED_COLOR := Color.DIM_GRAY

@onready var canvas_layer: CanvasLayer = %CanvasLayer
@onready var snooze: Snooze = %Snooze
@onready var clock: Label = %Clock
@onready var seconds: Label = %Seconds
@onready var snooze_label_1: Label = %SnoozeLabel1
@onready var snooze_label_2: Label = %SnoozeLabel2
@onready var snooze_label_3: Label = %SnoozeLabel3

var _time := 0.0
var _lives := 3
var _viewports: Array[DreamViewport] = []


func _ready() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#get_tree().root.mode = Window.MODE_MAXIMIZED
	# Load first scene
	var dream := preload("res://src/dreams/landscapes/example_landscape.tscn").instantiate()
	dream.sync_progress = 1.0
	dream.startup()
	_create_vp(dream)
	
	EventBus.transition.connect(_transition)
	EventBus.quicktime_failed.connect(_on_quicktime_failed)


func _process(delta: float) -> void:
	_time += delta
	@warning_ignore("narrowing_conversion")
	var t := Time.get_time_dict_from_unix_time(EIGHT_HOURS + _time)
	clock.text = "%02d:%02d" % [t.hour, t.minute]
	seconds.text = ":%02d" % [t.second]


func _on_quicktime_failed() -> void:
	var snooze_label: Label
	match _lives:
		3: snooze_label = snooze_label_3
		2: snooze_label = snooze_label_2
		1: snooze_label = snooze_label_1
	if is_instance_valid(snooze_label):
		var t := create_tween()
		t.tween_method(
			func set_snooze_color(color: Color) -> void:
				snooze_label.add_theme_color_override("font_color", color),
			Color.WHITE,
			SNOOZE_USED_COLOR,
			snooze.time
		)
	_lives -= 1
	snooze.start()


func _transition(dream: Landscape) -> void:
	_create_vp(dream)


func _create_vp(dream: Landscape) -> void:
	if _viewports.size() > 1:
		var old: DreamViewport = _viewports.pop_front()
		old.queue_free()
	var new: DreamViewport = DreamViewportScene.instantiate()
	add_child(new)
	new.set_dream(dream)
	_viewports.append(new)
