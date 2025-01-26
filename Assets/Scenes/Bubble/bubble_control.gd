class_name BubbleControl
extends Node2D
const momentum_factors : Vector2 = Vector2(10.0, 1.0)

# Reference to the node of the Player Witch character
var player_reference: PlayerCharacter
var bubble_scene

const bubble_throttle: float = 2.0
var time_until_next_bubble: float = 0

func _ready():
	# Access Parent scene first in order to have access to the unique name
	player_reference = get_parent().get_node("%PlayerCharacter")
	bubble_scene = preload("res://Assets/Scenes/Bubble/bubble.tscn")

func _physics_process(delta: float) -> void:
	time_until_next_bubble -= delta
	if Input.is_action_pressed("Bubble") and (time_until_next_bubble < 0) and not player_reference.cauldron_exploding:
		spawn_bubble(player_reference.position, Vector2(player_reference.get_x_accel(delta), player_reference.get_y_accel(delta) - 150))
		time_until_next_bubble = bubble_throttle

func spawn_bubble(pos: Vector2, acceleration: Vector2):
	acceleration = acceleration * momentum_factors
	#print("Player jumped! Releasing Bubble with momentum: ", acceleration.x, " ", acceleration.y)
	var bubble = bubble_scene.instantiate()
	add_child(bubble)
	bubble.velocity = acceleration
	bubble.position = pos
