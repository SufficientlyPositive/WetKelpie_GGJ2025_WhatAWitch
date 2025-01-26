class_name GameScene
extends Node2D

const GRAVITY: float = 750
const FRICTION_FLAT: float = 400
const FRICTION_COEFF: float = 0.02

const avg_ingredient_spawn_time: float = 2.5
const ingredient_spawn_time_range: float = 1.5
const avg_enemy_spawn_time: float = 8
const enemy_spawn_time_range: float = 4

var points: int = 0

@export var player_character: CharacterBody2D
@export var ingredient_spawner: IngredientSpawner
@export var enemy_spawner: EnemyControl

var time_until_next_ingredient_spawn: float = randf_range(-1, 1)
var time_until_next_enemy_spawn: float = randf_range(-2, 2)

func _ready():
	if not is_instance_valid(player_character):
		push_error("Player character not assigned!")

func _physics_process(delta: float) -> void:
	if time_until_next_ingredient_spawn < 0:
		time_until_next_ingredient_spawn += randf_range(avg_ingredient_spawn_time - ingredient_spawn_time_range, \
			avg_ingredient_spawn_time + ingredient_spawn_time_range)
		ingredient_spawner.spawn_rand_ingredient()
		
	if time_until_next_enemy_spawn < 0:
		time_until_next_enemy_spawn += randf_range(avg_enemy_spawn_time - ingredient_spawn_time_range, \
			avg_enemy_spawn_time + ingredient_spawn_time_range)
		enemy_spawner.spawn_enemy()
		
	time_until_next_ingredient_spawn -= delta
	time_until_next_enemy_spawn -= delta
