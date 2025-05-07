extends Node
  # Gán từ editor hoặc load bằng code

func _ready():
	# Tạo spawn points
	for i in 4:
		var spawn = Marker2D.new()
		spawn.add_to_group("spawn_points")
		spawn.position = Vector2(randf_range(100, 900), randf_range(100, 500))
		add_child(spawn)
	
	# Kết nối signals
	NetworkManager.multiplayer.peer_connected.connect(NetworkManager._on_player_connected)
	NetworkManager.multiplayer.peer_disconnected.connect(NetworkManager._on_player_disconnected)

func set_camera_limits(player):
	if not has_node("Ground") or not player.has_node("Camera2D"):
		push_error("Thiếu Ground hoặc Camera2D")
		return

	var ground = $Ground
	var camera = player.get_node("Camera2D")
	var map_limits = ground.get_used_rect()
	var tile_size = ground.tile_set.tile_size

	camera.limit_left = int(map_limits.position.x * tile_size.x)
	camera.limit_right = int(map_limits.end.x * tile_size.x)
	camera.limit_top = int(map_limits.position.y * tile_size.y)
	camera.limit_bottom = int(map_limits.end.y * tile_size.y)
