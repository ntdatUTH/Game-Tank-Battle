extends Node2D

@export var enemy_scene: PackedScene = preload("res://TankBattle/scenes/Tanks/kamikaze_tank.tscn")
@export var initial_spawn_interval: float = 3.0
@export var min_spawn_interval: float = 0.5  # Khoảng cách spawn tối thiểu
@export var interval_decrease_rate: float = 0.1  # Tốc độ giảm thời gian spawn
@export var initial_max_enemies: int = 5
@export var max_enemies_increase: int = 1  # Số enemy tăng thêm mỗi lần
@export var increase_interval: float = 10.0  # Thời gian tăng độ khó (giây)

var current_max_enemies: int
var current_spawn_interval: float
var timer: Timer
var difficulty_timer: Timer

func _ready():
	current_max_enemies = initial_max_enemies
	current_spawn_interval = initial_spawn_interval
	
	# Timer spawn enemy
	timer = Timer.new()
	timer.wait_time = current_spawn_interval
	timer.timeout.connect(_spawn_enemy)
	add_child(timer)
	timer.start()
	
	# Timer tăng độ khó
	difficulty_timer = Timer.new()
	difficulty_timer.wait_time = increase_interval
	difficulty_timer.timeout.connect(_increase_difficulty)
	add_child(difficulty_timer)
	difficulty_timer.start()

func _spawn_enemy():
	if get_tree().get_nodes_in_group("Enemy").size() >= current_max_enemies:
		return
	
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() == 0:
		return
	
	var new_enemy = enemy_scene.instantiate()
	get_parent().add_child(new_enemy)
	new_enemy.global_position = global_position
	new_enemy.add_to_group("Enemy")

func _increase_difficulty():
	# Tăng số lượng enemy tối đa
	current_max_enemies += max_enemies_increase
	print("Increased max enemies to: ", current_max_enemies)
	
	# Giảm thời gian spawn (nhưng không nhỏ hơn min_spawn_interval)
	current_spawn_interval = max(current_spawn_interval - interval_decrease_rate, min_spawn_interval)
	timer.wait_time = current_spawn_interval
	print("New spawn interval: ", current_spawn_interval)
