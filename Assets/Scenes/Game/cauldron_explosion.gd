class_name CauldronExplosionAnimation
extends AnimatedSprite2D

const explosion_anim_name = "explosion"

func explode() -> void:
	visible = true
	play(explosion_anim_name)

func on_animation_finished() -> void:
	visible = false
