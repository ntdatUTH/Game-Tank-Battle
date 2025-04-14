extends "res://TankBattle/scenes/Tanks/Tank.gd"

#func control(delta):
	#$Turret.look_at(get_global_mouse_position())
#
	#var rot_dir = 0
	#if Input.is_action_pressed("turn_right"):
		#rot_dir += 1
#
	#if Input.is_action_pressed("turn_left"):
		#rot_dir -= 1
	
	#rotation += rotation_speed * rot_dir * delta
	
	## Xóa `velocity=Vector2()` để tránh lỗi
	#velocity = Vector2.ZERO
	
	#if Input.is_action_pressed("forward"):
		#velocity = Vector2(speed, 0)
	#if Input.is_action_pressed("back"):
		#velocity = Vector2(-speed / 2, 0)
	
	## Di chuyển nhân vật
	#print("Velocity: ", velocity)
	#move_and_slide()
func control(delta):
	$Turret.look_at(get_global_mouse_position())
	$Turret.rotation += deg_to_rad(-90)
	velocity = Vector2.ZERO  # Khởi tạo lại velocity mỗi frame
	var rot_dir = 0
	
	# Xử lý di chuyển tự do
	if Input.is_action_pressed("forward"):
		velocity += Vector2(0, -1)
	if Input.is_action_pressed("back"):
		velocity += Vector2(0, 1)
	if Input.is_action_pressed("turn_right"):
		rot_dir += 3
		velocity += Vector2(1, 0)
	if Input.is_action_pressed("turn_left"):
		rot_dir -= 3
		velocity += Vector2(-1, 0)

	# Nếu có nhấn phím di chuyển
	if velocity.length() > 0:
		velocity = velocity.normalized() * max_speed  # Bình thường hóa vector và nhân với tốc độ
		rotation += rotation_speed * rot_dir * delta  # Cập nhật góc quay theo hướng di chuyển
		position += velocity * delta
	move_and_slide()
	
	if Input.is_action_just_pressed('click'):
		print("HP player: ", health)
		shoot(gun_shots, gun_spread)
