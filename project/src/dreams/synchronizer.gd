class_name Synchronizer
extends Node


@onready var module: Module = get_parent()

var dream: Landscape
var transition_camera_ours: Camera3D
var transition_camera_theirs: Camera3D
var original_camera_ours: SmoothCamera
var original_camera_theirs: SmoothCamera
var character_ours: Punk
var character_theirs: Punk


func _ready() -> void:
	module.ignore_missing_next = true
	module.activated.connect(start_sync)
	set_process(false)


# TODO: Remove manual progress, use module instead
func _process(_delta: float) -> void:
	if module.progress >= 1.0:
		transition_camera_theirs.queue_free()
		queue_free()
	update_sync(ease(module.progress, -2.0))


func start_sync() -> void:
	# TODO: We need to generate a new dream here
	if "_2" in owner.scene_file_path:
		dream = load("res://src/dreams/landscapes/example_landscape.tscn").instantiate()
	else:
		dream = load("res://src/dreams/landscapes/example_landscape_2.tscn").instantiate()
	dream.startup()
	EventBus.transition.emit(dream)
	
	# Retrieve and create needed nodes
	transition_camera_ours = Camera3D.new()
	transition_camera_theirs = Camera3D.new()
	original_camera_ours = get_viewport().get_camera_3d()
	original_camera_theirs = dream.get_camera()
	character_ours = module.character
	character_theirs = dream.get_character()
	
	# Activate cameras
	character_ours.add_child(transition_camera_ours)
	character_theirs.add_child(transition_camera_theirs)
	transition_camera_ours.make_current()
	transition_camera_theirs.make_current()
	
	# Setup sync process
	update_sync(0.0)
	set_process(true)
	character_theirs.anim.play(character_ours.anim.current_animation)
	character_theirs.anim.seek(character_ours.anim.current_animation_position, true)
	dream.get_first_module().time = module.time


func update_sync(sync_progress: float) -> void:
	dream.sync_progress = sync_progress
	var inv_ours := character_ours.global_transform.inverse()
	var inv_theirs := character_theirs.global_transform.inverse()
	var ours := inv_ours * original_camera_ours.global_transform
	var theirs := inv_theirs * original_camera_theirs.global_transform
	var interpolated := ours.interpolate_with(theirs, sync_progress)
	transition_camera_ours.transform = interpolated
	transition_camera_theirs.transform = interpolated
