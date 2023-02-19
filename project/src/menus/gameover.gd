extends Panel


func main() -> void:
	get_tree().change_scene_to_file("res://src/menus/main.tscn")


func play() -> void:
	get_tree().change_scene_to_file("res://src/game_controller/game_controller.tscn")
