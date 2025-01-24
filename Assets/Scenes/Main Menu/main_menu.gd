class_name MainMenu
extends Control

var on_start_pressed: Callable
var on_quit_pressed: Callable

func initialise(on_start_pressed: Callable, on_quit_pressed: Callable):
	self.on_start_pressed = on_start_pressed
	self.on_quit_pressed = on_quit_pressed

func _on_start_button_pressed():
	on_start_pressed.call()

func _on_quit_button_pressed():
	on_quit_pressed.call()
