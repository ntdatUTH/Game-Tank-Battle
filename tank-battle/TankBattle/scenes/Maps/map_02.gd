extends "res://TankBattle/scenes/Maps/BaseMap.gd"

func _ready():
	GLOBALS.required_kills = 20
	GLOBALS.enemies_in_level = 0
	GLOBALS.enemies_killed = 0
	GLOBALS.current_level=2
	if !GLOBALS.current_player:
		spawn_player()
	else:
		GLOBALS.load_player_state()
