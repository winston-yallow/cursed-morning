class_name SmoothCamera
extends Camera3D


@export var target_from: Marker3D
@export var target_to: Marker3D
@export var speed := 8.0

var current_from := position
var current_to := position


func _process(delta: float) -> void:
	current_from = current_from.lerp(target_from.position, delta * speed)
	current_to = current_to.lerp(target_to.position, delta * speed)
	look_at_from_position(current_from, current_to)
