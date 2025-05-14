extends Control
@onready var text_guide=$VBoxContainer/HuongDanButton/TextHD
@onready var text_network = $VBoxContainer/mode2nguoiButton/VBoxNetworkMode
@onready var welcome_label = $TenEmailLabel
func _ready() -> void:
	var ip = get_lan_ip()
	$LabelIP.text = "LAN IP: " + ip
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

func get_lan_ip() -> String:
	var ip_list = IP.get_local_addresses()
	for ip in ip_list:
		if ip.begins_with("192.168."):
			return ip
	return "Không tìm thấy IP 192.168"
	
func _on_tuy_chinh_button_pressed() -> void:
	get_tree().change_scene_to_file("res://TankBattle/scenes/Skins/skin_menu.tscn")
func _on_CampaignButton_pressed():
	get_tree().change_scene_to_file(GLOBALS.levels[1])

func _on_EndlessButton_pressed():
	get_tree().change_scene_to_file(GLOBALS.endless_map)
func _on_button_HD_pressed():
	# Chuyển trạng thái ẩn/hiện
	text_guide.visible = !text_guide.visible

func _on_host_pressed() -> void:
	MultiPlayer.host_game()

func _on_join_pressed() -> void:
	var ip = $VBoxContainer/VBoxNetworkMode/HBoxNetworkMode/IPtext.text.strip_edges()
	MultiPlayer.join_game(ip)

func _on_rank_button_pressed() -> void:
	get_tree().change_scene_to_file("res://TankBattle/scenes/rank/bxh.tscn")


func _on_mode_2_nguoi_button_pressed() -> void:
	text_network.visible = !text_network.visible
