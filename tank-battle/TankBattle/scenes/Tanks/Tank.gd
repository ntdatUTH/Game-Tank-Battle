extends CharacterBody2D
signal shoot_
signal health_changed
signal dead
@export var Bullet: PackedScene
@export var max_speed: float
@export var rotation_speed: float = 1.0
@export var gun_cooldown: float
@export var max_health: int


var can_shoot = true
var alive = true
var health

func _ready():
	health = max_health
	emit_signal('health_changed',health * 100/max_health)
	$GunTimer.wait_time = gun_cooldown

func control(delta):
	pass

func shoot():
	if can_shoot:
		can_shoot = false
		$GunTimer.start()
		var dir = Vector2(1,0).rotated($Turret.global_rotation+deg_to_rad(90))
		shoot_.emit(Bullet, $Turret/Muzzle.global_position, dir)
		$AnimationPlayer.play("muzzle_flash")

func _physics_process(delta):
	if not alive:
		return
	control(delta)

func take_damage(amount):
	health -= amount
	emit_signal('health_changed', health * 100/max_health)
	if health <=0:
		explode()
	 #hàm chết
	
func explode():
	$CollisionShape2D.disabled=true
	alive =false
	$Turret.hide()
	$Body.hide()
	$Explosion.show()
	$Explosion.play()
	emit_signal('dead')
	
func _on_gun_timer_timeout() -> void:
	can_shoot = true


func _on_explosion_animation_finished() -> void:
	queue_free()
