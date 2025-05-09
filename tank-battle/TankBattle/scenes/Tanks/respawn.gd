extends Node2D

@export var enemy_scene: PackedScene = preload("res://TankBattle/scenes/Tanks/kamikaze_tank.tscn")
@export var spawn_interval: float = 3.0  # Thời gian giữa các lần spawn
@export var max_enemies: int = 5  # Số enemy tối đa

var current_enemies: int = 0

func _ready():
	# Tạo và bắt đầu timer
	var timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.timeout.connect(_spawn_enemy)
	add_child(timer)
	timer.start()

func _spawn_enemy():
	# Kiểm tra số lượng enemy hiện có
	if current_enemies >= max_enemies:
		return
	
	# Kiểm tra player có tồn tại không
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() == 0:
		print("Không tìm thấy player")
		return
	
	# Tạo enemy mới
	var new_enemy = enemy_scene.instantiate()
	
	# Thêm vào scene tree
	get_parent().add_child(new_enemy)
	
	# Đặt vị trí spawn (có thể random hoặc theo điểm định sẵn)
	new_enemy.global_position = global_position
	
	current_enemies += 1
	
	# Kết nối signal khi enemy bị hủy
	new_enemy.tree_exiting.connect(_on_enemy_destroyed)

func _on_enemy_destroyed():
	current_enemies -= 1
