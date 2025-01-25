class_name PlayerCharacter
extends CharacterBody2D

enum Direction {LEFT, RIGHT}

const jump_force: float = 280
const max_speed: float = 400
var acceleration: float = 1500
var direction: Direction = Direction.RIGHT

var cauldron_contents : Array[RecipeManager.Ingredients]

@onready var stored_scale = self.scale.x

func _process(_delta: float):
	set_character_direction(direction)
	
	if cauldron_contents.size() < 3:
		if Input.is_action_just_pressed("ui_home"):
			cauldron_contents.append(RecipeManager.Ingredients.values().pick_random())
			

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
	if body is Ingredient:
		var ingredient: Ingredient = body as Ingredient
		
	elif body is Enemy:
		pass

func validate_cauldron_contents():
	pass

func set_character_direction(local_direction: Direction):
	match local_direction:
		Direction.LEFT: 
			self.scale.y = -stored_scale
			self.rotation_degrees = 180
		Direction.RIGHT:
			self.scale.y = stored_scale
			self.rotation = 0
