extends Control


@export var action_press: Action
@export var action_mash: Action
@export var action_hold: Action
@export var action_move: Action


func _ready() -> void:
	%PressUI.setup(null, action_press, Vector2.ZERO, true)
	%MashUI.setup(null, action_mash, Vector2.ZERO, true)
	%HoldUI.setup(null, action_hold, Vector2.ZERO, true)
	%MoveUI.setup(null, action_move, Vector2.ZERO, true)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		back()


func back() -> void:
	get_tree().change_scene_to_file("res://src/menus/main.tscn")
