class_name Bubble
extends Node2D

var target : Node2D = null
#var statuses : Array = ["empty", "catching", "falling"] # Unnecessary, here for readability
var status : String

const momentum_loss_factor = 1.01 # Should be bigger than 1.0 to lose momentum, less than 1.0 would make the bubble accelerate
const capturing_speed_factor = 15.0
const capturing_distance_threshold = 5
const wobble_base : float = 7.0
const wobble_momentum_gain : float = 20.0
const wobble_momentum_loss : float = 1.01
const base_scale = Vector2(0.18, 0.18)
var velocity : Vector2
var floating_velocity : Vector2 = Vector2(0.0, -30.0)
var wobble_momentum : float
var wobble_delta : float

@onready var collision_area : Area2D = $Area2D
@onready var bubble_sprite : Sprite2D = $Sprite2D
var current_collision_masks : Array

func _init():
	pass

func _ready():
	#collision_area = get_child(1)
	set_status("empty")

func _process(delta):
	wobbling_animation(delta)
	match status:
		"empty":
			# Check for transition to catching state (Check collision)
			if collision_area.has_overlapping_bodies():
				var first_area = collision_area.get_overlapping_bodies()[0]
				if first_area is Ingredient:
					target = first_area
				else:
					first_area.get_parent()
				set_status("catching")
			# Float up, lose momentum from player over time
			velocity = velocity / momentum_loss_factor
			position += (velocity + floating_velocity)*delta
		"catching":
			# We've collided with a target (ingredient or foe), home in on their position!!!
			if target is RigidBody2D:
				(target as RigidBody2D).apply_central_impulse((position - target.position) * 0.5)
			else:
				target.position += (position - target.position)*capturing_speed_factor*delta
				
			position += (target.position - position)*capturing_speed_factor*delta
			# Check if we've reached the target position, if so, transition to falling state
			if position.distance_to(target.position) < capturing_distance_threshold:
				target.position = position
				#TODO You should take complete control of the enemy's node (for position and rotation) here
				if target is Ingredient:
					(target as Ingredient).trap_in_bubble(self)
				else:
					target.reparent(self)
				
				set_status("falling")
		"falling":
			if target is RigidBody2D:
				(target as RigidBody2D).apply_central_impulse(-target.position * 0.2)
			else:
				target.position += (position - target.position)*capturing_speed_factor*delta
			
			# Check if we've reached ground, if so, transition to popping state
			if collision_area.has_overlapping_areas():
				#TODO "Let my people go!" Let the captured target fall to the ground, lose control over them
				set_status("popping")
			# Start falling toward the ground
			pass
		"popping":
			# For whatever reason, either we touched ground or something else, we are killing the bubble
			#TODO play bubble popping animation?
			queue_free() # Once The animation for popping is done, kill the node and children

func set_status(state):
	wobble_momentum = wobble_momentum_gain
	status = state
	match state:
		"empty":
			set_collision_masks([4, 5])		# Check for ingredients and enemies
		"catching":
			set_collision_masks([])			# We care about nothing.
		"falling":
			set_collision_masks([1])			# Check for ground only. Player's and Cauldron's job to check for us.
		"popping":
			set_collision_masks([])			# "There is nothing we can do." - Napoleon Bonaparte

func set_collision_masks(masks):
	# Set all masks to not be checked
	for mask in current_collision_masks:
		collision_area.set_collision_mask_value(mask, false)
	# Set masks from the masks argument array to be checked
	for mask in masks:
		collision_area.set_collision_mask_value(mask, true)
	# Store which masks are being used
	current_collision_masks = masks

func wobbling_animation(delta):
	var wobbling : float = wobble_base + wobble_momentum
	wobble_delta = fmod(wobble_delta + wobbling*delta, 2.0*PI)
	bubble_sprite.scale = base_scale + 0.02*Vector2(sin(wobble_delta), cos(wobble_delta))
	wobble_momentum /= wobble_momentum_loss
