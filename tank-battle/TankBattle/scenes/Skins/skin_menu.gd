extends Control

@onready var body_preview: TextureRect=$BodyPreview
@onready var barrel_preview: TextureRect=$BarrelPreview
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SkinManager.skin_changed.connect(_on_skin_changed)
	update_preview()
	GlobalSettings.load_settings()
	SkinManager.select_combo(GlobalSettings.current_body_index,GlobalSettings.current_barrel_index)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func _on_skin_changed(body_texture: Texture2D, barrel_texture: Texture2D):
	body_preview.texture = body_texture
	barrel_preview.texture = barrel_texture
func update_preview():
	body_preview.texture=SkinManager.get_current_body_skin()
	barrel_preview.texture=SkinManager.get_current_barrel_skin()
	print("Body texture: ", SkinManager.get_current_body_skin())
	print("Barrel texture: ", SkinManager.get_current_barrel_skin())
func _on_next_body_pressed():
	SkinManager.next_body_skin()
	GlobalSettings.current_body_index=SkinManager.current_body_index
	GlobalSettings.save_settings()
	print("nextbody")

func _on_prev_body_pressed():
	SkinManager.prev_body_skin()
	GlobalSettings.current_body_index=SkinManager.current_body_index
	GlobalSettings.save_settings()
	print("luibody")

func _on_next_barrel_pressed():
	SkinManager.next_barrel_skin()
	GlobalSettings.current_barrel_index=SkinManager.current_barrel_index
	GlobalSettings.save_settings()
	print("nextbarrel")

func _on_prev_barrel_pressed():
	SkinManager.prev_barrel_skin()
	GlobalSettings.current_barrel_index=SkinManager.current_barrel_index
	GlobalSettings.save_settings()
	print("luibarrel")
