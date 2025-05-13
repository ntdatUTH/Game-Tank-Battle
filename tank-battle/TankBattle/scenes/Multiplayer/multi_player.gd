extends Node2D

var peer = ENetMultiplayerPeer.new()

func _ready():
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_disconnected(id):
	print("Player disconnected: ", id)
	if multiplayer.is_server():
		# Server yêu cầu xóa player trên tất cả clients
		BaseMap.rpc("remove_disconnected_player", id)

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

func disconnect_game():
	#var existing_players = get_tree().get_nodes_in_group("Player")
	#for p in existing_players:
		#p.queue_free()
	if peer != null and peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("Đang ngắt kết nối...")

		# Ngắt kết nối mạng
		peer.close()
		multiplayer.multiplayer_peer = null
		peer = ENetMultiplayerPeer.new()  # Reset peer để có thể host/join lại sau
	else:
		print("Chưa kết nối hoặc đã ngắt kết nối.")
