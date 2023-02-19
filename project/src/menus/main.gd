extends Panel


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	resized.connect(adjust_clock_size)
	adjust_clock_size()


func adjust_clock_size() -> void:
	var new_scale := 0.5 + 0.5 * inverse_lerp(500, 1000, size.y)
	%Clock.scale = Vector2(new_scale, new_scale)


func tutorial() -> void:
	_change_scene(preload("tutorial.tscn"))


func start() -> void:
	_change_scene(preload("res://src/game_controller/game_controller.tscn"))


func credits() -> void:
	_change_scene(preload("credit_scene.tscn"))


func _change_scene(scn: PackedScene) -> void:
	var on_animation_finished := func on_animation_finished(_anim) -> void:
		get_tree().change_scene_to_packed(scn)
	%AnimationPlayer.animation_finished.connect(on_animation_finished)
	%AnimationPlayer.play("fade_out")


func exit() -> void:
	get_tree().quit()
