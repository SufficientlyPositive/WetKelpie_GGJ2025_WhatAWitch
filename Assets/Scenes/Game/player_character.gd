class_name PlayerCharacter
extends CharacterBody2D

enum Direction {LEFT, RIGHT}

const jump_force: float = 200
const max_speed: float = 50
var acceleration: float = 400
var direction: Direction = Direction.RIGHT

func _process(_delta: float):
	set_character_direction(direction)

func _physics_process(delta: float):
	var accel: Vector2 = Vector2(get_x_accel(delta), get_y_accel(delta))
	
	if accel.x < 0:
		direction = Direction.LEFT
		if velocity.x > 0:
			accel.x -= GameScene.FRICTION * delta
	elif accel.x > 0:
		direction = Direction.RIGHT
		if velocity.x < 0:
			accel.x += GameScene.FRICTION * delta
	
	self.velocity += accel
	self.velocity.x = clampf(self.velocity.x, -acceleration, acceleration)
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

func set_character_direction(local_direction: Direction):
	match local_direction:
		Direction.LEFT: 
			self.scale.y = -1
			self.rotation_degrees = 180
		Direction.RIGHT:
			self.scale.y = 1
			self.rotation = 0
