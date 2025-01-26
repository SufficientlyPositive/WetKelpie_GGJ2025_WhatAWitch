class_name Enemy
extends RigidBody2D

#var statuses : Array = ["falling", "stuck", "running", "popping"] # Unnecessary, here for readability
var status : String

@onready var default_parent = get_parent()
@onready var collision_area : CollisionShape2D = $CollisionShape2D
@onready var enemy_sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_player : AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var audio_player_2 : AudioStreamPlayer2D = $AudioStreamPlayer2D2

var audio_dict = {
	"Grunting" : [], 
	"Exploding" : [],
	"Running" : []
}
var exploding = false;

const MAX_Y_VELOCITY: float = 300
const MAX_Y_BUBBLE_VELOCITY: float = 100
const inflating_factor = 1.005
const exploding_time = 0.8
const running_acceleration : Vector2 = Vector2(100.0, 0.0)
const max_velocity : Vector2 = Vector2(100.0, 0.0)
var direction : Vector2 = Vector2(0.0, 0.0)

var accum_delta : float = 0.0
var velocity : Vector2
#var falling_velocity : Vector2 = Vector2(0.0, 70.0)
var sprite_angular_velocity : float = 0.0
var jittering : float = 0.0

var bubble_trapped : bool = false

func _ready():
	set_status("falling")
	load_audio()

func _physics_process(delta: float) -> void:
	spinning_animation(delta)
	if bubble_trapped == false:
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
			enemy_sprite.play("run")
			if direction == Vector2(0.0, 0.0):
				direction = Vector2(global_position.x - 950.0, 0.0).normalized()
				if direction.x < 0.0:
					enemy_sprite.flip_h = true
			# If you want Mr. Haggis to roll like a buffoon
			# apply_impulse(running_acceleration * direction * delta)
			# If you want actual results
			linear_velocity = linear_velocity - running_acceleration * direction * delta * 3.0
			rotation = 0.0
		"popping":
			jittering_animation(delta)
			accum_delta += delta
			enemy_sprite.scale = enemy_sprite.scale * inflating_factor
			if accum_delta > exploding_time:
				if exploding == false:
					audio_player.stream = audio_dict["Exploding"][floor(randf()*2.0)]
					audio_player.play()
					exploding = true
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
			bubble_trapped = false
			jittering = 0.0
			enemy_sprite.rotation = 0.0
			sprite_angular_velocity = 3.0
		"stuck":
			bubble_trapped = true
			jittering = 0.5
			sprite_angular_velocity = 6.0
		"running":
			audio_player.stream = audio_dict["Grunting"][floor(randf()*3.0)]
			audio_player.play()
			audio_player_2.stream = audio_dict["Running"][0]
			audio_player_2.play()
			bubble_trapped = false
			jittering = 0.0
			enemy_sprite.rotation = 0.0
			sprite_angular_velocity = 0.0
		"popping":
			bubble_trapped = false
			jittering = 3.0
			enemy_sprite.rotation = 0.0
			sprite_angular_velocity = 0.0

func trap_in_bubble(bubble: Bubble) -> void:
	default_parent = get_parent()
	set_status("stuck")
	self.reparent(bubble, true)
	bubble_trapped = true
	self.linear_damp = 3.0
	collision_area.disabled = true
	
func jittering_animation(delta):
	enemy_sprite.position = position + jittering*Vector2(randf()-0.5, randf()-0.5)

func spinning_animation(delta):
	enemy_sprite.rotation += sprite_angular_velocity * delta

func load_audio():
	audio_dict["Exploding"].append(load("res://Assets/Audio/HaggisBoom00.mp3"))
	audio_dict["Exploding"].append(load("res://Assets/Audio/HaggisBoom01.mp3"))
	audio_dict["Grunting"].append(load("res://Assets/Audio/HumanGrunt00.wav"))
	audio_dict["Grunting"].append(load("res://Assets/Audio/HumanGrunt01.wav"))
	audio_dict["Grunting"].append(load("res://Assets/Audio/HumanGrunt02.wav"))
	audio_dict["Running"].append(load("res://Assets/Audio/Footsteps.mp3"))
