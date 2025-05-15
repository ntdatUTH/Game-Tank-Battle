extends "res://TankBattle/scenes/Maps/BaseMap.gd"

func _ready():
	GLOBALS.current_game_mode = GLOBALS.GameMode.ENDLESS
	if !GLOBALS.current_player:
		spawn_player(1)
	GLOBALS.required_kills = 9999999999
	GLOBALS.enemies_in_level = 0
	GLOBALS.enemies_killed = 0
