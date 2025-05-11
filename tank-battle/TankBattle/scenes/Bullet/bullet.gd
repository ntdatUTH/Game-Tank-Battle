extends Area2D

@export var speed: int
@export var damage: int
@export var lifetime: float
@export var steer_force : float = 0

var velocity = Vector2()
var acceleration=Vector2()
var target=null
var shooter_id: int

func _ready():
	$Lifetime.wait_time = lifetime
	$Lifetime.start()
	
	# Chỉ owner mới điều khiển bullet
	if multiplayer.multiplayer_peer != null:
		set_multiplayer_authority(multiplayer.get_unique_id())

func seek():
	if !is_instance_valid(target) || !target is Node2D:
		return Vector2.ZERO  # Trả về vector zero nếu target không hợp lệ
	var desired = (target.position - position).normalized() * speed
	var steer = desired - velocity
	if steer.length() > 0:
		steer = steer.normalized() * steer_force
	return steer

func _physics_process(delta):
	if multiplayer.multiplayer_peer == null or is_multiplayer_authority():
		if target:
			acceleration = seek()
			velocity += acceleration * delta
			velocity = velocity.limit_length(speed)
			rotation = velocity.angle()
		
		position += velocity * delta

func _on_Bullet_body_entered(body: Node2D) -> void:
	if body != get_parent():
		explode.rpc()
		if body.has_method('take_damage'):
			body.take_damage.rpc(damage)

@rpc("any_peer", "call_local", "reliable")
func explode():
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true)
	$Sprite.hide()
	$Explosion.show()
	$Explosion.play("smoke")

func _on_lifetime_timeout() -> void:
	explode.rpc()

func _on_explosion_animation_finished() -> void:
	queue_free() # Replace with function body.
