extends Node2D

var peer = ENetMultiplayerPeer.new()

#func _ready():
	#multiplayer.peer_disconnected.connect(_on_peer_disconnected)
#
#func _on_peer_disconnected(id):
	#print("Bạn đã bị ngắt kết nối khỏi server 1 ")
	#if id != 1:
		#print("Bạn đã bị ngắt kết nối khỏi server 2")
		#
func host_game():
	peer.create_server(3007)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	print("Đã tạo server: ", peer)
	_change_to_game_scene()

func join_game(ip: String):
	peer.create_client(ip,3007)
	multiplayer.multiplayer_peer = peer
	_change_to_game_scene()

func _change_to_game_scene():
	get_tree().change_scene_to_file("res://TankBattle/scenes/Maps/map_05.tscn")

func _on_peer_connected(id):
	print("Người chơi kết nối với ID: ", id)
	# Khi có client mới, server gửi danh sách cập nhật
	if multiplayer.is_server():
		var all_players = []
		all_players.append_array(multiplayer.get_peers())
		BaseMap.rpc("sync_player_list", all_players)

# Thêm hàm buộc ngắt kết nối
func force_disconnect(player_id: int):
	if multiplayer.is_server():
		# Server sẽ ngắt kết nối với client này
		peer.disconnect_peer(player_id)
		print("Đã ngắt kết nối player: ", player_id)
		
		# Đồng bộ lại danh sách player cho các client còn lại
		var remaining_players = []
		remaining_players.append_array(multiplayer.get_peers())
		BaseMap.rpc("sync_player_list", remaining_players)
