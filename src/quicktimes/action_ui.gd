extends Control


var _quicktime: QuickTimeEvent
var _action: Action


func setup(quicktime: QuickTimeEvent, action: Action) -> void:
	_quicktime = quicktime
	_action = action
	if _action.get_direction() == _action.DIRECTION.HORIZONTAL:
		%HorizontalText.text = _action.get_text()
		%VerticalText.text = ""
	else:
		%HorizontalText.text = ""
		%VerticalText.text = _action.get_text()
	%AnimationPlayer.play("init")


func finish_success() -> void:
	%AnimationPlayer.play("success")


func finish_failure() -> void:
	%AnimationPlayer.play("fail")
	set_process(false)


func _process(_delta: float) -> void:
	if not is_instance_valid(_quicktime):
		return
	var cam := _quicktime.get_viewport().get_camera_3d()
	position = cam.unproject_position(_quicktime.global_position)
