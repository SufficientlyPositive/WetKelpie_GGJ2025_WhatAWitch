class_name CauldronExplosionAnimation
extends AnimatedSprite2D

const no_anim_name = "default"
const explosion_anim_name = "explosion"

func explode() -> void:
	if animation == no_anim_name:
		play(explosion_anim_name)

func on_animation_finished() -> void:
	if animation == explosion_anim_name:
		play(no_anim_name)
