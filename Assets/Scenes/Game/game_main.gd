class_name GameMain
extends Node

@onready var root_node: Main = get_tree().root.get_child(0) as Main
@export var game_scene: GameScene
@export var game_canvas: GameCanvas

var points: int = 0

func _ready():
	if not is_instance_valid(root_node):
		push_error("Root node did not successfully instantiate in GameMain. Unable to quit to main menu.")
	if not is_instance_valid(game_scene):
		push_error("GameScene node did not successfully instantiate in GameMain. No game to play!")
	if not is_instance_valid(game_canvas):
		push_error("GameUI node did not successfully instantiate in GameMain. Cannot access UI.")

func toggle_pause():
	get_tree().paused = not get_tree().paused
	game_canvas.toggle_pause_menu()

func game_over(b: bool):
	get_tree().paused = b
	game_canvas.game_over()

func quit_to_main_menu():
	root_node.load_main_menu()
	root_node.remove_game_main() # queue free's self
	get_tree().paused = false

# all input handling related non-gameplay actions should be handled here!
func _process(_delta):
	if Input.is_action_just_pressed("Toggle Pause Menu"):
		toggle_pause()

func change_points(add_val: int) -> void:
	points += add_val
	points = max(0, points)
	change_points_ui(points)

func change_points_ui(new_val: int) -> void:
	$GameCanvas/CauldronUI/Contents/Score.text = str(points)
