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


func back() -> void:
	get_tree().change_scene_to_packed(preload("main.tscn"))
