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
@rpc("any_peer", "reliable") 
func restart():
	if multiplayer.multiplayer_peer == null:
		current_level = 0
		print("Nhận lệnh restart từ server")
		get_tree().change_scene_to_file(levels[current_level])

func next_level():
	current_level += 1
	if current_level < levels.size():
		get_tree().change_scene_to_file(levels[current_level])
	else:
		restart()
