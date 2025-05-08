extends Control

@onready var welcome_label = $TenEmailLabel
func _ready() -> void:
	if AuthManager.check_auth_status():
		welcome_label.text = "Xin chào, %s!" % AuthManager.current_username
	else:
		get_tree().change_scene_to_file("res://TankBattle/scenes/databaseFirebase/Authentication.tscn")
func _input(event):
	if event.is_action_pressed("ui_select"):
		GLOBALS.next_level()


func _on_logout_button_pressed() -> void:
	Firebase.Auth.logout()
	get_tree().change_scene_to_file("res://TankBattle/scenes/databaseFirebase/Authentication.tscn")
	pass # Replace with function body.
