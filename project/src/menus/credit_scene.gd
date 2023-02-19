extends Panel


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		back()


func back() -> void:
	get_tree().change_scene_to_file("res://src/menus/main.tscn")
