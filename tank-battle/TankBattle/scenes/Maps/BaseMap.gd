extends Node
  # Gán từ editor hoặc load bằng code

func _ready():
	spawn_player()

func spawn_player():
	var player_scene =load("res://TankBattle/scenes/Tanks/Player.tscn")

	var player = player_scene.instantiate()

	# Đặt vị trí
	player.global_position = Vector2(100, 100)

	# ✅ KẾT NỐI TÍN HIỆU
	if player.has_signal("shoot_"):
		player.shoot_.connect(_on_Tank_shoot)

	if player.has_signal("dead"):
		player.dead.connect(_on_Player_dead)
		add_child(player)
	var hud = load("res://TankBattle/scenes/UI/hud.tscn")
	var hud_instance = hud.instantiate()
	hud_instance.name = "HUD"
	add_child(hud_instance)  # Thêm vào node bạn muốn
	var hud_node = $HUD
	player.ammo_changed.connect(hud_node.update_ammo)
	player.health_changed.connect(hud_node.update_healthbar)
	set_camera_limits(player)


func set_camera_limits(player):
	if not has_node("Ground") or not player.has_node("Camera2D"):
		push_error("Thiếu Ground hoặc Camera2D")
		return

	var ground = $Ground
	var camera = player.get_node("Camera2D")
	var map_limits = ground.get_used_rect()
	var tile_size = ground.tile_set.tile_size

	camera.limit_left = int(map_limits.position.x * tile_size.x)
	camera.limit_right = int(map_limits.end.x * tile_size.x)
	camera.limit_top = int(map_limits.position.y * tile_size.y)
	camera.limit_bottom = int(map_limits.end.y * tile_size.y)

func _on_Player_dead():
	GLOBALS.restart()

func _on_Tank_shoot(bullet, _position, _direction, _target = null):
	var b = bullet.instantiate()
	add_child(b)
	b.start(_position, _direction, _target)
