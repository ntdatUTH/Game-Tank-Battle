extends "res://TankBattle/scenes/Tanks/Tank.gd"
@onready var body_sprite=$Body
@onready var barrel_sprite=$Turret

func _ready():
	super._ready()
	# Load settings trước khi cập nhật skin
	GlobalSettings.load_settings()
	SkinManager.current_body_index = GlobalSettings.current_body_index
	SkinManager.current_barrel_index = GlobalSettings.current_barrel_index
	
	update_skin()
	SkinManager.skin_changed.connect(_on_skin_changed)
	Input.set_custom_mouse_cursor(
		load("res://TankBattle/kenney_top-down-tanks/PNG/Tanks/ngắm.png"),
		Input.CURSOR_ARROW,
		Vector2(16, 16) # Căn giữa hình ngắm
	)
func update_skin():
	$Body.texture = SkinManager.get_current_body_skin()
	$Turret.texture = SkinManager.get_current_barrel_skin()
	print("cap nhat skin")
func _on_skin_changed(body_texture:Texture2D,barrel_texture:Texture2D):
	if body_texture:
		body_sprite.texture=body_texture
	if barrel_texture:
		barrel_sprite.texture = barrel_texture
func _physics_process(delta):
	if not alive:
		return
	
	control(delta)
	move_and_slide()  
	
	if map:
		var tile_pos = map.local_to_map(position)
		var atlas_coords = map.get_cell_atlas_coords(0, tile_pos)
		if GLOBALS.slow_terrain.has(atlas_coords):
			velocity *= offroad_friction
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
