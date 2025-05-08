extends Node

var slow_terrain = [
	Vector2i(1,10),
	Vector2i(20,6),
]
var current_player:Node=null
var current_level = 0
var levels = [
	"res://TankBattle/scenes/UI/title_screen.tscn",
	"res://TankBattle/scenes/Maps/map_01.tscn",
	"res://TankBattle/scenes/Maps/map_02.tscn"
]
func spawn_player(position:Vector2):
	if current_player:
		current_player.queue_free()
	GlobalSettings.load_settings()
	SkinManager.select_combo(GlobalSettings.current_body_index, GlobalSettings.current_barrel_index)
	var player =load("res://TankBattle/scenes/Tanks/Player.tscn").instantiate()
	get_tree().current_scene.add_child(player)
	player.global_position=position
	player.update_skin()
	
	current_player = player
	return player
func restart():
	current_level = 0
	get_tree().change_scene_to_file(levels[current_level])

func next_level():
	current_level += 1
	if current_level < levels.size():
		get_tree().change_scene_to_file(levels[current_level])
	else:
		restart()
