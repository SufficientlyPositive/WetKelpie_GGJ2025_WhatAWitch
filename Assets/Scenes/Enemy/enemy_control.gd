class_name EnemyControl
extends Node2D

const enemy_scene = preload("res://Assets/Scenes/Enemy/enemy.tscn")

@export var spawning_area: SpawningArea

const x_force_min = -10
const x_force_max = 10
const y_force_min = 20
const y_force_max = 40

func spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	enemy.position = spawning_area.get_location_in_rect()
	
	var x = randf_range(x_force_min, x_force_max)
	var y = randf_range(y_force_min, y_force_max)
	enemy.apply_central_impulse(Vector2(x, y))
	self.add_child(enemy)
