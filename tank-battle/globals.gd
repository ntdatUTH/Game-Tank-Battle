extends Node

#lưu địa chỉ khi đăng nhập thành công
var firebase_token: String = ""
var user_data: Dictionary = {}
var is_connected: bool 

#lưu email
signal player_email_changed(new_email)

var _player_email = ""
var player_email:
	get:
		return _player_email
	set(value):
		_player_email = value
		emit_signal("player_email_changed", value)
		print("[GLOBALS] Đã cập nhật player_email:", value)

var slow_terrain = [
	Vector2i(1,10),
	Vector2i(20,6),
]
enum GameMode {
	CAMPAIGN,  # Chế độ vượt map level
	ENDLESS    # Chế độ bất tận
}
var current_game_mode: GameMode = GameMode.CAMPAIGN
var player_state:Dictionary={}
var current_player:Node=null
var current_level = 0
var levels = [
	"res://TankBattle/scenes/UI/title_screen.tscn",
	"res://TankBattle/scenes/Maps/map_01.tscn",
	"res://TankBattle/scenes/Maps/map_02.tscn",
	"res://TankBattle/scenes/Maps/map_03.tscn"
]
var endless_map = "res://TankBattle/scenes/Maps/map_04.tscn"
var network_map = "res://TankBattle/scenes/Maps/map_05.tscn"
var enemies_in_level:=0
var enemies_killed:=0
var required_kills:=0
var last_score:int=0

@rpc("any_peer", "reliable") 
func restart(_current_level:int):
	print("CHẠY RESTART của GLOBALS")
	# Chỉ server mới được xử lý restart
	if not multiplayer.is_server() or multiplayer.multiplayer_peer.get_class() == "OfflineMultiplayerPeer":
		print("BẮT ĐẦU RESTART")
		current_level = _current_level
		enemies_killed = 0  # Reset điểm số
		enemies_in_level = 0
		if current_level == 5:
			BaseMap.rpc_id(1, "request_player_list")
		else:
			if multiplayer.multiplayer_peer != null && multiplayer.multiplayer_peer.get_class() != "OfflineMultiplayerPeer":
				MultiPlayer.disconnect_game()
			get_tree().change_scene_to_file(levels[current_level])

func next_level():
	if current_game_mode == GameMode.ENDLESS:
		return
	current_level += 1
	
	if current_level < levels.size():
		get_tree().change_scene_to_file(levels[current_level])
	else:
		restart(0)
func register_enemy():
	enemies_in_level+=1
func enemy_killed():
	enemies_killed+=1
	if current_game_mode == GameMode.CAMPAIGN and enemies_killed >= required_kills and current_level<levels.size()-1:
		next_level()
func save_player_state():
	if current_player and current_player.has_method("save_state"):
		player_state=current_player.save_state()
func load_player_state():
	if current_player and current_player.has_method("load_state")and player_state:
		current_player.load_state(player_state)
