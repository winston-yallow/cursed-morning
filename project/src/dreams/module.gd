class_name Module
extends Node3D


signal activated()


var next: Module = null
var character: Node3D = null
var camera_position: Marker3D = null
var camera_target: Marker3D = null
var time := 0.0
var progress := 0.0
var ignore_missing_next := false
var _active_overridden := false


func _ready() -> void:
	if not _active_overridden:
		set_active(false)


func switch_to_next(leftover_time: float) -> void:
	set_active(false)
	if not is_instance_valid(next):
		if not ignore_missing_next and not get_tree().current_scene == self:
			push_error("No module set as next after '%s'" % name)
		return
	next.character = character
	next.camera_position = camera_position
	next.camera_target = camera_target
	next.time = leftover_time
	next.set_active(true)


func set_active(active: bool) -> void:
	_active_overridden = true
	set_process(active)
	set_physics_process(active)
	set_process_input(active)
	if active:
		activated.emit()


func get_end_point() -> Vector3:
	return Vector3.ZERO
