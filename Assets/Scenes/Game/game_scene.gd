class_name GameScene
extends Node2D

const GRAVITY: float = 400
const FRICTION: float = 400
@export var player_character: CharacterBody2D

func _ready():
	if not is_instance_valid(player_character):
		push_error("Player character not assigned!")
