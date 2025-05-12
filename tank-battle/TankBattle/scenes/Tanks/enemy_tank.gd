extends "res://TankBattle/scenes/Tanks/Tank.gd"

@onready var parent = get_parent()

@export var turret_speed: float
@export var detect_radius: int
var speed: float
var target = null

func _ready():
	super._ready()
	var circle = CircleShape2D.new()
	$DetectRadius/CollisionShape2D.shape = circle
	$DetectRadius/CollisionShape2D.shape.radius = detect_radius
	GLOBALS.register_enemy()
	add_to_group("Enemy")
func shoot(num, spread, target = null):
	if not can_shoot or not target.is_in_group("Player"):
		return
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

func control(delta):
	if parent is PathFollow2D:
		if $LookAhead1.is_colliding() or $LookAhead2.is_colliding():
			speed = lerp(speed, 0.0, 0.1)
		else:
			speed = lerp(speed, max_speed, 0.05)
		parent.progress += speed*delta
		# Reset vị trí local để tránh lệch khỏi PathFollow2D
		position = Vector2i.ZERO
	else:
		speed = 100
	var player=get_tree().get_first_node_in_group("Player")
	if player :
		var direction=(player.global_position-global_position).normalized()
		velocity=direction*max_speed
		rotation = lerp_angle(rotation, (player.global_position - global_position).angle(), turret_speed * delta)


func _process(delta):
	if target:
		# Tính góc hiện tại và góc mục tiêu
		var current_angle = $Turret.global_rotation
		var target_angle = (target.global_position - $Turret.global_position).angle()
		# Nội suy góc với tốc độ turret_speed
		$Turret.global_rotation = lerp_angle(current_angle, target_angle - deg_to_rad(90), turret_speed * delta)
	
		# Kiểm tra hướng bằng góc thay vì dot product
		if abs(current_angle - target_angle) > 0.9:  # ~5.7 độ
			print("HP bot: ", health)
			shoot(gun_shots,gun_spread,target)
func _on_detect_radius_body_entered(body: Node2D) -> void:
	print(body.name)
	target = body

func _on_detect_radius_body_exited(body: Node2D) -> void:
	if (body == target):
		target = null
		print("ko co player")
func take_damage(amount: int):
	if is_in_group("Player"):  # Bỏ qua nếu là Player
		return
	
	print("Enemy took damage! Current HP:", health, " - Damage:", amount)
	super.take_damage(amount)  # Gọi hàm cha (Tank.gd)
	if health <= 0:
		die()
		print("Enemy died!")  # Đổi thông báo cho rõ ràng
func die():
	super.explode()
	GLOBALS.enemy_killed()
	
	
	
