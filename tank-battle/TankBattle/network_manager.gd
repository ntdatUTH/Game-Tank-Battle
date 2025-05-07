extends Node

const PORT = 3004
const MAX_PLAYERS = 4

var peer = ENetMultiplayerPeer.new()
var players = {}

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)

func host_game():
	var err = peer.create_server(PORT, MAX_PLAYERS)
	if err != OK:
		print("Lỗi khởi tạo server: ", err)
		return
	multiplayer.multiplayer_peer = peer
	print("Server started! Your ID: ", multiplayer.get_unique_id())

func join_game(ip_address: String = "localhost"):
	var err = peer.create_client(ip_address, PORT)
	if err != OK:
		print("Lỗi kết nối: ", err)
		return
	multiplayer.multiplayer_peer = peer
	print("Đang kết nối đến server tại: ", ip_address)

# HÀM BỊ THIẾU - BỔ SUNG NGAY ĐÂY
func _on_connected_to_server():
	print("Đã kết nối thành công đến server! ID của bạn: ", multiplayer.get_unique_id())
	# Thêm player local sau khi kết nối
	add_player(multiplayer.get_unique_id())
	print(players)


# HÀM BỊ THIẾU - BỔ SUNG NGAY ĐÂY
func _on_connection_failed():
	print("Kết nối thất bại! Kiểm tra lại IP/port hoặc firewall")
	# Hiển thị thông báo lỗi trên UI
	$UI/ErrorLabel.text = "Kết nối thất bại!"

func _on_player_connected(id):
	print("Player connected: ", id)
	# Gửi thông tin player hiện có cho client mới
	rpc_id(id, "sync_existing_players", players)

func _on_player_disconnected(id):
	print("Player disconnected: ", id)
	if players.has(id):
		players[id].queue_free()
		players.erase(id)

@rpc("any_peer", "call_local")
func add_player(id):
	var player_scene =load("res://TankBattle/scenes/Tanks/Player.tscn")
	var player = player_scene.instantiate()
	player.name = str(id)
	player.set_multiplayer_authority(id)
	
	var spawn_points = get_tree().get_nodes_in_group("spawn_points")
	#player.global_position = spawn_points[randi() % spawn_points.size()].global_position
	player.global_position = Vector2(100, 100)
	# ✅ KẾT NỐI TÍN HIỆU
	if player.has_signal("shoot_"):
		player.shoot_.connect(GameManager._on_Tank_shoot)

	if player.has_signal("dead"):
		player.dead.connect(GameManager._on_Player_dead)
		get_node("/root/Map01").add_child(player)
	var hud = load("res://TankBattle/scenes/UI/hud.tscn")
	var hud_instance = hud.instantiate()
	hud_instance.name = "HUD"
	get_node("/root/Map01").add_child(hud_instance)  # Thêm vào node bạn muốn
	var hud_node = get_node("/root/Map01/HUD")
	player.ammo_changed.connect(hud_node.update_ammo)
	player.health_changed.connect(hud_node.update_healthbar)
	players[id] = player
	
	if id == multiplayer.get_unique_id():
		player.setup_local_player()

func spawn_player():
	var player_scene =load("res://TankBattle/scenes/Tanks/Player.tscn")

	var player = player_scene.instantiate()

	# Đặt vị trí
	player.global_position = Vector2(100, 100)

	# ✅ KẾT NỐI TÍN HIỆU
	if player.has_signal("shoot_"):
		player.shoot_.connect(GameManager._on_Tank_shoot)

	if player.has_signal("dead"):
		player.dead.connect(GameManager._on_Player_dead)
		get_node("/root/Map01").add_child(player)
	var hud = load("res://TankBattle/scenes/UI/hud.tscn")
	var hud_instance = hud.instantiate()
	hud_instance.name = "HUD"
	get_node("/root/Map01").add_child(hud_instance)  # Thêm vào node bạn muốn
	var hud_node = $HUD
	player.ammo_changed.connect(hud_node.update_ammo)
	player.health_changed.connect(hud_node.update_healthbar)

@rpc("any_peer")
func sync_existing_players(existing_players: Dictionary):
	# Đồng bộ player đã có từ server
	for player_id in existing_players:
		if not players.has(player_id) and player_id != multiplayer.get_unique_id():
			add_player(player_id)

func _process(delta):
	if not multiplayer.is_server(): return
	
	# Đồng bộ vị trí các player
	for id in players:
		var player = players[id]
		player.sync_position.rpc(player.global_position, player.rotation)
