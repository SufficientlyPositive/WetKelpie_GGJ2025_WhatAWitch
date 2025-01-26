class_name Ingredient
extends RigidBody2D

var type: RecipeManager.Ingredients
const MAX_Y_VELOCITY: float = 300
const MAX_Y_BUBBLE_VELOCITY: float = 100

enum SpriteAnims {
	STATIC,
	TUMBLE,
}

const type_sprite_map = {
	RecipeManager.Ingredients.SNAKE_EYES : {SpriteAnims.STATIC : "snake_eyes_static"},
	RecipeManager.Ingredients.FROGS_LEG : {SpriteAnims.STATIC : "frog_legs_static"},
	RecipeManager.Ingredients.GEMSTONE : {SpriteAnims.STATIC : "gemstone_static"},
	RecipeManager.Ingredients.DEATH_ROOT : {SpriteAnims.STATIC : "deathroot_static"},
	RecipeManager.Ingredients.TOADSTOOL : {SpriteAnims.STATIC : "toadstool_static"}
}

var current_anim_static: String
var current_anim_tumble: String
var anim_status: SpriteAnims = SpriteAnims.STATIC


#var statuses : Array = ["falling", "stuck", "popping"] # Unnecessary, here for readability
var status : String = "falling"
var accum_delta : float = 0.0
var popping_velocity : Vector2 = Vector2(0.0, 0.0)
const dancing_speed : float = 3.0

var bubble_trapped: bool = false

@onready var default_parent = get_parent()

@export var sprite: AnimatedSprite2D
@export var shadow: AnimatedSprite2D
@export var collision_area: CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func on_contact(body: Node):
	if body is StaticBody2D:
		set_status("popping")

func _physics_process(delta: float) -> void:
	if not bubble_trapped:
		apply_central_force(calc_gravity_force(delta))
	match status:
		"falling":
			accum_delta = fmod(accum_delta + dancing_speed*delta, 2*PI)
			sprite.rotation = 0.7*sin(accum_delta)
			shadow.rotation = 0.7*sin(accum_delta)
		"stuck":
			sprite.rotation += 1.0*delta
			shadow.rotation += 1.0*delta
		"popping":
			accum_delta += 0.2*delta
			sprite.modulate = 0.5*(1.0 + sin(100.0*accum_delta))*Color(1.0, 1.0, 1.0, 1.0)
			shadow.modulate = 0.5*(1.0 + sin(100.0*accum_delta))*Color(0.0, 0.0, 0.0, 1.0)
			popping_velocity = popping_velocity + (Vector2(0.0, 1.0) * 500.0) * delta
			position += popping_velocity * delta
			if accum_delta > 1.0:
				queue_free()

func calc_gravity_force(delta: float) -> Vector2:
	const gravity = GameScene.GRAVITY * 10
	var y_resist: float = ((self.linear_velocity.y + 10) / MAX_Y_VELOCITY) * gravity
	return Vector2(0, (gravity - y_resist) * delta)

func trap_in_bubble(bubble: Bubble) -> void:
	set_status("stuck")
	self.reparent(bubble)
	anim_status = SpriteAnims.STATIC
	bubble_trapped = true
	self.linear_damp = 3.0
	collision_area.disabled = true

func set_ingredient_type(atype: RecipeManager.Ingredients) -> void:
	current_anim_static = type_sprite_map[atype][SpriteAnims.STATIC]
	set_anim(anim_status)
	type = atype

func set_anim(anim: SpriteAnims) -> void:
	match anim:
		SpriteAnims.STATIC:
			sprite.play(current_anim_static)
			shadow.play(current_anim_static)

func set_status(state : String) -> void:
	status = state
	match state:
		"falling":
			pass
		"stuck":
			pass
		"popping":
			set_deferred("freeze", true)
			call_deferred("set_contact_monitor", false)
			popping_velocity = (Vector2(0.0, -1.0)*300.0)
			bubble_trapped = false
			accum_delta = 0.0
