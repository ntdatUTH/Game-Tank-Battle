extends "res://TankBattle/scenes/Maps/BaseMap.gd"

func _ready():
	if multiplayer.multiplayer_peer == null:
		return
	
	# Chờ network sẵn sàng
	await get_tree().create_timer(0.1).timeout
	
	# Server sẽ gửi danh sách player đầy đủ cho client mới
	if multiplayer.is_server():
		# Thêm tất cả player hiện có (bao gồm cả server)
		var all_players = []
		all_players.append_array(multiplayer.get_peers())
		for id in all_players:
			add_player.rpc(id)
	else:
		# Client yêu cầu danh sách player từ server
		rpc_id(1, "request_player_list")
