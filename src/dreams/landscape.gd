class_name Landscape
extends Node3D


var sync_progress := 0.0


func get_camera() -> SmoothCamera:
	return %SmoothCamera


func get_character() -> Node3D:
	return %Character


func get_first_module() -> Module:
	return %FirstModule


func startup() -> void:
	var module: Module = %FirstModule
	module.character = %Character
	module.camera_position = %CameraPosition
	module.camera_target = %CameraTarget
	module.set_active(true)
