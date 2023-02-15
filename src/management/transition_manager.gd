extends Control


const DreamViewportScene := preload("dream_viewport.tscn")
const DreamViewport := preload("dream_viewport.gd")
const Snooze := preload("res://src/quicktimes/snooze.gd")

const EIGHT_HOURS := 60.0 * 60.0 * 8.0

var viewports: Array[DreamViewport] = []
var active_on_a := true

@onready var canvas_layer: CanvasLayer = %CanvasLayer
@onready var snooze: Snooze = %Snooze
@onready var clock: Label = %Clock
@onready var seconds: Label = %Seconds

var _time := 0.0


func _ready() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#get_tree().root.mode = Window.MODE_MAXIMIZED
	# Load first scene
	var dream := preload("res://src/dreams/landscapes/example_landscape.tscn").instantiate()
	dream.sync_progress = 1.0
	dream.startup()
	_create_vp(dream)
	
	EventBus.transition.connect(_transition)
	EventBus.quicktime_failed.connect(snooze.start)


func _process(delta: float) -> void:
	_time += delta
	@warning_ignore("narrowing_conversion")
	var t := Time.get_time_dict_from_unix_time(EIGHT_HOURS + _time)
	clock.text = "%02d:%02d" % [t.hour, t.minute]
	seconds.text = ":%02d" % [t.second]


func _transition(dream: Landscape) -> void:
	_create_vp(dream)


func _create_vp(dream: Landscape) -> void:
	if viewports.size() > 1:
		var old: DreamViewport = viewports.pop_front()
		old.queue_free()
	var new: DreamViewport = DreamViewportScene.instantiate()
	add_child(new)
	new.set_dream(dream)
	viewports.append(new)
