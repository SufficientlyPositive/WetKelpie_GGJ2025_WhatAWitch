class_name Ingredient
extends RigidBody2D

var type: RecipeManager.Ingredients
const MAX_Y_VELOCITY: float = 300

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
var anim_status: SpriteAnims

@export var sprite: AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	apply_central_force(calc_gravity_force(delta))

func calc_gravity_force(delta: float) -> Vector2:
	const gravity = GameScene.GRAVITY * 10
	var y_resist = ((self.linear_velocity.y + 10) / 300) * gravity
	
	return Vector2(0, (gravity - y_resist) * delta)

func set_ingredient_type(type: RecipeManager.Ingredients) -> void:
	current_anim_static = type_sprite_map[type][SpriteAnims.STATIC]
	current_anim_tumble = type_sprite_map[type][SpriteAnims.TUMBLE]
	set_anim(anim_status)

func set_anim(anim: SpriteAnims) -> void:
	match anim:
		SpriteAnims.STATIC:
			sprite.animation = current_anim_static
		SpriteAnims.TUMBLE:
			sprite.animation = current_anim_tumble
