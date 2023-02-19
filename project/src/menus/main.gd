extends Panel


func _ready() -> void:
	resized.connect(adjust_clock_size)
	adjust_clock_size()


func adjust_clock_size() -> void:
	var new_scale := 0.5 + 0.5 * inverse_lerp(500, 1000, size.y)
	%Clock.scale = Vector2(new_scale, new_scale)


func tutorial() -> void:
	get_tree().change_scene_to_packed(preload("tutorial.tscn"))


func start() -> void:
	get_tree().change_scene_to_packed(
		preload("res://src/game_controller/game_controller.tscn")
	)


func credits() -> void:
	get_tree().change_scene_to_packed(preload("credit_scene.tscn"))


func exit() -> void:
	get_tree().quit()
