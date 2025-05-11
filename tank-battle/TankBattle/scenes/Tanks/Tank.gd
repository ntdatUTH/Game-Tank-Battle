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
@export var bullet_speed: int = 500
@export var bullet_damage: int = 10
@export var bullet_lifetime: float = 0.5

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
	if not can_shoot:
		return
		
	can_shoot = false
	$GunTimer.start()
	
	var dir = Vector2(1, 0).rotated($Turret.global_rotation + deg_to_rad(90))
	
	# Bỏ kiểm tra ammo nếu là enemy
	if is_in_group("Enemy") or ammo > 0:
		if not is_in_group("Enemy"):
			ammo -= 1  # Chỉ trừ ammo nếu không phải enemy
			
		if multiplayer.is_server() or is_multiplayer_authority():
			if num > 1:
				for i in range(num):
					var a = -spread + i * (2 * spread) / (num - 1)
					spawn_bullet.rpc($Turret/Muzzle.global_position, dir.rotated(a), target)
			else:
				spawn_bullet.rpc($Turret/Muzzle.global_position, dir, target)
	
	$AnimationPlayer.play("muzzle_flash")

func _physics_process(delta):
	if not alive:
		return
	if is_multiplayer_authority():
		control(delta)
	if map:
		var tile_pos = map.local_to_map(position)
		var atlas_coords = map.get_cell_atlas_coords(0, tile_pos)
		#print("Toa do cell: ",atlas_coords)
		if GLOBALS.slow_terrain.has(atlas_coords):
			print("giam toc do", offroad_friction)
			velocity *= offroad_friction
	move_and_slide()

@rpc("any_peer", "call_local")
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
	print("=== KIỂM TRA KẾT NỐI ===")
	print("Signal connected?", is_connected("dead", Callable(BaseMap, "_on_Player_dead")))
	dead.emit(int(name))
	GLOBALS.restart()
	print("Emitting dead for:", name)
	print("EMITTING FROM PLAYER INSTANCE:", self)
	
func _on_gun_timer_timeout() -> void:
	can_shoot = true

func _on_explosion_animation_finished() -> void:
	queue_free()

@rpc("any_peer", "call_local", "reliable")
func spawn_bullet(pos: Vector2, dir: Vector2, target=null):
	var bullet = Bullet.instantiate()
	bullet.speed = bullet_speed
	bullet.damage = bullet_damage
	bullet.lifetime = bullet_lifetime
	bullet.position = pos
	bullet.rotation = dir.angle()
	bullet.set_multiplayer_authority(multiplayer.get_unique_id())
	
	# Thêm vào scene chính
	get_parent().add_child(bullet)
	
	# Thiết lập velocity sau khi add_child để tránh warning
	bullet.velocity = dir * bullet_speed
	if target:
		bullet.target = target
