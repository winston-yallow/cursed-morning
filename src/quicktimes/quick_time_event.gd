class_name QuickTimeEvent
extends Area3D


const ActionUIScene := preload("action_ui.tscn")
const ActionUI := preload("action_ui.gd")

@export var time := 1.0
@export var sequence: Array[Action]

var _current_ui: ActionUI
var _internal_sequence: Array[Action] = []


func _ready() -> void:
	# Prevent changing the original resources
	for action in sequence:
		_internal_sequence.append(action.duplicate())
	
	# Make this Area3D undetectable by other nodes
	collision_layer = 0
	
	# Enable process only once we detected the player
	set_process(false)
	area_entered.connect(_activate)


func _activate(_other):
	set_process(true)
	_current_ui = _create_action_ui(_internal_sequence.front())


func _process(delta: float) -> void:
	time -= delta
	
	# Process sequence items
	var current: Action = _internal_sequence.front()
	current._process(delta)
	if current.finished:
		_internal_sequence.pop_front()
		if not _internal_sequence.is_empty():
			_current_ui.finish_success()
			_current_ui = _create_action_ui(_internal_sequence.front())
	
	# Check if we reached fail or success conditions
	if _internal_sequence.is_empty():
		_current_ui.finish_success()
		set_process(false)
	elif time < 0.0:
		_current_ui.finish_failure()
		set_process(false)
		EventBus.quicktime_failed.emit()


func _create_action_ui(action: Action) -> ActionUI:
	var new_ui: ActionUI = ActionUIScene.instantiate()
	new_ui.setup(self, action)
	get_tree().current_scene.canvas_layer.add_child(new_ui)
	return new_ui
