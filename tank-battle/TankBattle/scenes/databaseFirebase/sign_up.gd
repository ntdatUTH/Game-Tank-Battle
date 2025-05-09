extends Control

# Firebase configuration
const FIREBASE_CONFIG = {
	"apiKey": "AIzaSyC_C33LbHn4tn9PTVZwYWJjqKPPqbRCkS0",
	"authDomain": "game-tank-battle.firebaseapp.com",
	"databaseURL": "https://game-tank-battle-default-rtdb.firebaseio.com",
	"projectId": "game-tank-battle",
	"storageBucket": "game-tank-battle.firebasestorage.app",
	"messagingSenderId": "881841128069"
}

const FIREBASE_AUTH_URL = "https://identitytoolkit.googleapis.com/v1/accounts:"

@onready var email_input = %EmailLineEdit
@onready var password_input = %PaswordLineEdit
@onready var confirm_password_input = %PasswordLineEdit2
@onready var sign_up_button = %SignUpButton
@onready var state_label = %StateLabel
@onready var http_request = %HTTPRequest
@onready var login_container = %VBoxContainer

func _ready() -> void:
	http_request.request_completed.connect(_on_http_request_completed)
	sign_up_button.pressed.connect(_on_sign_up_button_pressed)
	login_container.visible = false 
	
func _on_sign_up_button_pressed() -> void:
	var email = email_input.text
	var password = password_input.text
	var confirm_password = confirm_password_input.text
	
	# Validate input
	if email.is_empty() or password.is_empty() or confirm_password.is_empty():
		state_label.text = "Vui lòng điền đầy đủ thông tin"
		return
	
	if password != confirm_password:
		state_label.text = "Mật khẩu không khớp!"
		return
	
	if password.length() < 6:
		state_label.text = "Mật khẩu phải có ít nhất 6 ký tự"
		return
	
	state_label.text = "Đang đăng ký..."
	_register_user(email, password)

func _register_user(email: String, password: String) -> void:
	var url = FIREBASE_AUTH_URL + "signUp?key=" + FIREBASE_CONFIG["apiKey"]
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"email": email,
		"password": password,
		"returnSecureToken": true
	})
	
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		state_label.text = "Lỗi kết nối đến Firebase"

func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var response = JSON.parse_string(body.get_string_from_utf8())
	
	if response == null:
		state_label.text = "Lỗi phản hồi từ server"
		return
	
	if response_code == 200:
		if response.has("idToken"):
			var auth_data = {
				"local_id": response.get("localId", ""),
				"id_token": response.get("idToken", ""),
				"email": response.get("email", "")
			}
			_on_signup_success(auth_data)
	else:
		var error_message = response.get("error", {}).get("message", "Lỗi không xác định")
		_on_signup_failed(response_code, error_message)


func _on_signup_success(auth_data: Dictionary) -> void:
	state_label.text = "Đăng ký thành công!"
	
	# Lưu thông tin đăng nhập (kiểm tra đúng cách)
	if Firebase != null && Firebase.Auth != null:
		Firebase.Auth.save_auth(auth_data)
	else:
		push_error("Firebase Auth module not loaded")
	
	# Gửi email và đợi hoàn thành
	await _send_email_verification(auth_data["id_token"])
	
	# Delay để hiển thị thông báo
	await get_tree().create_timer(1.5).timeout
	
	# Chuyển cảnh (kiểm tra file tồn tại)
	get_tree().change_scene_to_file("res://TankBattle/scenes/databaseFirebase/Authentication.tscn")


func _on_login_button_pressed() -> void:
	get_tree().change_scene_to_file("res://TankBattle/scenes/databaseFirebase/Authentication.tscn")
func _on_signup_failed(error_code: int, message: String) -> void:
	# Kiểm tra nếu email đã tồn tại
	if "EMAIL_EXISTS" in message:
		%StateLabel.text = "Bạn đã đăng ký với email này rồi!"
		login_container.visible = true 
	elif "INVALID_EMAIL" in message:
		%StateLabel.text = "Email không hợp lệ"
	elif "WEAK_PASSWORD" in message:
		%StateLabel.text = "Mật khẩu phải có ít nhất 6 ký tự"
	else:
		%StateLabel.text = "Đăng ký thất bại (Mã lỗi: %d)" % error_code
	
	print("Firebase Error - Code:", error_code, "| Message:", message)
func _send_email_verification(id_token: String) -> void:
	var url = FIREBASE_AUTH_URL + "sendOobCode?key=" + FIREBASE_CONFIG["apiKey"]
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"requestType": "VERIFY_EMAIL",
		"idToken": id_token
	})
	
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		print("Lỗi khi gửi email xác thực")
