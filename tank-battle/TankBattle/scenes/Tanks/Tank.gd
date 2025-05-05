extends CharacterBody2D

signal shoot_
signal health_changed
signal dead
signal ammo_changed

@export var Bullet: PackedScene
@export var max_speed: float
@export var rotation_speed: float = 1.0
@export var gun_cooldown: float
@export var max_health: int
@export var offroad_friction: float

@export var gun_shots: int = 1
@export_range(0, 1.5) var gun_spread: float = 0.2
@export var max_ammo: int = 20
var _ammo: int = -1  # Backing field
@export var ammo: int = -1:
	set(value):
		if value > max_ammo:
			value = max_ammo
		_ammo = value
		ammo_changed.emit(_ammo * 100 / max_ammo)
	get:
		return _ammo

var can_shoot = true
var alive = true
var health
var map

func _ready():
	health = max_health
	$Smoke.emitting = false
	health_changed.emit(health * 100 / max_health)
	ammo_changed.emit(ammo * 100 / max_ammo)
	$GunTimer.wait_time = gun_cooldown

func control(delta):
	pass

func shoot(num, spread, target=null):
	if can_shoot and ammo > 0:
		ammo -= 1  # Sẽ tự động gọi setter
		can_shoot = false
		$GunTimer.start()
		var dir = Vector2(1, 0).rotated($Turret.global_rotation + deg_to_rad(90))
		if num > 1:
			for i in range(num):
				var a = -spread + i * (2 * spread) / (num - 1)
				shoot_.emit(Bullet, $Turret/Muzzle.global_position, dir.rotated(a), target)
		else:
			shoot_.emit(Bullet, $Turret/Muzzle.global_position, dir, target)
		$AnimationPlayer.play("muzzle_flash")

func _physics_process(delta):
	if not alive:
		return
	control(delta)
	if map:
		var tile_pos = map.local_to_map(position)
		var atlas_coords = map.get_cell_atlas_coords(0, tile_pos)
		#print("Toa do cell: ",atlas_coords)
		if GLOBALS.slow_terrain.has(atlas_coords):
			print("giam toc do", offroad_friction)
			velocity *= offroad_friction
	move_and_slide()

func take_damage(amount):
	health -= amount
	health_changed.emit(health * 100 / max_health)
	if health < max_health/2 :
		$Smoke.emitting = true
	if health <= 0:
		explode()

func heal(amount):
	health += amount
	health = clamp(health, 0, max_health)
	health_changed.emit(health * 100 / max_health)
	if health >= max_health/2:
		$Smoke.emitting = false

func explode():
	$CollisionShape2D.disabled = true
	alive = false
	$Turret.hide()
	$Body.hide()
	$Explosion.show()
	$Explosion.play()
	dead.emit()
	
func _on_gun_timer_timeout() -> void:
	can_shoot = true

func _on_explosion_animation_finished() -> void:
	queue_free()
