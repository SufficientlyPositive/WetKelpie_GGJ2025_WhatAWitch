class_name Enemy
extends Node2D

#var statuses : Array = ["falling", "stuck", "running", "popping"] # Unnecessary, here for readability
var status : String

@onready var collision_area : Area2D = $Area2D
@onready var enemy_sprite : AnimatedSprite2D = $AnimatedSprite2D

const inflating_factor = 1.03
const exploding_time = 0.2
const running_acceleration : Vector2 = Vector2(10.0, 0.0)
const max_velocity : Vector2 = Vector2(100.0, 0.0)

var accum_delta : float = 0.0
var velocity : Vector2
#var falling_velocity : Vector2 = Vector2(0.0, 70.0)
var angular_velocity : float = 0.0
var jittering : float = 0.0

func _ready():
	set_status("falling")

func _physics_process(delta: float) -> void:
	jittering_animation(delta)
	match status:
		"falling":
			if collision_area.has_overlapping_areas():
				set_status("running")
		"stuck":
			#TODO: Lock physics. This guy is no longer in control of his destiny!
			pass
		"running":
			enemy_sprite.play("running")
			velocity = min(max_velocity, velocity + running_acceleration * delta)
			position += velocity * delta
		"popping":
			accum_delta += delta
			#enemy_sprite.scale = enemy_sprite.scale * inflating_factor
			if accum_delta > exploding_time:
				enemy_sprite.play("boom")
				if enemy_sprite.frame == 16:
					queue_free()
			else:
				enemy_sprite.play("blow")
				

func set_status(state):
	status = state
	match state:
		"falling":
			jittering = 0.0
			enemy_sprite.rotation = 0.0
			angular_velocity = 0.2
		"stuck":
			jittering = 0.0
			angular_velocity = 1.0
		"running":
			jittering = 0.0
			enemy_sprite.rotation = 0.0
			angular_velocity = 0.0
		"popping":
			jittering = 2.0
			enemy_sprite.rotation = 0.0
			angular_velocity = 0.0

func jittering_animation(delta):
	enemy_sprite.position = position + jittering*Vector2(randf()-0.5, randf()-0.5)

func spinning_animation(delta):
	enemy_sprite.rotation += angular_velocity * delta
