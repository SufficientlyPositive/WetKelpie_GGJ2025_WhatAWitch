class_name EnemyControl
extends Node2D

const enemy_scene = preload("res://Assets/Scenes/Enemy/enemy.tscn")

@export var spawning_area: SpawningArea

func spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	enemy.position = spawning_area.get_location_in_rect()
	self.add_child(enemy)
