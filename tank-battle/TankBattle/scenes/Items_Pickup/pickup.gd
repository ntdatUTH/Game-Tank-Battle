extends Area2D

enum Items {health, ammo}
var icon_textures = [
	preload("res://TankBattle/kenney_top-down-tanks-redux/Pickup/icon_pin-Photoroom.png"),
	preload("res://TankBattle/kenney_top-down-tanks-redux/Pickup/dantrang.png")
]
@export var type: Items = Items.health
@export var amount: Vector2 = Vector2(10, 25)
@export var respawn_time_range: Vector2 = Vector2(30, 60)  # Min 30s, Max 60s

var respawn_timer: Timer

func _ready():
	update_icon()
	# Tạo timer cho respawn
	respawn_timer = Timer.new()
	respawn_timer.one_shot = true
	add_child(respawn_timer)

func update_icon():
	$"IconPin-photoroom".texture = icon_textures[type]

func _on_body_entered(body: Node) -> void:
	match type:
		Items.health:
			if body.has_method("heal"):
				print("healing")
				body.heal(randi_range(int(amount.x), int(amount.y)))
		Items.ammo:
			body.ammo += int(randi_range(amount.x, amount.y))
	
	# Ẩn item thay vì xóa
	hide()
	set_deferred("monitoring", false)
	
	# Bắt đầu đếm ngược để respawn
	var respawn_time = randf_range(respawn_time_range.x, respawn_time_range.y)
	respawn_timer.start(respawn_time)
	respawn_timer.timeout.connect(_respawn_item)

func _respawn_item():
	# Hiển thị lại item
	show()
	set_deferred("monitoring", true)
	# Ngắt kết nối signal để tránh bị gọi nhiều lần
	respawn_timer.timeout.disconnect(_respawn_item)
