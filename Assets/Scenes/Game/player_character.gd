class_name PlayerCharacter
extends CharacterBody2D

const audio_dictionary = {
	"Explosion": [preload("res://Assets/Audio/CauldronExplode00.wav")],
	"Cackle": [preload("res://Assets/Audio/WitchGiggle00.wav"), preload("res://Assets/Audio/WitchGiggle01.wav"), preload("res://Assets/Audio/WitchGiggle02.wav")],
	"Plop": [preload("res://Assets/Audio/CauldronSplash00.wav")],
	"Potion Create": [preload("res://Assets/Audio/PotionSucces00.wav")],
}

var ingredient_sprites = [
	preload("res://Assets/Images/snake_eyes_big.png"),
	preload("res://Assets/Images/frogs_leg_big.png"),
	preload("res://Assets/Images/death_root_big.png"),
	preload("res://Assets/Images/toadstool_big.png"),
	preload("res://Assets/Images/gemstone_big.png"),
	preload("res://Assets/Images/Elouan Art/T_Haggis_Blow_01.png")
]

enum Direction {LEFT, RIGHT}
enum CauldronState {NOT_ENOUGH_ITEMS, FINE, NEEDS_EXPLODE}

var HP : int = 2
var invincibility_left : float = 0.0
var shield_popping_velocity : Vector2

signal game_over(value: bool)

signal change_points_by(value: int)

const jump_force: float = 350
const max_speed: float = 400

var acceleration: float = 1500
var direction: Direction = Direction.RIGHT

const cauldron_item_throttle: float = 0.2
var cauldron_time_since_item: float = 0
var cauldron_contents : Array[RecipeManager.Ingredients]
@onready var cauldron_explosion: CauldronExplosionAnimation = $Cauldron/CauldronExplosion
var cauldron_exploding: bool = false

@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var player_hurtbox: Area2D = $PlayerHurtBox
@onready var shield_sprite: AnimatedSprite2D = $ShieldNode.get_child(0)
@onready var cauldron: Area2D = $Cauldron
var accum_delta = 0.0
var broom_tilt = 0.0

@onready var stored_scale = self.scale.x

@onready var audio_player: AudioStreamPlayer2D = $PlayerAudio

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
	
	if cauldron_contents.size() > 0:
		if Input.is_action_just_pressed("Clear Cauldron"):
			cauldron_clear()

func _physics_process(delta: float):
	cauldron_time_since_item += delta
	accum_delta = fmod(accum_delta + 2.0*delta, 2.0*PI)
	floating_animation()
	tilting_animation()
	check_damage(delta)
	
	if not cauldron_exploding:
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
	else:
		self.velocity = Vector2(0, 0)

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
	if cauldron_time_since_item < cauldron_item_throttle:
		return
	else:
		cauldron_time_since_item = 0
	
	var success: bool = false
	if body is Enemy:
		if (body as Enemy).status != "running":
			explode_cauldron()
			body.queue_free()
	elif body is Ingredient:
		add_ingredient_to_cauldron((body as Ingredient).type)
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
					add_ingredient_to_cauldron(RecipeManager.Ingredients.BUBBLED_ENEMY)
					success = true
				elif target is Ingredient:
					add_ingredient_to_cauldron((target as Ingredient).type)
					success = true
				else:
					explode_cauldron()
	
	if success:
		match(get_cauldron_action()):
			CauldronState.FINE: 
				if RecipeManager.compare_ingredients_list(recipe_manager.current_recipe.ingredients, cauldron_contents) or RecipeManager.check_wildcard_list(cauldron_contents):
					craft_potion_raw(recipe_manager.current_recipe.value * RecipeManager.current_recipe_points_mod, \
						recipe_manager.current_recipe.effect)
					if HP == 1:
						restore_cat()
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
	cauldron_explosion.explode()
	cauldron_exploding = true
	player_sprite.play("cauldron_explodes")
	
	audio_player.stream = audio_dictionary["Explosion"][0]
	audio_player.pitch_scale = randf_range(0.95, 1.05)
	audio_player.play()
	
	change_points_by.emit(-50)

