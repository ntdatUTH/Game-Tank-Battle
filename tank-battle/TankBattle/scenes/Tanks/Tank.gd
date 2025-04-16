extends CharacterBody2D
signal shoot_
signal health_changed
signal dead
@export var Bullet: PackedScene
@export var max_speed: float
@export var rotation_speed: float = 1.0
@export var gun_cooldown: float
@export var max_health: int
@export var gun_shots: int =1
@export_range(0, 1.5)
var gun_spread: float = 0.2

var can_shoot = true
var alive = true
var health

func _ready():
	health = max_health
	emit_signal('health_changed',health * 100/max_health)
	$GunTimer.wait_time = gun_cooldown

func control(delta):
	pass

func shoot(num,spread,target=null):
	if can_shoot:
		can_shoot = false
		$GunTimer.start()
		var dir = Vector2(1,0).rotated($Turret.global_rotation+deg_to_rad(90))
		if num>1:
			for i in range(num):
				var a =-spread+i*(2*spread)/(num-1)
				shoot_.emit(Bullet, $Turret/Muzzle.global_position, dir.rotated(a),target)
		else:
			
			shoot_.emit(Bullet, $Turret/Muzzle.global_position, dir,target)
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
func heal(amount):
	health += amount
	health = clamp(health,0, max_health)
	emit_signal('health_changed', health * 100/max_health)
	
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
