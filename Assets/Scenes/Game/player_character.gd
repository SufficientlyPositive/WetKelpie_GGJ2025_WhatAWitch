class_name PlayerCharacter
extends CharacterBody2D

var ingredient_sprites = [
	preload("res://Assets/Images/snake_eyes_big.png"),
	preload("res://Assets/Images/frogs_leg_big.png"),
	preload("res://Assets/Images/death_root_big.png"),
	preload("res://Assets/Images/toadstool_big.png"),
	preload("res://Assets/Images/gemstone_big.png"),
]

enum Direction {LEFT, RIGHT}
enum CauldronState {NOT_ENOUGH_ITEMS, FINE, NEEDS_EXPLODE}

signal change_points_by(value: int)

const jump_force: float = 280
const max_speed: float = 400
var acceleration: float = 1500
var direction: Direction = Direction.RIGHT

var cauldron_contents : Array[RecipeManager.Ingredients]

@onready var stored_scale = self.scale.x

func update_cauldron_ui():
	for i in range(3):
		var box = %CauldronUI/Contents.get_node("I" + str(i))
		box.texture = null
		
	for i in range(cauldron_contents.size()):
		var box = %CauldronUI/Contents.get_node("I" + str(i))
		box.texture = ingredient_sprites[int(cauldron_contents[i])]

@onready var recipe_manager: RecipeManager = %Recipes

func _process(_delta: float):
	set_character_direction(direction)
	
	if cauldron_contents.size() < 3:
		if Input.is_action_just_pressed("ui_home"):
			cauldron_contents.append(RecipeManager.Ingredients.values().pick_random())
			update_cauldron_ui()

func _physics_process(delta: float):
	var accel: Vector2 = Vector2(get_x_accel(delta), get_y_accel(delta))
	
	if accel.x < 0:
		direction = Direction.LEFT
		if velocity.x > 0:
			accel.x -= GameScene.FRICTION_FLAT * delta
	elif accel.x > 0:
		direction = Direction.RIGHT
		if velocity.x < 0:
			accel.x += GameScene.FRICTION_FLAT * delta
	
	self.velocity += accel
	self.velocity.x = clampf(self.velocity.x, -max_speed, max_speed)
	self.velocity.x *= (1 - GameScene.FRICTION_COEFF)
	move_and_slide()

# movement may be floaty, 
func get_x_accel(delta: float) -> float:
	var x_component: int = 0
	if Input.is_action_pressed("Move Left"):
		x_component -= 1
	if Input.is_action_pressed("Move Right"):
		x_component += 1
	return delta * acceleration * x_component

func get_y_accel(delta: float) -> float:
	var y_component: float = 0
	
	if Input.is_action_pressed("Jump") and self.is_on_floor():
		y_component += -jump_force
	
	y_component += GameScene.GRAVITY * delta
	return y_component

func on_cauldron_body_entered(body: Node2D):
	var success: bool = false
	if body is Enemy:
		if (body as Enemy).status != "running":
			explode_cauldron()
			body.queue_free()
	elif body is Ingredient:
		self.cauldron_contents.append((body as Ingredient).type)
		success = true
	else:
		var par: Node = body.get_parent()
		if par is Bubble:
			var bubble: Node = par as Bubble
			if bubble.status == "falling":
				var target: Node2D = bubble.target
				bubble.set_status("popping")
				body = target
				if target is Enemy:
					self.cauldron_contents.append(RecipeManager.Ingredients.BUBBLED_ENEMY)
					success = true
				elif target is Ingredient:
					self.cauldron_contents.append((target as Ingredient).type)
					success = true
				else:
					print("wtf else are you putting in this dang cauldron?!")
					explode_cauldron()
	
	if success:
		update_cauldron_ui()
		
		match(get_cauldron_action()):
			CauldronState.FINE: 
				if RecipeManager.compare_ingredients_list(recipe_manager.current_recipe.ingredients, cauldron_contents):
					craft_potion_raw(recipe_manager.current_recipe.value * RecipeManager.current_recipe_points_mod, \
						recipe_manager.current_recipe.effect)
					recipe_manager.pick_new_current_recipe()
				else:
					var recipe_index: int = get_recipe()
					if recipe_index == -1:
						explode_cauldron()
					else:
						craft_potion(recipe_manager.valid_recipes[recipe_index])
			CauldronState.NEEDS_EXPLODE:
				explode_cauldron()
		
		body.queue_free()

func explode_cauldron():
	cauldron_clear()
	change_points_by.emit(-100)

func craft_potion_raw(value: int, effect) -> void:
	cauldron_clear()
	print("Potion crafted with value: " + str(value))
	change_points_by.emit(value)

func craft_potion(recipe: RecipeManager.Recipe):
	craft_potion_raw(recipe.value, recipe.effect)

func cauldron_clear():
	self.cauldron_contents.clear()

func get_cauldron_action() -> CauldronState:
	var n_ingredients = cauldron_contents.size()
	if n_ingredients < 3:
		return CauldronState.NOT_ENOUGH_ITEMS
	elif n_ingredients == 3:
		return CauldronState.FINE
	else:
		return CauldronState.NEEDS_EXPLODE

func get_recipe() -> int:
	if cauldron_contents.size() > 3:
		return -1
	if cauldron_contents.size() == 3:
		for i in range(recipe_manager.valid_recipes.size()):
			if RecipeManager.compare_ingredients_list(recipe_manager.valid_recipes[i].ingredients, cauldron_contents):
				return i
	return -1

func set_character_direction(local_direction: Direction):
	match local_direction:
		Direction.LEFT: 
			self.scale.y = -stored_scale
			self.rotation_degrees = 180
		Direction.RIGHT:
			self.scale.y = stored_scale
			self.rotation = 0
