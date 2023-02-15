extends Node2D


const SCREEN_BORDER := 64.0

var _quicktime: QuickTimeEvent
var _action: Action


func setup(quicktime: QuickTimeEvent, action: Action) -> void:
	_quicktime = quicktime
	_action = action
	%Background.texture = action.get_mask()
	%Progress.texture = action.get_mask()
	%Progress.visible = action.has_progress()
	%Shape.texture = action.get_shape()
	%Indicator.texture = action.get_indicator()
	%Mash.visible = action.needs_mashing()
	%StateAnimations.play("init")


func finish_success() -> void:
	%StateAnimations.play("finish_success")


func finish_failure() -> void:
	%StateAnimations.play("finish_fail")


func _process(_delta: float) -> void:
	%Progress.material.set_shader_parameter("progress", _action.get_progress())
	if not is_instance_valid(_quicktime):
		return
	var cam := _quicktime.get_viewport().get_camera_3d()
	var screensize := Vector2(get_tree().root.size)
	var center := screensize * 0.5
	var top_left := Vector2(SCREEN_BORDER, SCREEN_BORDER)
	var top_right := Vector2(screensize.x - SCREEN_BORDER, SCREEN_BORDER)
	var bottom_left := Vector2(SCREEN_BORDER, screensize.y - SCREEN_BORDER)
	var bottom_right := Vector2(screensize.x - SCREEN_BORDER, screensize.y - SCREEN_BORDER)
	var unprojected = cam.unproject_position(_quicktime.global_position)
	var top = Geometry2D.segment_intersects_segment(center, unprojected, top_left, top_right)
	var right = Geometry2D.segment_intersects_segment(center, unprojected, top_right, bottom_right)
	var bottom = Geometry2D.segment_intersects_segment(center, unprojected, bottom_right, bottom_left)
	var left = Geometry2D.segment_intersects_segment(center, unprojected, bottom_left, top_left)
	if top != null:
		position = top
	elif right != null:
		position = right
	elif bottom != null:
		position = bottom
	elif left != null:
		position = left
	else:
		position = unprojected
