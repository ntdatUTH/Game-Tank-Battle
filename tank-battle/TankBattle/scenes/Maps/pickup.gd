extends Area2D

enum ItemType {HEALTH, AMMO}

@export var type: ItemType = ItemType.HEALTH
@export var amount: Vector2 = Vector2(10, 25)

# Tín hiệu để thông báo khi item bị ăn
signal item_collected(item_type: ItemType, amount: int)

func _on_body_entered(body: Node) -> void:
	var collected_amount = randi_range(int(amount.x), int(amount.y))
	
	match type:
		ItemType.HEALTH:
			if body.has_method("heal"):
				body.heal(collected_amount)
				emit_signal("item_collected", type, collected_amount)
		ItemType.AMMO:
			if body.has_method("add_ammo"):
				body.add_ammo(collected_amount)
				emit_signal("item_collected", type, collected_amount)
	
	queue_free()
