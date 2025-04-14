extends Node2D

var bar_red = preload("res://TankBattle/kenney_top-down-tanks/PNG/maudo.png")
var bar_green = preload("res://TankBattle/kenney_top-down-tanks/PNG/mauday.png")
var bar_yellow = preload("res://TankBattle/kenney_top-down-tanks/PNG/mauvang.png")

func _ready():
	for node in get_children():
		node.hide()
func _process(delta):
	global_rotation = deg_to_rad(180)
func update_healthbar(value):
	$HealthBar.texture_progress = bar_green
	if value < 60:
		$HealthBar.texture_progress = bar_yellow
	if value < 25:
		$HealthBar.texture_progress = bar_red
	if value < 100:
		$HealthBar.show()
	$HealthBar.value = value
