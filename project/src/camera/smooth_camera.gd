class_name SmoothCamera
extends Camera3D


const MAX_ANGLE := deg_to_rad(30.0)

@export var target_from: Marker3D
@export var target_to: Marker3D
@export var speed := 8.0

var current_from := position
var current_to := position


func _process(delta: float) -> void:
	#current_from = current_from.lerp(target_from.position, delta * speed)
	current_to = current_to.lerp(target_to.position, delta * speed)
	var adjusted_dir := target_from.position - target_to.position
	#var axis_horizontal := Vector3.UP
	#var axis_vertical := Vector3.UP.cross(adjusted_dir).normalized()
	#adjusted_dir = adjusted_dir.rotated(axis_horizontal, InputManager.direction.x * MAX_ANGLE)
	#adjusted_dir = adjusted_dir.rotated(axis_vertical, InputManager.direction.y * MAX_ANGLE)
	var adjusted_from := target_to.position + adjusted_dir
	current_from = current_from.lerp(adjusted_from, delta * speed)
	look_at_from_position(current_from, current_to)
