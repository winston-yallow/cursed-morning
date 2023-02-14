extends Node


const CharacterScene := preload("res://src/character/punk.tscn")
const DevCameraScene := preload("dev_camera.tscn")
const TransitionManager := preload("res://src/management/transition_manager.gd")


func _ready() -> void:
	var scene := get_tree().current_scene
	if scene is Module:
		_init_module(scene)
	elif scene is Landscape:
		scene.startup()


func get_ui_parent() -> Node:
	if get_tree().current_scene is TransitionManager:
		return get_tree().current_scene.canvas_layer
	else:
		return get_tree().current_scene


func _init_module(module: Module) -> void:
	var character := CharacterScene.instantiate()
	var camera_position := DevCameraScene.instantiate()
	var camera_target := Marker3D.new()
	add_child(character)
	add_child(camera_position)
	add_child(camera_target)
	module.character = character
	module.camera_position = camera_position
	module.camera_target = camera_target
	module.set_active(true)
