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
	RecipeManager.Ingredients.SNAKE_EYES : {
		SpriteAnims.STATIC : "snake_eyes_static",
		SpriteAnims.TUMBLE : "snake_eyes_tumble",
	},
	RecipeManager.Ingredients.FROGS_LEGS : {
		SpriteAnims.STATIC : "frog_legs_static",
		SpriteAnims.TUMBLE : "frog_legs_tumble",
	},
	RecipeManager.Ingredients.GEMSTONE : {
		SpriteAnims.STATIC : "gemstone_static",
		SpriteAnims.TUMBLE : "gemstone_tumble",
	},
	RecipeManager.Ingredients.NIGHTSHADE : {
		SpriteAnims.STATIC : "nightshade_static",
		SpriteAnims.TUMBLE : "nightshade_tumble",
	},
	RecipeManager.Ingredients.TOADSTOOL : {
		SpriteAnims.STATIC : "toadstool_static",
		SpriteAnims.TUMBLE : "toadstool_tumble",
	},
}

var current_anim_static: String
var current_anim_tumble: String
var anim_status: SpriteAnims = SpriteAnims.STATIC

var bubble_trapped: bool = false

@export var sprite: AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	apply_central_force(calc_gravity_force(delta))

func calc_gravity_force(delta: float) -> Vector2:
	const gravity = GameScene.GRAVITY * 10
	
	var y_resist: float = 0
	if not bubble_trapped:
		y_resist = ((self.linear_velocity.y + 10) / MAX_Y_VELOCITY) * gravity
	else:
		y_resist = ((self.linear_velocity.y + 10) / MAX_Y_BUBBLE_VELOCITY) * gravity

	return Vector2(0, (gravity - y_resist) * delta)

func trap_in_bubble(bubble: Bubble) -> void:
	self.reparent(bubble)
	anim_status = SpriteAnims.STATIC
	bubble_trapped = true

func set_ingredient_type(type: RecipeManager.Ingredients) -> void:
	current_anim_static = type_sprite_map[type][SpriteAnims.STATIC]
	current_anim_tumble = type_sprite_map[type][SpriteAnims.TUMBLE]
	set_anim(anim_status)

func set_anim(anim: SpriteAnims) -> void:
	match anim:
		SpriteAnims.STATIC:
			sprite.play(current_anim_static)
		SpriteAnims.TUMBLE:
			sprite.play(current_anim_tumble)
