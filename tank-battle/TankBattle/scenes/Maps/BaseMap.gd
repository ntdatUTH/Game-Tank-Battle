extends Node

@export var spawn_positions: Array[Vector2] = [Vector2(100,100)]
@export var endless_mode_spawner: PackedScene  # Scene spawner enemy cho chế độ bất tận
var victory_panel = null
func _ready():
	spawn_player()
	
	# Nếu là chế độ bất tận, kích hoạt spawner
	if GLOBALS.current_game_mode == GLOBALS.GameMode.ENDLESS:
		start_endless_mode()

func spawn_player(spawn_position: Vector2 = spawn_positions[0]):
	if GLOBALS.current_player and is_instance_valid(GLOBALS.current_player):
		GLOBALS.current_player.queue_free()
	
	# Kiểm tra lại sau khi xóa
	var existing_players = get_tree().get_nodes_in_group("Player")
	for p in existing_players:
		p.queue_free()
	var player_scene = load("res://TankBattle/scenes/Tanks/Player.tscn")
	var player = player_scene.instantiate()
	player.global_position = spawn_position

	if player.has_signal("shoot_"):
		player.shoot_.connect(_on_Tank_shoot)
	if player.has_signal("dead"):
		player.dead.connect(_on_Player_dead)

	add_child(player)

	var hud = load("res://TankBattle/scenes/UI/hud.tscn")
	var hud_instance = hud.instantiate()
	hud_instance.name = "HUD"
	add_child(hud_instance)

	var hud_node = $HUD
	player.ammo_changed.connect(hud_node.update_ammo)
	player.health_changed.connect(hud_node.update_healthbar)
	
	# Cập nhật HUD theo chế độ
	#if GLOBALS.current_game_mode == GLOBALS.GameMode.ENDLESS:
		#hud_node.update_mode_label("Endless Mode")

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
func _on_Tank_shoot(bullet, _position, _direction, _target = null):
	var b = bullet.instantiate()
	add_child(b)
	b.start(_position, _direction, _target)
var game_over_panel = null  # Biến lưu panel game over

func _on_Player_dead():
	# Kiểm tra nếu panel đã tồn tại thì không tạo mới
	if game_over_panel != null:
		return
	

	# Tạo panel game over
	game_over_panel = Panel.new()
	add_child(game_over_panel)
	
	# Thiết lập panel
	game_over_panel.size = Vector2(600, 300)
	game_over_panel.position = Vector2(276, 174)  # Căn giữa màn hình 1152x648
	game_over_panel.theme = Theme.new()
	
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
	
	#nhận tính hiệu khi chết rồi truyền dl qua globals
	if GLOBALS.current_game_mode == GLOBALS.GameMode.ENDLESS:
		var kills_label = Label.new()
		game_over_panel.add_child(kills_label)
		kills_label.text = "Kẻ thù đã tiêu diệt: " + str(GLOBALS.enemies_killed)
		kills_label.position = Vector2(180, 100)
		kills_label.add_theme_font_size_override("font_size", 30)
	#chổ này đọc điểm của số enemy đã tiêu diệt làm bxh
	GLOBALS.endless_score = GLOBALS.enemies_killed
		
	#kết thúc game endlesss thì cập nhật điểm 
	GLOBALS.add_current_player_to_leaderboard()
	
	if GLOBALS.current_game_mode == GLOBALS.GameMode.ENDLESS:
	# Đảm bảo có email và điểm hợp lệ
		if GLOBALS.player_email != "" and GLOBALS.enemies_killed > 0:
			var new_record = {
				"email": GLOBALS.player_email,
				"score": GLOBALS.enemies_killed
			}
			GLOBALS.leaderboard_data.append(new_record)
			
			# Debug: In ra để kiểm tra
			print("Added new record: ", new_record)
			
			# Lưu dữ liệu nếu cần
		
		
   		# Hiển thị bảng xếp hạng
		var leaderboard_scene = preload("res://TankBattle/scenes/rank/Rank.tscn").instantiate()
		get_tree().current_scene.add_child(leaderboard_scene)
		

	
	
	# Vô hiệu hóa player và enemy
	if GLOBALS.current_player:
		GLOBALS.current_player.set_process(false)
		GLOBALS.current_player.set_physics_process(false)



func _on_restart_pressed():
	if GLOBALS.current_game_mode == GLOBALS.GameMode.ENDLESS:
		get_tree().change_scene_to_file(GLOBALS.endless_map)
	else:
		GLOBALS.restart(GLOBALS.current_level)

func _on_menu_pressed():
	GLOBALS.restart(0)



	
func _input(event):
	if game_over_panel and event is InputEventKey:

		if Input.is_action_pressed("_on_restart_pressed"):
			_on_restart_pressed()
		elif Input.is_action_pressed("_on_menu_pressed"):
			_on_menu_pressed()
