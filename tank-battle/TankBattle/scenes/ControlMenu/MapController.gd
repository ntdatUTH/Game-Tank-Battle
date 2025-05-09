extends Node

@export var spawn_positions: Array[Vector2] = [Vector2(100,100)]

func _ready():
	spawn_player()
	
	# Nếu là chế độ bất tận, setup spawner enemy
	if GLOBALS.current_game_mode == GLOBALS.GameMode.ENDLESS:
		setup_endless_mode()

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

	GLOBALS.current_player = player
	set_camera_limits(player)

func setup_endless_mode():
	# Tạo spawner enemy cho chế độ bất tận
	var spawner = preload("res://path_to_your_spawner.tscn").instantiate()
	add_child(spawner)
	
	# Cập nhật HUD cho chế độ bất tận
	$HUD.update_mode_label("Endless Mode")

func _on_Player_dead():
	if GLOBALS.current_game_mode == GLOBALS.GameMode.ENDLESS:
		show_game_over_screen()
	else:
		GLOBALS.restart()

func show_game_over_screen():
	var game_over = preload("res://TankBattle/scenes/UI/game_over.tscn").instantiate()
	add_child(game_over)
	game_over.set_score(GLOBALS.enemies_killed)

# ... (các hàm khác giữ nguyên)
