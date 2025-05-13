extends Control
@onready var vbox_container = %VBoxContainer

@onready var STT_Label = $Panel/VBoxContainer/HBoxContainer/STTLabel
@onready var Email_Label = $Panel/VBoxContainer/HBoxContainer/EmailLabel
@onready var Score_Label = $Panel/VBoxContainer/HBoxContainer/ScoreLabel

# Cấu hình Firebase
const FIREBASE_CONFIG = {
	"apiKey": "AIzaSyC_C33LbHn4tn9PTVZwYWJjqKPPqbRCkS0",
	"authDomain": "game-tank-battle.firebaseapp.com",
	"databaseURL": "https://game-tank-battle-default-rtdb.firebaseio.com",
	"projectId": "game-tank-battle",
	"storageBucket": "game-tank-battle.appspot.com",
	"messagingSenderId": "881841128069"
}

var http_request : HTTPRequest

func _ready():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_http_request_completed)
	
	# Kiểm tra kết nối internet và Firebase
	if  GLOBALS.is_connected:
		await fetch_leaderboard()
		print("Kết nối database thành công")
	else:
		# Hiển thị dữ liệu mẫu nếu offline
		print("Kết nối thất bại")
		show_sample_data()

#func test_internet_connection() -> bool:
	#var test_request = HTTPRequest.new()
	#add_child(test_request)
	#
	#var connected = false
	#var timer = get_tree().create_timer(5.0) # Timeout sau 5 giây
	#
	## Callback khi nhận phản hồi
	#var callback = func(_result, code, _headers, _body):
		#connected = (code == 204) # 204 No Content
		#test_request.queue_free()
	#
	#test_request.request_completed.connect(callback)
	#
	#var error = test_request.request("http://connectivitycheck.gstatic.com/generate_204")
	#if error != OK:
		#test_request.queue_free()
		#return false
	#
	#await timer.timeout
	#return connected

func fetch_leaderboard():
	var url = FIREBASE_CONFIG["databaseURL"] + "/leaderboard.json?auth=" + GLOBALS.firebase_token
	url += "&orderBy=\"score\"&limitToLast=10" # Lấy top 10 điểm cao nhất
	
	var error = http_request.request(url)
	if error != OK:
		push_error("Không thể gửi yêu cầu leaderboard")
		return
	
	var result = await http_request.request_completed
	var response = parse_response(result[3])
	
	if response:
		var leaderboard_data = convert_firebase_data(response)
		display_leaderboard(leaderboard_data)
	else:
		push_error("Không có dữ liệu leaderboard")
		show_sample_data()

func convert_firebase_data(firebase_data: Dictionary) -> Array:
	var result = []
	
	for key in firebase_data:
		var entry = firebase_data[key]
		if entry and typeof(entry) == TYPE_DICTIONARY:
			result.append({
				"email": entry.get("email", "unknown"),
				"score": entry.get("score", 0)
			})
	
	# Sắp xếp giảm dần theo điểm
	result.sort_custom(func(a, b): return a["score"] > b["score"])
	return result

