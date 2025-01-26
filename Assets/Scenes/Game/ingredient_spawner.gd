class_name IngredientSpawner
extends Node2D

const ingredient_scene = preload("res://Assets/Scenes/Ingredient/ingredient.tscn")

const x_force_min = -10
const x_force_max = 10
const y_force_min = 20
const y_force_max = 40

@export var spawning_area: SpawningArea

func spawn_rand_ingredient() -> void:
	spawn_ingredient(rand_ingredient())

func rand_ingredient() -> RecipeManager.Ingredients:
	match (randi_range(0, 4)):
		0: return RecipeManager.Ingredients.SNAKE_EYES
		1: return RecipeManager.Ingredients.FROGS_LEG
		2: return RecipeManager.Ingredients.DEATH_ROOT
		3: return RecipeManager.Ingredients.TOADSTOOL
		_: return RecipeManager.Ingredients.GEMSTONE

func spawn_ingredient(type: RecipeManager.Ingredients) -> void:
	var ingredient = ingredient_scene.instantiate()
	ingredient.set_ingredient_type(type)
	ingredient.position = spawning_area.get_location_in_rect()
	
	var x = randf_range(x_force_min, x_force_max)
	var y = randf_range(y_force_min, y_force_max)
	ingredient.apply_central_impulse(Vector2(x, y))
	self.add_child(ingredient)
