extends CanvasLayer


const GameController := preload("res://src/game_controller/game_controller.gd")


func _ready() -> void:
	visible = false


func _input(event: InputEvent) -> void:
	if get_tree().current_scene is GameController:
		if event.is_action_pressed("ui_cancel"):
			set_pause(not visible)


func set_pause(enabled: bool) -> void:
	visible = enabled
	get_tree().paused = enabled
	if enabled:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func continue_game() -> void:
	set_pause(false)


func main_menu() -> void:
	get_tree().change_scene_to_file("res://src/menus/main.tscn")
