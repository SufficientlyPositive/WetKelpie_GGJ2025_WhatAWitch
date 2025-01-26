class_name RecipeManager
extends Control


var ingredient_sprites = [
	preload("res://Assets/Images/snake_eyes_big.png"),
	preload("res://Assets/Images/frogs_leg_big.png"),
	preload("res://Assets/Images/death_root_big.png"),
	preload("res://Assets/Images/toadstool_big.png"),
	preload("res://Assets/Images/gemstone_big.png"),
]
var recipe_card = preload("res://Assets/Scenes/Game/recipe_card.tscn")

enum Ingredients {
		SNAKE_EYES,
		FROGS_LEG,
		DEATH_ROOT,
		TOADSTOOL,
		GEMSTONE,
		BUBBLED_ENEMY,
}

static func compare_ingredients(a: Ingredients, b: Ingredients) -> bool:
	return (a == Ingredients.BUBBLED_ENEMY) or (b == Ingredients.BUBBLED_ENEMY) or (a == b)

static func compare_ingredients_list(a: Array[Ingredients], b: Array[Ingredients]) -> bool:
	if a.size() != b.size():
		return false
	
	for i in range(a.size()):
		if not RecipeManager.compare_ingredients(a[i], b[i]):
			return false
	
	return true

class Recipe:
	var ingredients : Array[Ingredients]
	var value : int
	var effect = null
	
	func _init(ing : Array[Ingredients], val : int) -> void:
		ingredients = ing
		value = val

const current_recipe_points_mod: int = 5

var valid_recipes : Array[Recipe] = [
	
	Recipe.new([
			Ingredients.FROGS_LEG,
			Ingredients.DEATH_ROOT,
			Ingredients.SNAKE_EYES],
			200),
	Recipe.new([
			Ingredients.SNAKE_EYES,
			Ingredients.FROGS_LEG,
			Ingredients.GEMSTONE],
			200),
	Recipe.new([
			Ingredients.FROGS_LEG,
			Ingredients.GEMSTONE,
			Ingredients.TOADSTOOL],
			200),
	Recipe.new([
			Ingredients.GEMSTONE,
			Ingredients.FROGS_LEG,
			Ingredients.DEATH_ROOT],
			200),
	Recipe.new([
			Ingredients.TOADSTOOL,
			Ingredients.SNAKE_EYES,
			Ingredients.GEMSTONE],
			200),
	Recipe.new([
			Ingredients.DEATH_ROOT,
			Ingredients.TOADSTOOL,
			Ingredients.SNAKE_EYES],
			200),
	Recipe.new([
			Ingredients.TOADSTOOL,
			Ingredients.FROGS_LEG,
			Ingredients.GEMSTONE],
			200),
]

var current_recipe : Recipe


func pick_new_current_recipe():
	if $MarginContainer/CurrentRecipe.get_child_count() > 1:
		$MarginContainer/CurrentRecipe.get_child(1).queue_free()
	current_recipe = valid_recipes.pick_random()
	var rc = recipe_card.instantiate()
	for i in range(3):
		rc.get_node("I" + str(i)).texture = ingredient_sprites[int(current_recipe.ingredients[i])]
		rc.get_node("Val").text = str(current_recipe.value * current_recipe_points_mod)
	$MarginContainer/CurrentRecipe.add_child(rc)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for r in valid_recipes:
		var rc = recipe_card.instantiate()
		for i in range(3):
			rc.get_node("I" + str(i)).texture = ingredient_sprites[int(r.ingredients[i])]
		rc.get_node("Val").text = str(r.value)
		$MarginContainer/RecipeCards.add_child(rc)
	
	pick_new_current_recipe()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
