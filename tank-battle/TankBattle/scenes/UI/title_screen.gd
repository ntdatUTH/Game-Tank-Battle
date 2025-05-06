extends Control
func _input(event):
	if event.is_action_pressed("ui_select"):
		GLOBALS.next_level()


func _on_logout_button_pressed() -> void:
	Firebase.Auth.logout()
	get_tree().change_scene_to_file("res://TankBattle/scenes/databaseFirebase/Authentication.tscn")
	pass # Replace with function body.
