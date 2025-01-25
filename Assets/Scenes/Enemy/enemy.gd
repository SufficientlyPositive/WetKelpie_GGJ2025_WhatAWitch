class_name Enemy
extends RigidBody2D

#var statuses : Array = ["falling", "stuck", "running", "popping"] # Unnecessary, here for readability
var status : String

#@onready var collision_area : Area2D = $Area2D
@onready var enemy_sprite : AnimatedSprite2D = $AnimatedSprite2D

const MAX_Y_VELOCITY: float = 300
const MAX_Y_BUBBLE_VELOCITY: float = 100
const inflating_factor = 1.03
const exploding_time = 0.2
const running_acceleration : Vector2 = Vector2(10.0, 0.0)
const max_velocity : Vector2 = Vector2(100.0, 0.0)

var accum_delta : float = 0.0
var velocity : Vector2
#var falling_velocity : Vector2 = Vector2(0.0, 70.0)
var sprite_angular_velocity : float = 0.0
var jittering : float = 0.0

var enemy_trapped : bool = false

func _ready():
	set_status("falling")

func _physics_process(delta: float) -> void:
	if enemy_trapped == false:
		apply_central_force(calc_gravity_force(delta))
	match status:
		"falling":
			if get_colliding_bodies().size() > 0:
			#if has_overlapping_areas():
				set_status("running")
		"stuck":
			#TODO: Lock physics. This guy is no longer in control of his destiny!
			jittering_animation(delta)
		"running":
			enemy_sprite.play("running")
			apply_impulse(running_acceleration * delta)
			#position += velocity * delta
		"popping":
			jittering_animation(delta)
			accum_delta += delta
			#enemy_sprite.scale = enemy_sprite.scale * inflating_factor
			if accum_delta > exploding_time:
				enemy_sprite.play("boom")
				if enemy_sprite.frame == 16:
					queue_free()
			else:
				enemy_sprite.play("blow")

func calc_gravity_force(delta: float) -> Vector2:
	const gravity = GameScene.GRAVITY * 10
	var y_resist: float = ((self.linear_velocity.y + 10) / MAX_Y_VELOCITY) * gravity
	return Vector2(0, (gravity - y_resist) * delta)

func set_status(state):
	status = state
	match state:
		"falling":
			enemy_trapped = false
			jittering = 0.0
			enemy_sprite.rotation = 0.0
			sprite_angular_velocity = 0.2
		"stuck":
			enemy_trapped = true
			jittering = 0.5
			sprite_angular_velocity = 1.0
		"running":
			enemy_trapped = false
			jittering = 0.0
			enemy_sprite.rotation = 0.0
			sprite_angular_velocity = 0.0
		"popping":
			enemy_trapped = true
			jittering = 2.0
			enemy_sprite.rotation = 0.0
			sprite_angular_velocity = 0.0

func jittering_animation(delta):
	enemy_sprite.position = position + jittering*Vector2(randf()-0.5, randf()-0.5)

func spinning_animation(delta):
	enemy_sprite.rotation += sprite_angular_velocity * delta
