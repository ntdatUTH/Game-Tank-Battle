extends Node

func _ready():
	set_camera_limits()
	Input.set_custom_mouse_cursor(load("res://TankBattle/kenney_top-down-tanks/PNG/Tanks/ngắm.png"),Input.CURSOR_ARROW,Vector2(16,16))
func set_camera_limits():
	# Kiểm tra node tồn tại
	if not has_node("Ground") or not has_node("Player/Camera2D"):
		push_error("Missing required nodes")
		return
	
	var ground = $Ground
	var camera = $Player/Camera2D
	
	# Lấy thông số từ TileMap
	var map_limits = ground.get_used_rect()
	var tile_size = ground.tile_set.tile_size
	
	# Thiết lập giới hạn (ép kiểu int)
	camera.limit_left = int(map_limits.position.x * tile_size.x)
	camera.limit_right = int(map_limits.end.x * tile_size.x)
	camera.limit_top = int(map_limits.position.y * tile_size.y)
	camera.limit_bottom = int(map_limits.end.y * tile_size.y)

func _on_Tank_shoot(bullet, _position, _direction):
	var b = bullet.instantiate()
	add_child(b)
	b.start(_position, _direction)

func _on_Player_dead():
	get_tree().reload_current_scene()
