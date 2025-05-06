
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
var http_request : HTTPRequest

func _ready() -> void:
	# Initialize HTTP request
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_http_request_completed)
	if Firebase.Auth.check_auth_file():
		%StateLabel.text = "Đang đăng nhập"
		get_tree().change_scene_to_file("D:/Game/Game-Tank-Battle/tank-battle/TankBattle/scenes/Maps/map_01.tscndddddd")

func _on_login_button_pressed() -> void:
	var email = %EmailLineEdit.text
	var password = %PasswordLineEdit.text
	_firebase_email_password_auth(email, password, "signInWithPassword")
	%StateLabel.text = "Đang đăng nhập"

func _on_signup_button_pressed() -> void:
	var email = %EmailLineEdit.text
	var password = %PasswordLineEdit.text
	_firebase_email_password_auth(email, password, "signUp")
	%StateLabel.text = "Đang đăng ký"

func _firebase_email_password_auth(email: String, password: String, auth_type: String) -> void:
	var url = FIREBASE_AUTH_URL + auth_type + "?key=" + FIREBASE_CONFIG["apiKey"]
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"email": email,
		"password": password,
		"returnSecureToken": true
	})
	
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		%StateLabel.text = "Lỗi kết nối"

func _on_http_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var response = JSON.parse_string(body.get_string_from_utf8())
	
	if response == null:
		push_error("Invalid response from server")
		%StateLabel.text = "Lỗi phản hồi từ server"
		return
	
	if response_code == 200:
		if response.has("idToken"):
			var auth_data = {
				"local_id": response.get("localId", ""),
				"id_token": response.get("idToken", ""),
				"email": response.get("email", "")
			}
			
			if response.get("registered", false):
				on_login_succeeded(auth_data)
			else:
				on_signup_succeeded(auth_data)
	else:
		var error_message = response.get("error", {}).get("message", "Unknown error")
		if error_message.find("EMAIL_EXISTS") != -1:
			on_singup_failed(response_code, error_message)
		else:
			on_login_failed(response_code, error_message)

func on_login_succeeded(auth):
	print(auth)
	%StateLabel.text = "Đăng nhập thành công!"
	Firebase.Auth.save_auth(auth)
	get_tree().change_scene_to_file("D:/Game/Game-Tank-Battle/tank-battle/TankBattle/scenes/Maps/map_01.tscn")

func on_signup_succeeded(auth):
	print(auth)
	%StateLabel.text = "Đăng ký thành công!"
	Firebase.Auth.save_auth(auth)
	get_tree().change_scene_to_file("res://scenes/Maps/map_01.tscn")

func on_login_failed(error_code, message):
	print(error_code)
	print(message)
	%StateLabel.text = "Đăng nhập thất bại. Lỗi: " + str(message)
	
func on_singup_failed(error_code, message):
	print(error_code)
	print(message)
	%StateLabel.text = "Đăng ký thất bại. Lỗi: " + str(message)
