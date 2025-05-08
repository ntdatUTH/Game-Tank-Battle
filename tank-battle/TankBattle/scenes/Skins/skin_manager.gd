class_name skin_manager

extends Node

@export var raw_body_textures: Array[Texture2D] = [
	preload("res://TankBattle/kenney_top-down-tanks-redux/PNG/Retina/tankBody_bigRed.png"),
	preload("res://TankBattle/kenney_top-down-tanks-redux/PNG/Retina/tankBody_green.png"),
	preload("res://TankBattle/kenney_top-down-tanks-redux/PNG/Retina/tankBody_huge.png"),
	preload("res://TankBattle/kenney_top-down-tanks-redux/PNG/Retina/tankBody_red.png")
]

@export var raw_turret_textures: Array[Texture2D] = [
	preload("res://TankBattle/kenney_top-down-tanks-redux/PNG/Retina/tankDark_barrel2.png"),
	preload("res://TankBattle/kenney_top-down-tanks-redux/PNG/Retina/tankGreen_barrel1.png"),
	preload("res://TankBattle/kenney_top-down-tanks-redux/PNG/Retina/tankRed_barrel1.png"),
	preload("res://TankBattle/kenney_top-down-tanks-redux/PNG/Retina/tankSand_barrel1.png")
]

# Kích thước mong muốn
const BODY_SIZE := Vector2i(76, 72)
const BARREL_SIZE := Vector2i(16, 52)

var ListBody: Array[Texture2D] = []
var ListTurret: Array[Texture2D] = []

signal skin_changed(body_texture: Texture2D, barrel_texture: Texture2D)
var current_body_index: int = 0:
	set(value):
		current_body_index = wrapi(value, 0, ListBody.size())
		GlobalSettings.current_body_index = current_body_index
		GlobalSettings.save_settings()
		skin_changed.emit(get_current_body_skin(), get_current_barrel_skin())

var current_barrel_index: int = 0:
	set(value):
		current_barrel_index = wrapi(value, 0, ListTurret.size())
		GlobalSettings.current_barrel_index = current_barrel_index
		GlobalSettings.save_settings()
		skin_changed.emit(get_current_body_skin(), get_current_barrel_skin())

func _ready():
	# Resize tất cả texture khi khởi động
	process_textures()

# Hàm resize texture
func resize_texture(texture: Texture2D, target_size: Vector2i) -> Texture2D:
	var img := texture.get_image()
	img.resize(target_size.x, target_size.y, Image.INTERPOLATE_LANCZOS)  # Hoặc INTERPOLATE_NEAREST nếu là pixel art
	var new_texture := ImageTexture.create_from_image(img)
	return new_texture

# Xử lý resize tất cả texture
func process_textures():
	ListBody.clear()
	ListTurret.clear()
	
	for tex in raw_body_textures:
		ListBody.append(resize_texture(tex, BODY_SIZE))
	
	for tex in raw_turret_textures:
		ListTurret.append(resize_texture(tex, BARREL_SIZE))

# Các hàm còn lại giữ nguyên
func get_current_body_skin() -> Texture2D:
	return ListBody[current_body_index] if ListBody.size() > 0 else null

func get_current_barrel_skin() -> Texture2D:
	return ListTurret[current_barrel_index] if ListTurret.size() > 0 else null

func next_body_skin():
	current_body_index += 1

func prev_body_skin():
	current_body_index -= 1

func next_barrel_skin():
	current_barrel_index += 1

func prev_barrel_skin():
	current_barrel_index -= 1

func select_combo(index_body: int, index_barrel: int):
	select_body_skin(index_body)
	select_barrel_skin(index_barrel)

func select_body_skin(index: int):
	if index >= 0 && index < ListBody.size():
		current_body_index = index

func select_barrel_skin(index: int):
	if index >= 0 && index < ListTurret.size():
		current_barrel_index = index
