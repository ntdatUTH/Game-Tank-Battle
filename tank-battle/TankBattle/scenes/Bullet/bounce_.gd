extends CharacterBody2D

@export var speed: int =20

@export var damage: int = 20
@export var lifetime: float = 5.0
@export var bounciness: float = 1.2  # Độ đàn hồi khi nảy
@export var max_bounces: int = 5     # Số lần nảy tối đa

var bounce_count: int = 0
var initial_direction: Vector2 = Vector2.ZERO

func start(_position: Vector2, _direction: Vector2, _target=null):
	position = _position
	rotation = _direction.angle()
	initial_direction = _direction
	velocity = initial_direction * speed
	$Lifetime.wait_time = lifetime
	$Lifetime.start()

func _physics_process(delta: float) -> void:
	# Di chuyển và xử lý va chạm
	var collision = move_and_collide(velocity *speed *delta)
	if collision:
		handle_collision(collision)

func handle_collision(collision: KinematicCollision2D):
	bounce_count += 1
	
	# Xử lý nảy
	velocity = velocity.bounce(collision.get_normal()) * bounciness
	rotation = velocity.angle()
	
	# Xử lý khi chạm enemy/player
	if collision.get_collider().is_in_group("Enemy") or collision.get_collider().is_in_group("Player"):
		explode()
		if collision.get_collider().has_method("take_damage"):
			collision.get_collider().take_damage(damage)
	# Xử lý khi hết số lần nảy
	elif bounce_count >= max_bounces:
		explode()

func explode():
	velocity = Vector2.ZERO
	$Sprite2D.hide()
	$Explosion.show()
	$Explosion.play("smoke")
	set_physics_process(false)  # Dừng xử lý vật lý

func _on_lifetime_timeout():
	explode()

func _on_explosion_animation_finished():
	queue_free()
