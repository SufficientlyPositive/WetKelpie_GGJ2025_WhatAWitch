class_name GameMain
extends Node

@onready var root_node: Main = get_tree().root.get_child(0) as Main

func _ready():
	if not is_instance_valid(root_node):
		push_error("Root node did not successfully instantiate in GameMain. Unable to quit to main menu.")

func quit_to_main_menu():
	root_node.load_main_menu()
	root_node.remove_game_main()
