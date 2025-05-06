extends Node

var slow_terrain = [
	Vector2i(1,10),
	Vector2i(20,6),
]
var current_level = 0
var levels = [
	"res://TankBattle/scenes/UI/title_screen.tscn",
	"res://TankBattle/scenes/Maps/map_01.tscn",
	"res://TankBattle/scenes/Maps/map_02.tscn"
]

func restart():
	current_level = 0
	get_tree().change_scene_to_file(levels[current_level])

func next_level():
	current_level += 1
	if current_level < levels.size():
		get_tree().change_scene_to_file(levels[current_level])
	else:
		restart()
