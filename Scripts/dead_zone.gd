extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("damage") and body is Player:
		body.damage()
