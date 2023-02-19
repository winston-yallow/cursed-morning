extends Control


const DreamViewportScene := preload("dream_viewport.tscn")
const DreamViewport := preload("dream_viewport.gd")
const Snooze := preload("res://src/quicktimes/snooze.gd")
const MusicPlayer := preload("res://src/music/music_player.gd")
const ActionUI := preload("res://src/quicktimes/action_ui.gd")

const EIGHT_HOURS := 60.0 * 60.0 * 8.0
const SNOOZE_USED_COLOR := Color.DIM_GRAY

@onready var canvas_layer: CanvasLayer = %CanvasLayer
@onready var snooze: Snooze = %Snooze
@onready var clock: Label = %Clock
@onready var seconds: Label = %Seconds
@onready var snooze_label_1: Label = %SnoozeLabel1
@onready var snooze_label_2: Label = %SnoozeLabel2
@onready var snooze_label_3: Label = %SnoozeLabel3
@onready var music_player: MusicPlayer = %MusicPlayer

var is_snoozing := false

var _time := 0.0
var _lives := 3
var _viewports: Array[DreamViewport] = []


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Load first scene
	var dream := preload("res://src/dreams/special_landscapes/first.tscn").instantiate()
	dream.sync_progress = 1.0
	dream.startup()
	_create_vp(dream)
	
	snooze.failed.connect(gameover)
	
	EventBus.transition.connect(_transition)
	EventBus.quicktime_failed.connect(_on_quicktime_failed)


func _process(delta: float) -> void:
	_time += delta
	@warning_ignore("narrowing_conversion")
	var t := Time.get_time_dict_from_unix_time(EIGHT_HOURS + _time)
	clock.text = "%02d:%02d" % [t.hour, t.minute]
	seconds.text = ":%02d" % [t.second]


func _on_quicktime_failed() -> void:
	if is_snoozing:
		return
	
	is_snoozing = true
	var snooze_label: Label
	match _lives:
		3: snooze_label = snooze_label_3
		2: snooze_label = snooze_label_2
		1: snooze_label = snooze_label_1
	if is_instance_valid(snooze_label):
		var st := create_tween()
		st.tween_method(
			func set_snooze_color(color: Color) -> void:
				snooze_label.add_theme_color_override("font_color", color),
			Color.WHITE,
			SNOOZE_USED_COLOR,
			snooze.time
		)
		_lives -= 1
		snooze.start()
		
		# Make music quite for the time of snoozing
		var mt := create_tween()
		mt.tween_method(music_player.set_volume_lerp, 1.0, 0.0, 0.3)
		mt.tween_interval(snooze.time - 0.6)
		mt.tween_method(music_player.set_volume_lerp, 0.0, 1.0, 0.3)
		
		# Disable snooze safety
		var timer := get_tree().create_timer(snooze.time + 0.75)
		timer.timeout.connect(func(): is_snoozing = false)
	else:
		gameover()


func gameover() -> void:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		var mt := create_tween()
		mt.tween_method(music_player.set_volume_lerp, 1.0, 0.0, 0.3)
		mt.tween_interval(snooze.time - 0.6)
		mt.tween_callback(snooze.stop_sound_only)
		snooze.play_sound_only()
		%AnimationPlayer.animation_finished.connect(_cleanup)
		%AnimationPlayer.play("gameover")
		var duration: float = %AnimationPlayer.get_animation("gameover").length
		var at := create_tween()
		at.set_parallel(true)
		for child in canvas_layer.get_children():
			if child is ActionUI:
				at.tween_property(child, "modulate", Color.TRANSPARENT, duration)
		# prevent error from empty tween
		at.tween_callback(func(): pass)


func _cleanup(_anim) -> void:
	for vp in _viewports:
		vp.queue_free()
	for child in canvas_layer.get_children():
		if child is ActionUI:
			child.queue_free()


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
