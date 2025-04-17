extends Area2D

enum Items {health, ammo}
var icon_textures=[preload("res://TankBattle/kenney_top-down-tanks-redux/Pickup/icon_pin-Photoroom.png"),
preload("res://TankBattle/kenney_top-down-tanks-redux/Pickup/dantrang.png")]
@export var type: Items = Items.health
@export var amount: Vector2 = Vector2(10, 25)
func _ready():
	$"IconPin-photoroom".texture=icon_textures[type]
func _on_body_entered(body: Node) -> void:
	match type:
		Items.health:
			if body.has_method("heal"):
				print("healing")
				body.heal(randi_range(int(amount.x), int(amount.y)))
		Items.ammo:
			body.ammo+=int(randi_range(amount.x,amount.y))
	queue_free()
