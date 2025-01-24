class_name Main
extends Node

const main_menu_scene = preload("res://Assets/Scenes/Main Menu/main_menu.tscn")
#const game_node = TODO put stuff here.

var main_menu_root_node: MainMenu

func _ready():
	main_menu_root_node = main_menu_scene.instantiate() as MainMenu
	main_menu_root_node.initialise(self.start, self.exit)
	self.add_child(main_menu_root_node)

func start():
	pass

func exit():
	get_tree().quit()
