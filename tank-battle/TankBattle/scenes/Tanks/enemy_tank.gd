extends "res://TankBattle/scenes/Tanks/Tank.gd"

@onready var parent = get_parent()

@export var turret_speed: float
@export var detect_radius: int
var speed: float
var target = null

func _ready():
	super._ready()
	setup_detection_radius()
	add_to_group("Enemy")  # Nhóm để nhận diện

func setup_detection_radius():
	var circle = CircleShape2D.new()
	circle.radius = detect_radius
	$DetectRadius/CollisionShape2D.shape = circle

func control(delta):
	if parent is PathFollow2D:
		handle_patrol_movement(delta)

func handle_patrol_movement(delta):
	if $LookAhead1.is_colliding() or $LookAhead2.is_colliding():
		speed = lerp(speed, 0.0, 0.1)
	else:
		speed = lerp(speed, max_speed, 0.05)
	
	parent.progress += speed * delta
	position = Vector2.ZERO  # Giữ tank ở giữa PathFollow2D

func _process(delta):
	if target and is_instance_valid(target) and target.alive:
		aim_at_target(delta)
		try_attack()

func aim_at_target(delta):
	var to_target = target.global_position - $Turret.global_position
	var target_angle = to_target.angle()
	var current_angle = $Turret.global_rotation
	
	$Turret.global_rotation = lerp_angle(
		current_angle,
		target_angle - deg_to_rad(90),  # Điều chỉnh góc turret
		turret_speed * delta
	)

func try_attack():
	print(can_shoot)
	if can_shoot and abs($Turret.global_rotation - (target.global_position - $Turret.global_position).angle()) > 0.9:
		print("Đang bắn!")  # Debug xác nhận
		super.shoot(gun_shots, gun_spread, target)
		start_attack_cooldown()

func start_attack_cooldown():
	can_shoot = false
	await get_tree().create_timer(gun_cooldown).timeout
	can_shoot = true

func _on_detect_radius_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.alive:
		target = body
		print("Đã phát hiện mục tiêu: ", body.name)

func _on_detect_radius_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		print("Mất dấu mục tiêu")


func update_healthbar() -> void:
	pass # Replace with function body.
