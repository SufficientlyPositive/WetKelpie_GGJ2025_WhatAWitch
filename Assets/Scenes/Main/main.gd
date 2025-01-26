class_name Main
extends Node

const main_menu_scene = preload("res://Assets/Scenes/Main Menu/main_menu.tscn")
const game_scene = preload("res://Assets/Scenes/Game/game_scene.tscn")

var main_menu_root_node: MainMenu
var game_scene_root_node: GameMain

func _ready():
	load_main_menu()

func load_main_menu():
	if not is_instance_valid(main_menu_root_node):
		main_menu_root_node = main_menu_scene.instantiate() as MainMenu
		main_menu_root_node.initialise(start, exit)
		self.add_child(main_menu_root_node)
	else:
		push_warning("Trying to load main menu when main menu is already valid.")

func remove_main_menu():
	if is_instance_valid(main_menu_root_node):
		main_menu_root_node.queue_free()
	else:
		push_warning("Trying to free main menu when main menu is already freed.")

func load_game_main():
	if not is_instance_valid(game_scene_root_node):
		get_tree().paused = false
		game_scene_root_node = game_scene.instantiate() as GameMain
		self.add_child(game_scene_root_node)
	else:
		push_warning("Trying to load game scene when game scene is already valid.")

func remove_game_main():
	if is_instance_valid(game_scene_root_node):
		game_scene_root_node.queue_free()
	else:
		push_warning("Trying to free game scene when game scene is already freed.")

func start():
	load_game_main()
	remove_main_menu()

func exit():
	get_tree().quit()
