extends Control

func _on_CampaignButton_pressed():
	GLOBALS.set_game_mode(GLOBALS.GameMode.CAMPAIGN)
	# Chuyển cảnh trước khi xóa
	print("Campaign mode selected")

	get_tree().change_scene_to_file(GLOBALS.levels[0])
	

func _on_EndlessButton_pressed():
	GLOBALS.set_game_mode(GLOBALS.GameMode.ENDLESS)
	# Chuyển cảnh trước khi xóa
	get_tree().change_scene_to_file(GLOBALS.endless_map)