func craft_potion_raw(value: int, effect) -> void:
	cauldron_clear()
	
	audio_player.stream = audio_dictionary["Potion Create"][0]
	audio_player.pitch_scale = randf_range(0.90, 1.0)
	audio_player.play()
	
	change_points_by.emit(value)

func craft_potion(recipe: RecipeManager.Recipe):
	craft_potion_raw(recipe.value, recipe.effect)

func add_ingredient_to_cauldron(ingredient: RecipeManager.Ingredients):
	self.cauldron_contents.append(ingredient)
	
	audio_player.stream = audio_dictionary["Plop"][0]
	audio_player.pitch_scale = randf_range(0.95, 1.05)
	audio_player.play()
	
	update_cauldron_ui()

func cauldron_clear():
	self.cauldron_contents.clear()
	update_cauldron_ui()

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
	if invincibility_left < 0.3:
		match local_direction:
			Direction.LEFT: 
				self.scale.y = -stored_scale
				self.rotation_degrees = 180
				#if HP == 1:
				#	shield_sprite.get_parent().scale.y = stored_scale
				#	shield_sprite.get_parent().rotation = 0
			Direction.RIGHT:
				self.scale.y = stored_scale
				self.rotation = 0
				#if HP == 1:
				#	shield_sprite.get_parent().scale.y = -stored_scale
				#	shield_sprite.get_parent().rotation = 180

func restore_cat() -> void:
	HP = 2
	shield_popping_velocity = Vector2(0.0, 0.0)
	shield_sprite.get_parent().position = Vector2(0.0, 0.0)
	shield_sprite.rotation = 0.0
	shield_sprite.play("default")

func take_damage() -> void:
	HP -= 1
	if HP == 1:
		#kill the kitty
		shield_popping_velocity = (Vector2(randf()*0.2, -1.0)*600.0)
		shield_sprite.play("dead")
			# then play gravity on the kitty every frame, you can do this by checking HP every frame
			#shield_popping_velocity = shield_popping_velocity + (Vector2(0.0, 1.0) * 500.0) * delta
			#shield_node.position += shield_popping_velocity * delta
		invincibility_left = 2.5
	else:
		# Game over
		game_over.emit(true)

func check_damage(delta) -> void:
	if HP == 1:
		shield_popping_velocity = shield_popping_velocity + (Vector2(0.0, 1.0) * 1200.0) * delta
		shield_sprite.get_parent().position += shield_popping_velocity * delta
		shield_sprite.rotation += delta
	if invincibility_left < 0.3:
		invincibility_left = 0.0
		player_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
		var overlapping_bodies = player_hurtbox.get_overlapping_bodies()
		if (overlapping_bodies).size() > 0:
			take_damage()
	else:
		#sprite.modulate = 0.5*(1.0 + sin(100.0*accum_delta))*Color(1.0, 1.0, 1.0, 1.0)
		player_sprite.modulate = 0.5*(1.0 + sin(10.0*accum_delta))*Color(1.0, 1.0, 1.0, 1.0)
		invincibility_left -= delta

func _on_player_sprite_animation_finished() -> void:
	cauldron_exploding = false
	player_sprite.play("default")

func floating_animation() -> void:
	player_sprite.position = Vector2(0.0, 0.0 + 10.0*sin(accum_delta))
	shield_sprite.position = Vector2(104.0, 12.5 + 10.0*sin(accum_delta))
	cauldron.position = Vector2(19.0, 0.0 + 10.0*sin(accum_delta))

func tilting_animation() -> void:
	broom_tilt += 0.005*velocity.length()
	broom_tilt /= 5.0
	var rot = 0.3*(1.0 - exp(- broom_tilt))
	player_sprite.rotation = rot
	shield_sprite.get_parent().rotation = rot
	
