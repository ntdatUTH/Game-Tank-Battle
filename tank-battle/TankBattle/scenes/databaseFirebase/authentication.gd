extends Control
# Thêm vào đầu script
const SAVE_PATH = "user://login_settings.cfg"  # File sẽ lưu trong thư mục appdata/local
var config = ConfigFile.new()  # Đối tượng để đọc/ghi file

# Cấu hình Firebase
const FIREBASE_CONFIG = {
	"apiKey": "AIzaSyC_C33LbHn4tn9PTVZwYWJjqKPPqbRCkS0",
	"authDomain": "game-tank-battle.firebaseapp.com",
	"databaseURL": "https://game-tank-battle-default-rtdb.firebaseio.com",
	"projectId": "game-tank-battle",
	"storageBucket": "game-tank-battle.firebasestorage.app",
	"messagingSenderId": "881841128069"
}

const FIREBASE_AUTH_URL = "https://identitytoolkit.googleapis.com/v1/accounts:"
var http_request : HTTPRequest

@onready var email_input = %EmailLineEdit
@onready var password_input = %PasswordLineEdit
@onready var login_button = %LoginButton
@onready var state_label = %StateLabel
@onready var signup_container = %VBoxContainer  # Container chứa nút đăng ký
@onready var signup_button = %SignUpButton  # Nút đăng ký
@onready var remember_me_checkbox = %remember_me_checkbox

func _ready() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_http_request_completed)
	
	# Ẩn container đăng ký ban đầu
	signup_container.visible = false
	
	# Kết nối các nút bấm và checkbox
	login_button.pressed.connect(_on_login_button_pressed)
	signup_button.pressed.connect(_on_sign_up_button_pressed)
	
	
	_load_login_data()

func _on_login_button_pressed() -> void:
	var email = email_input.text.strip_edges()
	var password = password_input.text.strip_edges()
	var remember_me =remember_me_checkbox.button_pressed
	
	if email.is_empty() or password.is_empty():
		state_label.text = "Vui lòng nhập đầy đủ email và mật khẩu"
		return
	
	state_label.text = "Đang xác thực..."
	_firebase_login(email, password)
	
	# Lưu thông tin nếu chọn "Nhớ mật khẩu"
	config.set_value("login", "email", email if remember_me else "")
	config.set_value("login", "password", password if remember_me else "")  # Cảnh báo: Nên mã hóa mật khẩu!
	config.set_value("login", "remember_me", remember_me)
	config.save(SAVE_PATH)

func _firebase_login(email: String, password: String) -> void:
	var url = FIREBASE_AUTH_URL + "signInWithPassword?key=" + FIREBASE_CONFIG["apiKey"]
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"email": email,
		"password": password,
		"returnSecureToken": true
	})
	
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		state_label.text = "Lỗi kết nối đến máy chủ"

func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var response = JSON.parse_string(body.get_string_from_utf8())
	
	if response == null:
		state_label.text = "Lỗi xử lý dữ liệu từ máy chủ"
		return
	
	if response_code == 200:
		if response.has("idToken"):
			var auth_data = {
				"local_id": response.get("localId", ""),
				"id_token": response.get("idToken", ""),
				"email": response.get("email", "")
			}
			_on_login_success(auth_data)
	else:
		var error_message = response.get("error", {}).get("message", "Lỗi không xác định")
		_on_login_failed(response_code, error_message)

#sửa lại hàm này
func _on_login_success(auth_data: Dictionary) -> void:
	# Lưu thông tin auth vào Firebase.Auth
	if Firebase != null && Firebase.Auth != null:
		Firebase.Auth.save_auth(auth_data)
	
	# Lấy email từ auth_data
	var user_email = auth_data.get("email", "")
	
	# Lưu email vào cả AuthManager và GLOBALS
	AuthManager.current_user_email = user_email
	   
	
	AuthManager.current_username = AuthManager.current_user_email.split("@")[0]
	AuthManager.is_logged_in = true
	#lưu đangư nhập thành công
	GLOBALS.player_email =AuthManager.current_username
	
	
	state_label.text = "Đăng nhập thành công!"
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://TankBattle/scenes/UI/title_screen.tscn")

func _on_login_failed(error_code: int, message: String) -> void:
	if "INVALID_LOGIN_CREDENTIALS" in message:
		state_label.text = "Email hoặc mật khẩu không đúng"
		# Hiển thị container đăng ký khi thông tin đăng nhập sai
		signup_container.visible = true
	elif "TOO_MANY_ATTEMPTS" in message:
		state_label.text = "Thử lại sau ít phút"
	else:
		state_label.text = "Lỗi đăng nhập: " + message
	
	print("Chi tiết lỗi [", error_code, "]: ", message)

func _on_sign_up_button_pressed() -> void:
	get_tree().change_scene_to_file("res://TankBattle/scenes/databaseFirebase/SignUp.tscn")
	



func _load_login_data():
	var err = config.load(SAVE_PATH)
	if err == OK:  # Nếu file tồn tại
		var remember_me = config.get_value("login", "remember_me", false)
		if remember_me:
			email_input.text = config.get_value("login", "email", "")
			password_input.text = config.get_value("login", "password", "")
			remember_me_checkbox.button_pressed = true
