class_name MainMenu
extends Control

var _on_start_pressed: Callable

func _on_start_button_pressed():
	_on_start_pressed.call()
