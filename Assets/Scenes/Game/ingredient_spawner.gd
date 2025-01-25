class_name IngredientSpawner
extends Node2D

const ingredient_scene = preload("res://Assets/Scenes/Ingredient/ingredient.tscn")

@export var spawning_area: SpawningArea

func spawn_rand_ingredient() -> void:
	spawn_ingredient(rand_ingredient())

func rand_ingredient() -> RecipeManager.Ingredients:
	match (randi_range(0, 4)):
		0: return RecipeManager.Ingredients.SNAKE_EYES
		1: return RecipeManager.Ingredients.FROGS_LEGS
		2: return RecipeManager.Ingredients.NIGHTSHADE
		3: return RecipeManager.Ingredients.TOADSTOOL
		_: return RecipeManager.Ingredients.GEMSTONE

func spawn_ingredient(type: RecipeManager.Ingredients) -> void:
	var ingredient = ingredient_scene.instantiate()
	ingredient.set_ingredient_type(type)
	ingredient.position = spawning_area.get_location_in_rect()
	self.add_child(ingredient)
