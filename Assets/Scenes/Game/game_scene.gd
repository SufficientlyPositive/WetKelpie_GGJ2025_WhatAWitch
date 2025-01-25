class_name GameScene
extends Node2D

const GRAVITY: float = 750
const FRICTION_FLAT: float = 400
const FRICTION_COEFF: float = 0.02

const ingredient_spawn_time: float = 2.0

@export var player_character: CharacterBody2D
@export var ingredient_spawner: IngredientSpawner

var time_passed_since_ingredient_spawn: float = 0

func _ready():
	if not is_instance_valid(player_character):
		push_error("Player character not assigned!")

func _physics_process(delta: float) -> void:
	if time_passed_since_ingredient_spawn > ingredient_spawn_time:
		time_passed_since_ingredient_spawn -= ingredient_spawn_time
		ingredient_spawner.spawn_rand_ingredient()
	time_passed_since_ingredient_spawn += delta
