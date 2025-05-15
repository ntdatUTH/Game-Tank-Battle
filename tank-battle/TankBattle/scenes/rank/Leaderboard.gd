extends Control

@onready var http_request = $HTTPRequest
@onready var vbox_container = $VBoxContainer
@onready var header_container = $VBoxContainer/HBoxContainer
@onready var stt_label = $VBoxContainer/HBoxContainer/STTLabel
@onready var user_label = $VBoxContainer/HBoxContainer/UserLabel
@onready var score_label = $VBoxContainer/HBoxContainer/ScoreLabel
@onready var leaderboard_box = $VBoxContainer/LeaderboardBox
@onready var refresh_button = $RefreshButton

func _ready():
	refresh_button.pressed.connect(Callable(self, "_on_refresh_button_pressed"))
	http_request.request_completed.connect(Callable(self, "_on_http_request_completed"))
	GLOBALS.connect("player_email_changed", Callable(self, "_on_player_email_changed"))
	setup_header()
	load_leaderboard()

func setup_header():
	var header_labels = [stt_label, user_label, score_label]
	var header_texts = ["STT", "Người dùng", "Điểm"]
	
	for i in range(header_labels.size()):
		var label = header_labels[i]
		label.text = header_texts[i]
		label.add_theme_font_size_override("font_size", 24)
		label.add_theme_color_override("font_color", Color.GOLD)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_constant_override("margin_right", 10)

func _on_refresh_button_pressed():
	load_leaderboard()

func _on_player_email_changed(new_email):
	print("[BXH] Nhận email mới:", new_email)
	load_leaderboard()

func load_leaderboard():
	if http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		http_request.cancel_request() 
	var url = "https://game-tank-battle-default-rtdb.firebaseio.com/scores.json"
	var err = http_request.request(url)
	if err != OK:
		print("Lỗi khi gửi request: ", err)

func _on_http_request_completed(result, response_code, headers, body):
	if response_code != 200:
		print("Lỗi khi lấy dữ liệu: %d" % response_code)
		return
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json == null:
		print("Lỗi khi phân tích JSON")
		return
	
	# Xóa dữ liệu cũ
	for child in leaderboard_box.get_children():
		leaderboard_box.remove_child(child)
		child.queue_free()
	
	# Xử lý dữ liệu
	var players = []
	for player_name in json.keys():
		var score = int(json[player_name]["score"])
		players.append({ "name": player_name, "score": score })
	
	players.sort_custom(func(a, b): return a["score"] > b["score"])
	
	var display_count = min(players.size(), 10)
	
	for i in range(display_count):
		var hbox = HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		hbox.custom_minimum_size = Vector2(0, 40)  # Đặt chiều cao tối thiểu
		
		# Kiểm tra và highlight người chơi hiện tại
		if str(players[i]["name"]).strip_edges() == str(GLOBALS.player_email).strip_edges():
			print("DEBUG: Tìm thấy dòng cần highlight - ", players[i]["name"])
			var stylebox = StyleBoxFlat.new()
			stylebox.bg_color = Color(0.98, 0.92, 0.84)  # Màu beige
			stylebox.set_content_margin_all(10)
			stylebox.corner_radius_top_left = 5
			stylebox.corner_radius_top_right = 5
			stylebox.corner_radius_bottom_left = 5
			stylebox.corner_radius_bottom_right = 5
			hbox.add_theme_stylebox_override("panel", stylebox)
			
			# Đổi màu chữ để dễ nhìn hơn
			var highlight_color = Color.RED  # Màu chữ tối
			
			# STT
			var stt = Label.new()
			stt.text = str(i + 1) + "."
			stt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			stt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			stt.add_theme_font_size_override("font_size", 20)
			stt.add_theme_color_override("font_color", highlight_color)
			
			# Tên người chơi
			var name = Label.new()
			name.text = players[i]["name"]
			name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			name.add_theme_font_size_override("font_size", 20)
			name.add_theme_color_override("font_color", highlight_color)
			
			# Điểm số
			var score = Label.new()
			score.text = str(players[i]["score"])
			score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			score.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			score.add_theme_font_size_override("font_size", 20)
			score.add_theme_color_override("font_color", highlight_color)
			
			hbox.add_child(stt)
			hbox.add_child(name)
			hbox.add_child(score)
		else:
			# Tạo các label bình thường
			var stt = Label.new()
			stt.text = str(i + 1) + "."
			stt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			stt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			stt.add_theme_font_size_override("font_size", 20)
			stt.add_theme_color_override("font_color", Color.WHITE)
			
			var name = Label.new()
			name.text = players[i]["name"]
			name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			name.add_theme_font_size_override("font_size", 20)
			name.add_theme_color_override("font_color", Color.WHITE)
			
			var score = Label.new()
			score.text = str(players[i]["score"])
			score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			score.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			score.add_theme_font_size_override("font_size", 20)
			score.add_theme_color_override("font_color", Color.WHITE)
			
			hbox.add_child(stt)
			hbox.add_child(name)
			hbox.add_child(score)
		
		leaderboard_box.add_child(hbox)
		
		if i < display_count - 1:
			var separator = HSeparator.new()
			separator.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			leaderboard_box.add_child(separator)

func _on_button_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://TankBattle/scenes/UI/title_screen.tscn")
