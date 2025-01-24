class_name MainMenu
extends Control

var on_start_pressed: Callable
var on_quit_pressed: Callable

func initialise(_on_start_pressed: Callable, _on_quit_pressed: Callable):
	self.on_start_pressed = _on_start_pressed
	self.on_quit_pressed = _on_quit_pressed

func _on_start_button_pressed():
	on_start_pressed.call()

func _on_quit_button_pressed():
	on_quit_pressed.call()
