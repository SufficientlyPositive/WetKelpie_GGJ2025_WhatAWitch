class_name GameCanvas
extends Node

@export var in_game_ui: Control # placeholder
@export var pause_menu: Control

func _ready():
	if not is_instance_valid(in_game_ui):
		pass
		#push_error("In game UI not instantiated in GameUI. Recipes and the like will not be available.")
	if not is_instance_valid(pause_menu):
		push_error("Pause Menu not instantiated in GameUI. Will not be able to exit to menu and pressing 'esc' will cause a crash.")

func toggle_pause_menu():
	pause_menu.visible = not pause_menu.visible
