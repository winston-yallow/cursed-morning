class_name Action
extends Resource


enum MODE { CONTINUOUS, DISCRETE }
enum TYPE { ACTION, MOTION, NONE }

const MOTION_MAX_ANGLE := deg_to_rad(15.0)

@export var mode: MODE = MODE.DISCRETE
@export var increase := 1.0
@export var decrease := 0.0
@export var indicator: Texture
@export var event: InputEvent

var _finished := false
var _progress := 0.0
var _event_pressed := false
var _event_type := TYPE.NONE


func setup() -> void:
	if event is InputEventMouseMotion:
		_event_type = TYPE.MOTION
	elif (
		event is InputEventKey
		or event is InputEventMouseButton
		or event is InputEventJoypadButton
		or event is InputEventJoypadMotion
		or event is InputEventAction
	):
		_event_type = TYPE.ACTION
	else:
		push_error("Unsupported input event %s" % event)


func _input(external_event: InputEvent) -> void:
	# Early exit if already finished
	if _finished:
		return
	
	# Handle input events
	match _event_type:
		TYPE.ACTION:
			if event.is_match(external_event):
				_handle_action(external_event)
		TYPE.MOTION:
			if external_event is InputEventMouseMotion:
				_handle_motion(external_event)


func _handle_action(external_event: InputEvent) -> void:
	if external_event.is_pressed() and not external_event.is_echo():
		_event_pressed = true
		if mode == MODE.DISCRETE:
			_advance(increase)
	elif not external_event.is_pressed():
		_event_pressed = false


func _handle_motion(external_event: InputEventMouseMotion) -> void:
	var external_velocity: Vector2 = external_event.velocity
	var desired_velocity: Vector2 = event.velocity
	if external_velocity.length_squared() >= desired_velocity.length_squared():
		var angle := abs(desired_velocity.angle_to(external_velocity))
		if angle < MOTION_MAX_ANGLE:
			if mode == MODE.DISCRETE:
				_advance(increase)
			_event_pressed = true
			return
	_event_pressed = false


func _process(delta: float) -> void:
	# Early exit if already finished
	if _finished:
		return
	
	if mode == MODE.CONTINUOUS and _event_pressed:
		_advance(increase * delta)
	
	if not _event_pressed:
		_progress = max(_progress - decrease * delta, 0.0)


func _advance(amount) -> void:
	_progress += amount
	if _progress >= 1.0:
		_progress = 1.0
		_finished = true


func is_finished():
	return _finished


func get_mask() -> Texture:
	if mode == MODE.DISCRETE:
		return preload("images/mask_round.png")
	return preload("images/mask_rect.png")


func get_shape() -> Texture:
	if mode == MODE.DISCRETE:
		return preload("images/shape_round.png")
	return preload("images/shape_rect.png")


func get_indicator() -> Texture:
	return indicator


func needs_mashing() -> bool:
	return mode == MODE.DISCRETE and increase < 1.0


func has_progress() -> bool:
	return mode == MODE.CONTINUOUS or increase < 1.0


func get_progress() -> float:
	return _progress
