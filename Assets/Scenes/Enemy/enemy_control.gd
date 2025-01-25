class_name EnemyControl
extends Node2D

var player_reference
var enemy_scene

func _ready():
	# Access Parent scene first in order to have access to the unique name
	player_reference = get_parent().get_node("%PlayerCharacter")
	enemy_scene = preload("res://Assets/Scenes/Enemy/enemy.tscn")

func _physics_process(delta: float) -> void:
	# Enemy spawning here
	pass
