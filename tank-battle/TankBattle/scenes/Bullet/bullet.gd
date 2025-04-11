extends Area2D

@export var speed: int
@export var damage: int
@export var lifetime: float

var velocity = Vector2()

func start(_position, _direction):
	position = _position
	rotation = _direction.angle()
	$Lifetime.wait_time = lifetime
	velocity = _direction * speed
	$Lifetime.start()

func _process(delta):
	position += velocity * delta

#Hàm phát nổ
func explode():
	velocity = Vector2()
	$Sprite.hide()
	$Explosion.show()
	$Explosion.play("smoke")
func _on_Bullet_body_entered(body: Node2D) -> void:
	print("trung enemy")
	explode()
	if body.has_method('take_damage'):
		body.take_damage(damage)

func _on_lifetime_timeout() -> void:
	explode()
func _on_explosion_animation_finished() -> void:
	queue_free() # Replace with function body.
