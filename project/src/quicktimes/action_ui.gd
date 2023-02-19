extends Node2D


const SCREEN_BORDER := 64.0

var _reference: Node3D
var _action: Action
var _offset := Vector2.ZERO
var _manual := false


func setup(reference: Node3D, action: Action, offset := Vector2.ZERO, manual := false) -> void:
	_reference = reference
	_action = action
	_offset = offset
	_manual = manual
	%Background.texture = action.get_mask()
	%Progress.texture = action.get_mask()
	%Progress.visible = action.has_progress()
	%Progress.rotation = action.get_direction() * TAU * 0.25
	%Progress.material = %Progress.material.duplicate()
	%Shape.texture = action.get_shape()
	%Indicator.texture = action.get_indicator()
	%Mash.visible = action.needs_mashing()
	if not _manual:
		%StateAnimations.play("init")


func finish_success() -> void:
	%StateAnimations.play("finish_success")


func finish_failure() -> void:
	%StateAnimations.play("finish_fail")


func finish_neutral() -> void:
	%StateAnimations.play("finish_neutral")


func _process(_delta: float) -> void:
	%Progress.material.set_shader_parameter("progress", _action.get_progress())
	if not is_instance_valid(_reference) or _manual:
		return
	var cam := _reference.get_viewport().get_camera_3d()
	var screensize := Vector2(get_tree().root.size)
	var center := screensize * 0.5
	var top_left := Vector2(SCREEN_BORDER, SCREEN_BORDER)
	var top_right := Vector2(screensize.x - SCREEN_BORDER, SCREEN_BORDER)
	var bottom_left := Vector2(SCREEN_BORDER, screensize.y - SCREEN_BORDER)
	var bottom_right := Vector2(screensize.x - SCREEN_BORDER, screensize.y - SCREEN_BORDER)
	var unprojected := cam.unproject_position(_reference.global_position)
	var adjusted := unprojected + _offset
	var top = Geometry2D.segment_intersects_segment(center, adjusted, top_left, top_right)
	var right = Geometry2D.segment_intersects_segment(center, adjusted, top_right, bottom_right)
	var bottom = Geometry2D.segment_intersects_segment(center, adjusted, bottom_right, bottom_left)
	var left = Geometry2D.segment_intersects_segment(center, adjusted, bottom_left, top_left)
	if top != null:
		position = top
	elif right != null:
		position = right
	elif bottom != null:
		position = bottom
	elif left != null:
		position = left
	else:
		position = adjusted
