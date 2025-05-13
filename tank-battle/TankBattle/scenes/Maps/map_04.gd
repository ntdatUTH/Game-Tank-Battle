extends "res://TankBattle/scenes/Maps/BaseMap.gd"

func _ready():
	# Chỉ chạy khi OFFLINE (không có kết nối multiplayer)
	print(multiplayer.multiplayer_peer)
	if multiplayer.multiplayer_peer == null or multiplayer.multiplayer_peer.get_class() == "OfflineMultiplayerPeer":
		print("add player")
		spawn_player(1)  # Dùng ID mặc định (ví dụ: 1) cho offline
		# Nếu là chế độ bất tận, kích hoạt spawner
		if GLOBALS.current_game_mode == GLOBALS.GameMode.ENDLESS:
			start_endless_mode()
