extends Control
@onready var text_guide=$VBoxContainer/HuongDanButton/TextHD
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


func _on_tuy_chinh_button_pressed() -> void:
	get_tree().change_scene_to_file("res://TankBattle/scenes/Skins/skin_menu.tscn")
func _on_CampaignButton_pressed():
	GLOBALS.set_game_mode(GLOBALS.GameMode.CAMPAIGN)

	get_tree().change_scene_to_file(GLOBALS.levels[1])

func _on_EndlessButton_pressed():
	GLOBALS.set_game_mode(GLOBALS.GameMode.ENDLESS)
	get_tree().change_scene_to_file(GLOBALS.endless_map)
func _on_button_HD_pressed():
	# Chuyển trạng thái ẩn/hiện
	text_guide.visible = !text_guide.visible


func _on_rank_button_pressed() -> void:
	get_tree().change_scene_to_file("res://TankBattle/scenes/rank/Rank.tscn")
	
