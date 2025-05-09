extends "res://TankBattle/scenes/Maps/BaseMap.gd"



func _input(event):
	if event.is_action_pressed("quit_game"):
		get_tree().change_scene_to_file("res://TankBattle/scenes/UI/title_screen.tscn")