func save_score_to_firebase(email: String, score: int):
	if not GLOBALS.is_connected:
		push_error("Không có kết nối, không thể lưu điểm")
		return
	
	# Tạo ID duy nhất từ email
	var player_id = email.sha1_text()
	
	var url = FIREBASE_CONFIG["databaseURL"] + "/leaderboard/" + player_id + ".json?auth=" + GLOBALS.firebase_token
	
	var data = {
		"email": email,
		"score": score,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(data)
	
	var error = http_request.request(url, headers, HTTPClient.METHOD_PUT, body)
	if error != OK:
		push_error("Không thể gửi điểm lên Firebase")

func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	print("HTTP Request Completed - Code:", response_code)
	if response_code != 200:
		push_error("Lỗi request:", body.get_string_from_utf8())

func parse_response(body: PackedByteArray):
	var body_text = body.get_string_from_utf8()
	if body_text == "" or body_text == "null":
		return null
	
	var json = JSON.new()
	if json.parse(body_text) != OK:
		push_error("Lỗi parse JSON:", json.get_error_message())
		return null
	
	return json.get_data()

func show_sample_data():
	var sample_data = [
		{"email": "player1@example.com", "score": 150},
		{"email": GLOBALS.player_email, "score": GLOBALS.enemies_killed},
		{"email": "player2@example.com", "score": 120},
		{"email": "player3@example.com", "score": 90}
	]
	display_leaderboard(sample_data)

func display_leaderboard(data: Array):
	# Xóa các dòng cũ (giữ lại dòng tiêu đề)
	for child in vbox_container.get_children():
		if child != $Panel/VBoxContainer/HBoxContainer:
			child.queue_free()
	
	# Thêm các dòng mới
	for i in range(data.size()):
		var record = data[i]
		add_leaderboard_row(i + 1, record["email"], record["score"])

func add_leaderboard_row(rank: int, email: String, score: int):
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var rank_label = Label.new()
	rank_label.text = str(rank) + "."
	rank_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var email_label = Label.new()
	email_label.text = str(email)
	email_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var score_label = Label.new()
	score_label.text = str(score)
	score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	hbox.add_child(rank_label)
	hbox.add_child(email_label)
	hbox.add_child(score_label)
	
	# Highlight người chơi hiện tại
	if email == GLOBALS.player_email:
		hbox.add_theme_color_override("font_color", Color.YELLOW)
		email_label.add_theme_font_size_override("font_size", 25)
	
	vbox_container.add_child(hbox)





#extends Control
#@onready var vbox_container = %VBoxContainer
#
#@onready var STT_Label = $Panel/VBoxContainer/HBoxContainer/STTLabel
#@onready var Email_Label = $Panel/VBoxContainer/HBoxContainer/EmailLabel
#@onready var Score_Label = $Panel/VBoxContainer/HBoxContainer/ScoreLabel
#
 ##Cấu hình Firebase
#const FIREBASE_CONFIG = {
	#"apiKey": "AIzaSyC_C33LbHn4tn9PTVZwYWJjqKPPqbRCkS0",
	#"authDomain": "game-tank-battle.firebaseapp.com",
	#"databaseURL": "https://game-tank-battle-default-rtdb.firebaseio.com",
	#"projectId": "game-tank-battle",
	#"storageBucket": "game-tank-battle.firebasestorage.app",
	#"messagingSenderId": "881841128069"
#}
#
#const FIREBASE_AUTH_URL = "https://identitytoolkit.googleapis.com/v1/accounts:"
#var http_request : HTTPRequest
#
#
#
#
#func _ready():
 #
	#http_request = HTTPRequest.new()
	#add_child(http_request)
	#http_request.request_completed.connect(_on_http_request_completed)
	## 2. Tạo dữ liệu mẫu
	#var sample_data = [
		#{"email": "player1@example.com", "score": 150},
		#{"email": GLOBALS.player_email, "score": GLOBALS.enemies_killed},
		#{"email": "player2@example.com", "score": 120},
		#{"email": "player3@example.com", "score": 90}
	#]
	#
	## 3. Hiển thị leaderboard
	#display_leaderboard(sample_data)
	#
#func display_leaderboard(data: Array):
	## Xóa các dòng cũ
	#for child in vbox_container.get_children():
		#if child != $Panel/VBoxContainer/HBoxContainer:  # Giữ lại dòng tiêu đề
			#child.queue_free()
	#
	## Sắp xếp theo điểm giảm dần
	#data.sort_custom(func(a, b): return a["score"] > b["score"])
	#
	## Thêm các dòng mới
	#for i in range(data.size()):
		#var record = data[i]
		## DEBUG: In ra từng bản ghi
		#print("Record ", i, ": ", record)
		#add_leaderboard_row(i + 1, record["email"], record["score"])
#
#func prepare_leaderboard_data(display_data: Array) -> Dictionary:
	#var data_to_save = {}
	#for i in range(display_data.size()):
		#var record = display_data[i]
		#data_to_save[str(i)] = {  # Tạo key dạng "0", "1",...
			#"email": record["email"],
			#"score": record["score"],
			#"timestamp": Time.get_unix_time_from_system()  # Thêm timestamp
		#}
	#return data_to_save
#
#func save_leaderboard_to_firebase(display_data: Array):
	#print("Dữ liệu chuẩn bị gửi:", display_data)  # <-- Thêm dòng này
	#var data_to_save = {"scores": display_data}
	## Chuẩn bị dữ liệu
	##var data_to_save = {}
	#for i in range(display_data.size()):
		#data_to_save["player_"+str(i)] = display_data[i]  # Tạo key riêng cho mỗi người chơi
	#
		#print("Cấu trúc dữ liệu:", data_to_save)  # Debug
		#var json_data = JSON.stringify(data_to_save)
#
#
	#var leaderboard_data = prepare_leaderboard_data(display_data)
	#var json_data = JSON.stringify(leaderboard_data)
	#
	## Tạo URL endpoint (thay YOUR_PATH bằng path bạn muốn lưu)
	#var firebase_url = FIREBASE_CONFIG["databaseURL"] + "/leaderboard.json?auth=" + Firebase.Auth.auth.idtoken
	#
	## Thiết lập headers
	#var headers = ["Content-Type: application/json"]
	#
	## Gửi request PUT để ghi đè dữ liệu
	#http_request.request(firebase_url, headers, HTTPClient.METHOD_PUT, json_data)
	#
#func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	#print("Response code:", response_code)
	#print("Response body:", body.get_string_from_utf8())
	#if response_code == 200:
		#print("Lưu leaderboard thành công!")
		#var response = body.get_string_from_utf8()
		#print("Firebase response: ", response)
	#else:
		#push_error("Lỗi khi lưu leaderboard: ", response_code)
		#print(body.get_string_from_utf8())
	#
#func add_leaderboard_row(rank: int, email: String, score: int):
	#print("Adding row - Rank:", rank, " Email:", email, " Score:", score)  # Debug
	#
	#var hbox = HBoxContainer.new()
	#hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#
	## Tạo và cấu hình các Label
	#var rank_label = Label.new()
	#rank_label.text = str(rank) + "."
	#rank_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#
	#var email_label = Label.new()
	#email_label.text = str(email)  # Đảm bảo chuyển thành string
	#email_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#
	#var score_label = Label.new()
	#score_label.text = str(score)
	#score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#
	## Thêm vào container
	#hbox.add_child(rank_label)
	#hbox.add_child(email_label)
	#hbox.add_child(score_label)
	#
	## Highlight người chơi hiện tại
	#if email == GLOBALS.player_email:
		#hbox.add_theme_color_override("font_color", Color.YELLOW)
		#email_label.add_theme_font_size_override("font_size", 25)
	#
	#vbox_container.add_child(hbox)
