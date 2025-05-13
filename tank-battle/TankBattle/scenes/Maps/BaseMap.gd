extends Node

@export var spawn_positions: Array[Vector2] = [Vector2(100,100)]
@export var endless_mode_spawner: PackedScene  # Scene spawner enemy cho chế độ bất tận
var victory_panel = null
#
#func _ready():
	## Chỉ chạy khi OFFLINE (không có kết nối multiplayer)
	#print(multiplayer.multiplayer_peer)
	#if multiplayer.multiplayer_peer == null or multiplayer.multiplayer_peer.get_class() == "OfflineMultiplayerPeer":
		#print("add player")
		#spawn_player(1)  # Dùng ID mặc định (ví dụ: 1) cho offline
		## Nếu là chế độ bất tận, kích hoạt spawner
		#if GLOBALS.current_game_mode == GLOBALS.GameMode.ENDLESS:
			#start_endless_mode()

@rpc("any_peer", "call_local", "reliable")
func spawn_player(id, spawn_position: Vector2 = spawn_positions[0]):
	#if GLOBALS.current_player and is_instance_valid(GLOBALS.current_player):
		#GLOBALS.current_player.queue_free()
	#
	## Kiểm tra lại sau khi xóa
	#var existing_players = get_tree().get_nodes_in_group("Player")
	#for p in existing_players:
		#p.queue_free()
	print("Đã add người chơi")
	var player = preload("res://TankBattle/scenes/Tanks/Player.tscn").instantiate()
	player.name = str(id)
	player.Bullet = preload("res://TankBattle/scenes/Bullet/bounce_.tscn")
	player.z_index = 10
	# Đặt vị trí
	player.global_position = Vector2(100, 100)

	if id == multiplayer.get_unique_id():
		player.dead.connect(_on_Player_dead)
		player.shoot_.connect(_on_Tank_shoot)
		# 1. Kiểm tra CanvasLayer đã có HUD chưa
		var canvas = get_tree().current_scene.get_node("HUDlocal")
		if not canvas.has_node("HUD"):  # Dùng tên FIXED cho HUD local
			var hud = preload("res://TankBattle/scenes/UI/hud.tscn").instantiate()
			hud.name = "HUD"  # ⭐ Tên cố định chỉ 1 HUD duy nhất
			canvas.add_child(hud)
			# Kết nối signals
			player.ammo_changed.connect(hud.update_ammo)
			player.health_changed.connect(hud.update_healthbar)

	add_child(player)
	GLOBALS.current_player = player
	set_camera_limits(player)


func start_endless_mode():
	if endless_mode_spawner:
		var spawner = endless_mode_spawner.instantiate()
		add_child(spawner)
		print("Endless mode activated")
	else:
		push_warning("No endless spawner assigned")

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

@rpc("any_peer", "reliable")
func update_camera_limits(player_path: NodePath, limits: Dictionary):
	var player = get_node(player_path)
	if not player or not player.has_node("Camera2D"):
		return

	var camera = player.get_node("Camera2D")
	camera.limit_left = limits["left"]
	camera.limit_right = limits["right"]
	camera.limit_top = limits["top"]
	camera.limit_bottom = limits["bottom"]

func _on_Tank_shoot(bullet, _position, _direction, _target = null):
	print("Đã chạy signal Bắn")
	var b = bullet.instantiate()
	# Thiết lập tham số TRƯỚC khi add_child
	b.position = _position
	b.rotation = _direction.angle()
	b.velocity = _direction * b.speed  # Truy cập speed từ bullet
	b.target = _target
	add_child(b)

var game_over_panel = null  # Biến lưu panel game over
func _on_Player_dead():
	var canvas = get_tree().current_scene.get_node("HUDlocal")
	if canvas.has_node("LocalPlayerHUD"):
		var old_hud = canvas.get_node("LocalPlayerHUD")
		old_hud.queue_free()
	print("Dead đã chạy")
	if multiplayer.is_server():
		var all_players = []
		all_players.append_array(multiplayer.get_peers())
		rpc("sync_player_list", all_players)
	_show_game_over_panel()

