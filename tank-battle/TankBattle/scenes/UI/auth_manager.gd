extends Node


# Biến lưu thông tin người dùng
var current_user_email := ""
var current_username := ""
var is_logged_in := false
var firebase_token := ""

# Hàm khởi tạo Firebase
func initialize_firebase():
	var config = {
		"apiKey": "AIzaSyC_C33LbHn4tn9PTVZwYWJjqKPPqbRCkS0",
		"authDomain": "game-tank-battle.firebaseapp.com",
		"databaseURL": "https://game-tank-battle-default-rtdb.firebaseio.com",
		"projectId": "game-tank-battle",
		"storageBucket": "game-tank-battle.firebasestorage.app",
		"messagingSenderId": "881841128069"
	}
	Firebase.initialize(config, get_script().get_path().get_base_dir())

# Hàm xử lý đăng nhập
func login_with_email(email: String, password: String) -> void:
	var url = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=" + Firebase.config.apiKey
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"email": email,
		"password": password,
		"returnSecureToken": true
	})
	
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_login_completed)
	http_request.request(url, headers, HTTPClient.METHOD_POST, body)

func _on_login_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, token: String, user_data: Dictionary, is_connected: bool):
	var response = JSON.parse_string(body.get_string_from_utf8())
	
	if response_code == 200:
		current_user_email = response.get("email", "")
		current_username = current_user_email.split("@")[0]
		firebase_token = response.get("idToken", "")
		is_logged_in = true
		
		# Luôn cập nhật GLOBALS khi login thành công
		GLOBALS.firebase_token = token
		GLOBALS.user_data = user_data
		GLOBALS.is_connected = true
		print("Đã lưu thông tin đăng nhập vào Global!")
		emit_signal("login_success")
	else:
		GLOBALS.is_connected = false
		printerr("Đăng nhập Firebase thất bại!")
		emit_signal("login_failed", response.get("error", {}).get("message", "Unknown error"))

# Hàm kiểm tra trạng thái đăng nhập
func check_auth_status() -> bool:
	return is_logged_in
# hàm lưu điểm số
func save_score_to_leaderboard(score: int):
	if Firebase.Auth.get_jwt_token().is_empty():
		return
	
	var user_data = {
		"email": current_user_email,
		"score": score
	}
	
	Firebase.Database.set(
		"leaderboard/%s" % Firebase.Auth.get_user_id(),
		user_data
	)
# Hàm đăng xuất
func logout():
	current_user_email = ""
	current_username = ""
	firebase_token = ""
	is_logged_in = false
