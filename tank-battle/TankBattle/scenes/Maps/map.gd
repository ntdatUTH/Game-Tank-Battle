extends "res://TankBattle/scenes/Maps/BaseMap.gd"

func _ready():
	GLOBALS.required_kills = 10
	GLOBALS.enemies_in_level = 0
	GLOBALS.enemies_killed = 0

	if !GLOBALS.current_player:
		spawn_player()
	else:
		GLOBALS.load_player_state()
