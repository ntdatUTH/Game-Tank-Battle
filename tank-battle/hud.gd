extends CanvasLayer
var bar_red = preload("res://TankBattle/kenney_top-down-tanks/PNG/maudo.png")
var bar_green = preload("res://TankBattle/kenney_top-down-tanks/PNG/mauday.png")
var bar_yellow = preload("res://TankBattle/kenney_top-down-tanks/PNG/mauvang.png")
var bar_texture

func update_ammo(value):
	$Margin/Container/AmmoGauge.value=value


func update_healthbar(value):
	bar_texture = bar_green
	if value < 60:
		bar_texture = bar_yellow
	if value < 25:
		bar_texture = bar_red
	$Margin/Container/HealthBar.texture_progress = bar_texture
	var tween = create_tween()
	tween.tween_property(
		$Margin/Container/HealthBar, 
		"value", 
		value, 
		0.3  # Thời gian animation (giây)
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	$AnimationPlayer.play("healthbar_flash")

func _on_animation_player_animation_finished(anim_name):
	if anim_name == 'healthbar_flash':
		$Margin/Container/HealthBar.texture_progress = bar_texture
