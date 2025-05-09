extends Node

@export var spawn_positions: Array[Vector2] = [Vector2(100,100)]
@export var endless_mode_spawner: PackedScene  # Scene spawner enemy cho chế độ bất tận

func _ready():
	spawn_player()
	
	# Nếu là chế độ bất tận, kích hoạt spawner
	if GLOBALS.current_game_mode == GLOBALS.GameMode.ENDLESS:
		start_endless_mode()

func spawn_player(spawn_position: Vector2 = spawn_positions[0]):
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

func _on_Player_dead():
	if GLOBALS.current_game_mode == GLOBALS.GameMode.ENDLESS:
		# Chuyển thẳng về màn hình chọn chế độ
		get_tree().change_scene_to_file("res://TankBattle/scenes/UI/mode_selection.tscn")
	else:
		# Giữ nguyên xử lý cho campaign
		GLOBALS.restart()

func show_endless_results():
	var game_over = preload("res://TankBattle/scenes/UI/mode_selection.tscn").instantiate()
	game_over.set_score(GLOBALS.enemies_killed)
	add_child(game_over)

func _on_Tank_shoot(bullet, _position, _direction, _target = null):
	var b = bullet.instantiate()
	add_child(b)
	b.start(_position, _direction, _target)
