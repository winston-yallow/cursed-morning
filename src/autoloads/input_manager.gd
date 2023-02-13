extends Node


const DIRECTION_SPEED := 0.001
const SMOOTH_SPEED := 5.0

var direction := Vector2.ZERO
var smooth_direction := Vector2.ZERO
var _relative := Vector2.ZERO


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_relative += event.relative


func _process(delta: float) -> void:
	direction = (direction - _relative * DIRECTION_SPEED).limit_length(1.0)
	smooth_direction = smooth_direction.lerp(direction, delta * SMOOTH_SPEED)
	_relative = Vector2.ZERO
