class_name Landscape
extends Node3D


var sync_progress := 0.0

@export var camera: SmoothCamera
@export var character: Punk
@export var first_module: Module
@export var camera_position: Marker3D
@export var camera_target: Marker3D


func startup() -> void:
	first_module.character = character
	first_module.camera_position = camera_position
	first_module.camera_target = camera_target
	first_module.set_active(true)
