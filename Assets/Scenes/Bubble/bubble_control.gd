class_name BubbleControl
extends Node2D
const momentum_factors : Vector2 = Vector2(10.0, 1.0)

# Reference to the node of the Player Witch character
var player_reference
var bubble_scene

func _ready():
	# Access Parent scene first in order to have access to the unique name
	player_reference = get_parent().get_node("%PlayerCharacter")
	bubble_scene = preload("res://Assets/Scenes/Bubble/bubble.tscn")

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("Jump") and player_reference.is_on_floor():
		var acceleration : Vector2 = Vector2(player_reference.get_x_accel(delta), player_reference.get_y_accel(delta))
		acceleration = acceleration * momentum_factors
		#print("Player jumped! Releasing Bubble with momentum: ", acceleration.x, " ", acceleration.y)
		var bubble = bubble_scene.instantiate()
		add_child(bubble)
		bubble.velocity = acceleration
		bubble.position = player_reference.position
