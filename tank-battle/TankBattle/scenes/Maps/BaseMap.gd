extends Node
  # Gán từ editor hoặc load bằng code

func set_camera_limits(player):
	# Kiểm tra node cần thiết (chạy trên mọi peer)
	if not has_node("Ground") or not player.has_node("Camera2D"):
		push_error("Thiếu Ground hoặc Camera2D")
		return

	var ground = $Ground
	var camera = player.get_node("Camera2D")
	var map_limits = ground.get_used_rect()
	var tile_size = ground.tile_set.tile_size

	# Tính toán giới hạn
	var limits = {
		"left": int(map_limits.position.x * tile_size.x),
		"right": int(map_limits.end.x * tile_size.x),
		"top": int(map_limits.position.y * tile_size.y),
		"bottom": int(map_limits.end.y * tile_size.y)
	}

	# Đồng bộ giới hạn camera qua RPC nếu là host
	if multiplayer.is_server():
		update_camera_limits.rpc(player.get_path(), limits)
	else:
		update_camera_limits(player.get_path(), limits)

@rpc("any_peer", "call_local", "reliable")
func update_camera_limits(player_path: NodePath, limits: Dictionary):
	var player = get_node(player_path)
	if not player or not player.has_node("Camera2D"):
		return

	var camera = player.get_node("Camera2D")
	camera.limit_left = limits["left"]
	camera.limit_right = limits["right"]
	camera.limit_top = limits["top"]
	camera.limit_bottom = limits["bottom"]

func _on_Player_dead(player_id: int):
	print("Người chơi ", player_id," có dấu hiệu chết")
	print(player_id, " và ", is_multiplayer_authority())
	print(multiplayer.get_peers())
	if multiplayer.is_server():
		var all_players = []
		all_players.append_array(multiplayer.get_peers())
		BaseMap.rpc("sync_player_list", all_players)

@rpc("any_peer", "reliable")
func announce_player_death(player_id: int):
	print("Người chơi ", player_id, " đã rời khỏi game")

@rpc("authority", "reliable")
func prepare_disconnect():
	print("Chuẩn bị ngắt kết nối...")
	# Lưu dữ liệu, hiển thị thông báo
	await get_tree().create_timer(1.0).timeout
	GLOBALS.restart()

func _on_Tank_shoot(bullet, _position, _direction, _target = null):
	print("Đã chạy signal Bắn")
	var b = bullet.instantiate()
	# Thiết lập tham số TRƯỚC khi add_child
	b.position = _position
	b.rotation = _direction.angle()
	b.velocity = _direction * b.speed  # Truy cập speed từ bullet
	b.target = _target
	add_child(b)

@rpc("any_peer", "call_local", "reliable")
func add_player(id):
	print("Đã add người chơi")
	var player = preload("res://TankBattle/scenes/Tanks/Player.tscn").instantiate()
	player.name = str(id)
	player.Bullet = preload("res://TankBattle/scenes/Bullet/bounce_.tscn")
	player.z_index = 10
	# Đặt vị trí
	player.global_position = Vector2(100, 100)

	# ✅ KẾT NỐI TÍN HIỆU
	# Chỉ thực hiện trên client của người chơi hiện tại
		# Kết nối signal
	if player.has_signal("shoot_"):
		player.shoot_.connect(_on_Tank_shoot)
	if player.has_signal("dead"):
		player.dead.connect(_on_Player_dead)
				# Kiểm tra HUD chưa tồn tại
	# ⚠️ QUAN TRỌNG: Chỉ xử lý HUD trên client LOCAL
	# ⚠️ QUAN TRỌNG: Chỉ xử lý HUD trên client LOCAL
	if id == multiplayer.get_unique_id():
		# 1. Kiểm tra CanvasLayer đã có HUD chưa
		var canvas = get_node("/root/map02/HUDlocal")
		if not canvas.has_node("LocalPlayerHUD"):  # Dùng tên FIXED cho HUD local
			var hud = preload("res://TankBattle/scenes/UI/hud.tscn").instantiate()
			hud.name = "LocalPlayerHUD"  # ⭐ Tên cố định chỉ 1 HUD duy nhất
			canvas.add_child(hud)
			
			# Kết nối signals
			player.ammo_changed.connect(hud.update_ammo)
			player.health_changed.connect(hud.update_healthbar)

	add_child(player)
	set_camera_limits(player)

@rpc("any_peer", "reliable")
func request_player_list():
	if multiplayer.is_server():
		var all_players = []
		all_players.append_array(multiplayer.get_peers())
		rpc("sync_player_list", all_players)

@rpc("reliable", "call_local")
func sync_player_list(players: Array):
	for id in players:
		if not get_node_or_null(str(id)):  # Tránh thêm trùng
			add_player(id)
			pass
