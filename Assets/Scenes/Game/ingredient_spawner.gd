class_name IngredientSpawner
extends Node2D

const ingredient_scene = preload("res://Assets/Scenes/Ingredient/ingredient.tscn")

@export var SpawningArea: Area2D

func spawn_ingredient(type: RecipeManager.Ingredients) -> void:
	var ingredient = ingredient_scene.instantiate()
	ingredient.set_ingredient_type(type)
	#ingredient.position = location
	self.add_child(ingredient)
