class_name QuickTimeEvent
extends Area3D


signal succeded()
signal failed()

const ActionUIScene := preload("action_ui.tscn")
const ActionUI := preload("action_ui.gd")

@export var time := 1.0
@export var forward_fails := true
@export var sequence: Array[Action]

var _finished := false
var _current: Action
var _current_ui: ActionUI
var _internal_sequence: Array[Action] = []


func _ready() -> void:
	# Prevent changing the original resources
	for action in sequence:
		var new_action := action.duplicate()
		new_action.setup()
		_internal_sequence.append(new_action)
	
	# Make this Area3D undetectable by other nodes
	collision_layer = 0
	
	# Enable process only once we detected the player
	set_process(false)
	area_entered.connect(_activate)


func _activate(_other):
	set_process(true)
	_current = _internal_sequence.pop_front()
	_current_ui = _create_action_ui(_current)


func _input(event: InputEvent) -> void:
	if is_instance_valid(_current):
		_current._input(event)


func _process(delta: float) -> void:
	time -= delta
	
	# Process sequence items
	_current._process(delta)
	if _current.is_finished():
		if _internal_sequence.is_empty():
			_current = null
			_finished = true
		else:
			_current_ui.finish_success()
			_current = _internal_sequence.pop_front()
			_current_ui = _create_action_ui(_current)
	
	# Check if we reached fail or success conditions
	if _finished:
		succeded.emit()
		_current_ui.finish_success()
		set_process(false)
	elif time < 0.0:
		failed.emit()
		_current_ui.finish_failure()
		set_process(false)
		if forward_fails:
			EventBus.quicktime_failed.emit()


func _create_action_ui(action: Action) -> ActionUI:
	var new_ui: ActionUI = ActionUIScene.instantiate()
	new_ui.setup(self, action)
	get_tree().current_scene.canvas_layer.add_child(new_ui)
	return new_ui
