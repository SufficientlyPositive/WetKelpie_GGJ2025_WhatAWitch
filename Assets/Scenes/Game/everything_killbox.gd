class_name EverythingKillbox
extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_killbox_entered(body: Node2D) -> void:
	if body.editor_description == "immortal":
		pass
	elif body is PlayerCharacter:
		pass
	elif body is Ingredient or body is Enemy:
		body.queue_free()
	else:
		body.get_parent().queue_free()
