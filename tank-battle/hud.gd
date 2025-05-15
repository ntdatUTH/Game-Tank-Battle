extends CanvasLayer
var bar_red = preload("res://TankBattle/kenney_top-down-tanks/PNG/maudo.png")
var bar_green = preload("res://TankBattle/kenney_top-down-tanks/PNG/mauday.png")
var bar_yellow = preload("res://TankBattle/kenney_top-down-tanks/PNG/mauvang.png")
var bar_texture

func _ready() -> void:
	print(multiplayer.multiplayer_peer, multiplayer.multiplayer_peer.get_class())
	if multiplayer.multiplayer_peer != null && multiplayer.multiplayer_peer.get_class() != "OfflineMultiplayerPeer":
		$PauseButton.texture_normal = load("res://TankBattle/scenes/UI/logout.png")
func update_ammo(value):
	$Margin/Container/AmmoGauge.value=value

func update_healthbar(value):
	bar_texture = bar_green
	if value < 60:
		bar_texture = bar_yellow
	if value < 25:
		bar_texture = bar_red
	$Margin/Container/HealthBar.texture_progress = bar_texture
	var tween = create_tween()
	tween.tween_property(
		$Margin/Container/HealthBar, 
		"value", 
		value, 
		0.3  # Thời gian animation (giây)
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	$AnimationPlayer.play("healthbar_flash")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == 'healthbar_flash':
		$Margin/Container/HealthBar.texture_progress = bar_texture

var pause_panel = null
func _on_pause_button_pressed() -> void:
	if multiplayer.multiplayer_peer == null or multiplayer.multiplayer_peer.get_class() == "OfflineMultiplayerPeer":
		_show_pause_panel()
		get_tree().paused = true
	else:
		BaseMap._on_menu_pressed()

func _show_pause_panel():
	var canvas = get_tree().current_scene.get_node("HUDlocal")
	pause_panel = Panel.new()
	pause_panel.name = "pause"
	pause_panel.z_index = 13
	pause_panel.size = Vector2(600, 300)
	pause_panel.position = Vector2(276, 174)
	pause_panel.process_mode = Node.PROCESS_MODE_ALWAYS 
	canvas.add_child(pause_panel)
	
	# Thêm label "Bạn đã chết"
	var thongbao = Label.new()
	pause_panel.add_child(thongbao)
	thongbao.text = "THÔNG BÁO!"
	thongbao.position = Vector2(200, 50)
	thongbao.add_theme_font_size_override("font_size", 50)
	
	# Thêm nút "Chơi lại" (Y)
	var continue_button = Button.new()
	pause_panel.add_child(continue_button)
	continue_button.text = "TIẾP TỤC"
	continue_button.position = Vector2(100, 150)
	continue_button.size = Vector2(150, 50)
	continue_button.process_mode = Node.PROCESS_MODE_ALWAYS
	continue_button.pressed.connect(_on_continue_pressed)
	
	# Thêm nút "Về menu" (X)
	var menu_button = Button.new()
	pause_panel.add_child(menu_button)
	menu_button.text = "VỀ MENU"
	menu_button.position = Vector2(350, 150)
	menu_button.size = Vector2(150, 50)
	menu_button.process_mode = Node.PROCESS_MODE_ALWAYS
	menu_button.pressed.connect(BaseMap._on_menu_pressed)

func _on_continue_pressed():
	print("đã chạy continue")
	get_tree().paused = false
	var canvas = get_tree().current_scene.get_node("HUDlocal")
	canvas.get_node("pause").queue_free()
