extends "res://TankBattle/scenes/Maps/BaseMap.gd"
func _ready():
	GLOBALS.required_kills = 30
	GLOBALS.enemies_in_level = 0
	GLOBALS.enemies_killed = 0
	GLOBALS.current_level=3
	if !GLOBALS.current_player:
		if multiplayer.multiplayer_peer == null or multiplayer.multiplayer_peer.get_class() == "OfflineMultiplayerPeer":
			spawn_player(1)
	else:
		GLOBALS.load_player_state()
func _process(delta: float) -> void:
	if GLOBALS.enemies_killed >= GLOBALS.required_kills and victory_panel == null:
		show_victory_panel()
		if GLOBALS.current_player:
			GLOBALS.current_player.queue_free()
			GLOBALS.current_player = null
		

func show_victory_panel():
	# Tạo panel chiến thắng
	victory_panel = Panel.new()
	add_child(victory_panel)
	
	# Thiết lập kích thước và vị trí
	victory_panel.size = Vector2(600, 300)
	victory_panel.position = Vector2(276, 174)
	victory_panel.theme = Theme.new()

	# Thêm label "CHIẾN THẮNG!"
	var victory_label = Label.new()
	victory_panel.add_child(victory_label)
	victory_label.text = "CHIẾN THẮNG!"
	victory_label.position = Vector2(180, 50)
	victory_label.add_theme_font_size_override("font_size", 50)
	
	# Thêm nút "VỀ MENU (X)"
	var menu_button = Button.new()
	victory_panel.add_child(menu_button)
	menu_button.text = "VỀ MENU (X)"
	menu_button.position = Vector2(225, 150)
	menu_button.size = Vector2(150, 50)
	menu_button.pressed.connect(_on_menu_pressed)

	# Vô hiệu hóa player và enemy
	if GLOBALS.current_player:
		GLOBALS.current_player.set_process(false)
		GLOBALS.current_player.set_physics_process(false)

func _on_menu_pressed():
	GLOBALS.restart(0)

func _input(event):
	if victory_panel and event is InputEventKey:
		if Input.is_action_pressed("_on_menu_pressed"):
			_on_menu_pressed()
