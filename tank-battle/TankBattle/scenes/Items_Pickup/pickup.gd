extends Area2D

enum Items {health, ammo}

@export var type: Items = Items.health
@export var amount: Vector2 = Vector2(10, 25)

func _on_body_entered(body: Node) -> void:
	match type:
		Items.health:
			if body.has_method("heal"):
				print("healing")
				body.heal(randi_range(int(amount.x), int(amount.y)))
		Items.ammo:
			pass
	queue_free()
