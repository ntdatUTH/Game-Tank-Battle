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
		
		speed = 0
		pass

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
			shoot()
func _on_detect_radius_body_entered(body: Node2D) -> void:
	print(body.name)
	target = body

func _on_detect_radius_body_exited(body: Node2D) -> void:
	if (body == target):
		target = null
		print("ko co player")


func update_healthbar() -> void:
	pass # Replace with function body.
