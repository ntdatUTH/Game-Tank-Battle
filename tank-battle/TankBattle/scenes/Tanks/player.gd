extends "res://TankBattle/scenes/Tanks/Tank.gd"
@onready var body_sprite=$Body
@onready var barrel_sprite=$Turret

func _enter_tree() -> void:
	if multiplayer.multiplayer_peer != null && multiplayer.multiplayer_peer.get_class() != "OfflineMultiplayerPeer":
		# Online logic
		set_multiplayer_authority(name.to_int())

func _ready():
	super._ready()
	if str(name) == str(multiplayer.get_unique_id()):
		$Camera2D.make_current()
	#if not is_multiplayer_authority():  # Kiểm tra nếu không phải client local
	# Load settings trước khi cập nhật skin
	GlobalSettings.load_settings()
	SkinManager.current_body_index = GlobalSettings.current_body_index
	SkinManager.current_barrel_index = GlobalSettings.current_barrel_index
	
	update_skin()
	#SkinManager.skin_changed.connect(_on_skin_changed)
	Input.set_custom_mouse_cursor(
		load("res://TankBattle/kenney_top-down-tanks/PNG/Tanks/ngắm.png"),
		Input.CURSOR_ARROW,
		Vector2(16, 16) # Căn giữa hình ngắm
	)
	add_to_group("Player")
	
func update_skin():
	$Body.texture = SkinManager.get_current_body_skin()
	$Turret.texture = SkinManager.get_current_barrel_skin()
	print("cap nhat skin")
func _on_skin_changed(body_texture:Texture2D,barrel_texture:Texture2D):
	if body_texture:
		body_sprite.texture=body_texture
	if barrel_texture:
		barrel_sprite.texture = barrel_texture

func control(delta):
	$Turret.look_at(get_global_mouse_position())
	$Turret.rotation += deg_to_rad(-90)
	velocity = Vector2.ZERO
	var rot_dir = 0

	if Input.is_action_pressed("forward"):
		velocity += Vector2(0, -1)
	if Input.is_action_pressed("back"):
		velocity += Vector2(0, 1)
	if Input.is_action_pressed("turn_right"):
		rot_dir += 3
		velocity += Vector2(1, 0)
	if Input.is_action_pressed("turn_left"):
		rot_dir -= 3
		velocity += Vector2(-1, 0)

	if velocity.length() > 0:
		velocity = velocity.normalized() * max_speed
		rotation += rotation_speed * rot_dir * delta
		position += velocity * delta
	move_and_slide()

	if Input.is_action_just_pressed('click'):
		print("HP player: ", health)
		shoot(gun_shots, gun_spread)
func save_state() -> Dictionary:
	return {
		"health": health,
		"ammo": ammo,
		"position": global_position,
		"body_index": SkinManager.current_body_index,
		"barrel_index": SkinManager.current_barrel_index

	}

func load_state(state: Dictionary):
	health = state["health"]
	ammo = state["ammo"]
	global_position = state["position"]
	update_skin()
