class_name GameScene
extends Node2D

const GRAVITY: float = 750
const FRICTION_FLAT: float = 400
const FRICTION_COEFF: float = 0.02

const ingredient_spawn_time: float = 1.5
const enemy_spawn_time: float = 5

var points: int = 0

@export var player_character: CharacterBody2D
@export var ingredient_spawner: IngredientSpawner
@export var enemy_spawner: EnemyControl

var time_passed_since_ingredient_spawn: float = ingredient_spawn_time
var time_passed_since_enemy_spawn: float = enemy_spawn_time

func _ready():
	if not is_instance_valid(player_character):
		push_error("Player character not assigned!")

func _physics_process(delta: float) -> void:
	if time_passed_since_ingredient_spawn > ingredient_spawn_time:
		time_passed_since_ingredient_spawn -= ingredient_spawn_time
		ingredient_spawner.spawn_rand_ingredient()
		
	if time_passed_since_enemy_spawn > enemy_spawn_time:
		time_passed_since_enemy_spawn -= enemy_spawn_time
		enemy_spawner.spawn_enemy()
		
	time_passed_since_ingredient_spawn += delta
	time_passed_since_enemy_spawn += delta
