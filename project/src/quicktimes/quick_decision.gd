class_name QuickDecision
extends Area3D


signal decision_a()
signal decision_b()
signal decision(payload: Node3D)

const ActionUIScene := preload("action_ui.tscn")
const ActionUI := preload("action_ui.gd")

enum FINISH { NOT_YET, A, B, FAIL }
enum OPTION { A, B }

@export var time := 1.0
@export var forward_fails := true
@export var default: OPTION = OPTION.A
@export var action_a: Action
@export var action_b: Action
@export var payload_a: Node3D
@export var payload_b: Node3D

var _ui_a: ActionUI
var _ui_b: ActionUI


func _ready() -> void:
	# Prevent changing the original resources
	action_a = action_a.duplicate()
	action_b = action_b.duplicate()
	action_a.setup()
	action_b.setup()
	
	# Make this Area3D undetectable by other nodes
	collision_layer = 0
	
	# Enable process only once we detected the player
	set_process(false)
	area_entered.connect(_activate)


func _activate(_other) -> void:
	if get_tree().current_scene.is_snoozing:
		_decide(default)
		return
	set_process(true)
	_ui_a = _create_action_ui(action_a, Vector2.LEFT * 32.0)
	_ui_b = _create_action_ui(action_b, Vector2.RIGHT * 32.0)


func _input(event: InputEvent) -> void:
	if is_processing():
		if is_instance_valid(action_a):
			action_a._input(event)
		if is_instance_valid(action_b):
			action_b._input(event)


func _process(delta: float) -> void:
	# Process time and actions
	time -= delta
	action_a._process(delta)
	action_b._process(delta)
	
	# Check if we reached a decision or the end
	var result := FINISH.NOT_YET
	if action_a.is_finished():
		result = FINISH.A
	elif action_b.is_finished():
		result = FINISH.B
	elif time < 0.0:
		var progress_a := action_a.get_progress()
		var progress_b := action_b.get_progress()
		if progress_a > 0.5 and progress_a > progress_b:
			result = FINISH.A
		elif progress_b > 0.5 and progress_b > progress_a:
			result = FINISH.B
		else:
			result = FINISH.FAIL
	
	# Perform finishing
	match result:
		FINISH.A:
			_ui_a.finish_success()
			_ui_b.finish_neutral()
			_decide(OPTION.A)
		FINISH.B:
			_ui_a.finish_neutral()
			_ui_b.finish_success()
			_decide(OPTION.B)
		FINISH.FAIL:
			_ui_a.finish_failure()
			_ui_b.finish_failure()
			_decide(default)
			if forward_fails:
				EventBus.quicktime_failed.emit()


func _decide(option: OPTION) -> void:
	match option:
		OPTION.A:
			decision_a.emit()
			decision.emit(payload_a)
		OPTION.B:
			decision_b.emit()
			decision.emit(payload_b)
	set_process(false)


func _create_action_ui(action: Action, offset: Vector2) -> ActionUI:
	var new_ui: ActionUI = ActionUIScene.instantiate()
	new_ui.setup(self, action, offset)
	get_tree().current_scene.canvas_layer.add_child(new_ui)
	return new_ui
