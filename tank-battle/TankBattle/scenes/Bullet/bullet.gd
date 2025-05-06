extends Area2D

@export var speed: int
@export var damage: int
@export var lifetime: float
@export var steer_force : float = 0

var velocity = Vector2()
var acceleration=Vector2()
var target=null

func start(_position, _direction,_target=null):
	position = _position
	rotation = _direction.angle()
	$Lifetime.wait_time = lifetime
	velocity = _direction * speed
	$Lifetime.start()
	target=_target

func seek():
	var desired = (target.position - position).normalized() * speed
	var steer = desired - velocity
	if steer.length() > 0:
		steer = steer.normalized() * steer_force
	return steer

func _process(delta):
	if target:
		acceleration = seek()
		velocity += acceleration * delta
		velocity = velocity.limit_length(speed)
		rotation = velocity.angle()
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
