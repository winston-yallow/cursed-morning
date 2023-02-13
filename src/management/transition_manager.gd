extends Control


const DreamViewportScene := preload("dream_viewport.tscn")
const DreamViewport := preload("dream_viewport.gd")

var viewports: Array[DreamViewport] = []
var active_on_a := true


func _ready() -> void:
	# Load first scene
	var dream := preload("res://src/dreams/landscapes/example_landscape.tscn").instantiate()
	dream.sync_progress = 1.0
	dream.startup()
	_create_vp(dream)
	
	EventBus.transition.connect(_transition)


func _transition(dream: Landscape) -> void:
	_create_vp(dream)


func _create_vp(dream: Landscape) -> void:
	if viewports.size() > 1:
		var old: DreamViewport = viewports.pop_front()
		old.queue_free()
	var new: DreamViewport = DreamViewportScene.instantiate()
	add_child(new)
	new.set_dream(dream)
	viewports.append(new)
