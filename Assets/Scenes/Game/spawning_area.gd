class_name SpawningArea
extends Area2D

@export var rectangle: CollisionShape2D
@onready var spawn_rect: Rect2 = Rect2(rectangle.shape.get_rect())

func _ready() -> void:
	spawn_rect.position += rectangle.global_position

func get_location_in_rect() -> Vector2:
	var x = randf_range(spawn_rect.position.x, spawn_rect.end.x)
	var y = randf_range(spawn_rect.position.y, spawn_rect.end.y)
	return Vector2(x, y)