func _show_game_over_panel():
	print("Panel đã chạy")
	# Kiểm tra nếu panel đã tồn tại thì không tạo mới
	if game_over_panel != null:
		return
	print("tạo Panel")
	var canvas = get_tree().current_scene.get_node("HUDlocal")
	# Tạo panel game over
	game_over_panel = Panel.new()
	game_over_panel.name = "game_over_panel"
	game_over_panel.z_index = 12
	game_over_panel.size = Vector2(600, 300)
	game_over_panel.position = Vector2(276, 174)
	canvas.add_child(game_over_panel)
	
	# Thêm label "Bạn đã chết"
	var death_label = Label.new()
	game_over_panel.add_child(death_label)
	death_label.text = "BẠN ĐÃ CHẾT"
	death_label.position = Vector2(200, 50)
	death_label.add_theme_font_size_override("font_size", 50)
	
	# Thêm nút "Chơi lại" (Y)
	var restart_button = Button.new()
	game_over_panel.add_child(restart_button)
	restart_button.text = "CHƠI LẠI (Y)"
	restart_button.position = Vector2(100, 150)
	restart_button.size = Vector2(150, 50)
	restart_button.pressed.connect(_on_restart_pressed)
	
	# Thêm nút "Về menu" (X)
	var menu_button = Button.new()
	game_over_panel.add_child(menu_button)
	menu_button.text = "VỀ MENU (X)"
	menu_button.position = Vector2(350, 150)
	menu_button.size = Vector2(150, 50)
	menu_button.pressed.connect(_on_menu_pressed)
	if GLOBALS.current_game_mode == GLOBALS.GameMode.ENDLESS:
		var kills_label = Label.new()
		game_over_panel.add_child(kills_label)
		kills_label.text = "Kẻ thù đã tiêu diệt: " + str(GLOBALS.enemies_killed)
		kills_label.position = Vector2(180, 100)
		kills_label.add_theme_font_size_override("font_size", 30)
		#chổ này đọc điểm của số enemy đã tiêu diệt làm bxh
		
	# Vô hiệu hóa player và enemy
	if GLOBALS.current_player:
		GLOBALS.current_player.set_process(false)
		GLOBALS.current_player.set_physics_process(false)

func _on_restart_pressed():
	var canvas = get_tree().current_scene.get_node("HUDlocal")
	if game_over_panel != null:
		canvas.get_node("game_over_panel").queue_free()
	if GLOBALS.current_game_mode == GLOBALS.GameMode.ENDLESS:
		get_tree().change_scene_to_file(GLOBALS.endless_map)
	elif multiplayer.multiplayer_peer == null or multiplayer.multiplayer_peer.get_class() == "OfflineMultiplayerPeer":
		GLOBALS.restart(GLOBALS.current_level)
	else:
		print("Đã nhảy vô xử lí mạng RESTART")
		if multiplayer.is_server():
			GLOBALS.restart.rpc(GLOBALS.current_level)  # Server chỉ điều khiển clients
		else:
			request_restart.rpc_id(1)  # Client gửi yêu cầu

func _on_menu_pressed():
	print("Đã ấn nút restart")
	if multiplayer.multiplayer_peer == null or multiplayer.multiplayer_peer.get_class() == "OfflineMultiplayerPeer":
		GLOBALS.restart(0)
	else:
		GLOBALS.restart.rpc_id(1,0)

@rpc("any_peer", "reliable")
func request_restart():
	print("Đã CHẠY REQUEST")
	if multiplayer.is_server():
		GLOBALS.restart.rpc(GLOBALS.current_level)  # Server broadcast

func _input(event):
	if game_over_panel and event is InputEventKey:
		if Input.is_action_pressed("_on_restart_pressed"):
			_on_restart_pressed()
		elif Input.is_action_pressed("_on_menu_pressed"):
			_on_menu_pressed()

@rpc("any_peer", "reliable")
func request_player_list():
	if multiplayer.is_server():
		var all_players = []
		all_players.append_array(multiplayer.get_peers())
		rpc("sync_player_list", all_players)

@rpc("reliable", "call_local")
func sync_player_list(players: Array):
	# Danh sách ID player hiện có
	var current_players = []
	for child in get_children():
		if child.is_in_group("Player"):
			current_players.append(int(child.name))
	
	# Xóa player không còn trong danh sách
	for player_id in current_players:
		if not player_id in players and player_id != multiplayer.get_unique_id():
			var player_node = get_node_or_null(str(player_id))
			if player_node:
				player_node.queue_free()
	
	# Thêm player mới
	for id in players:
		if not get_node_or_null(str(id)) and not has_node(str(id)):
			spawn_player(id)

@rpc("reliable", "call_local")
func remove_disconnected_player(id):
	var player_node = get_node_or_null(str(id))
	if player_node:
		player_node.queue_free()
		print("Removed player: ", id)
	
	# Nếu là server, cập nhật lại danh sách player
	if multiplayer.is_server():
		var remaining_players = []
		remaining_players.append_array(multiplayer.get_peers())
		sync_player_list(remaining_players)
