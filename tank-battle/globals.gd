extends Node

var slow_terrain = [
	Vector2i(1,10),
	Vector2i(20,6),
]
enum GameMode {
	CAMPAIGN,  # Chế độ vượt map level
	ENDLESS    # Chế độ bất tận
}
var current_game_mode: GameMode = GameMode.CAMPAIGN
var player_state:Dictionary={}
var current_player:Node=null
var current_level = 0
var levels = [
	"res://TankBattle/scenes/UI/title_screen.tscn",
	"res://TankBattle/scenes/Maps/map_01.tscn",
	"res://TankBattle/scenes/Maps/map_02.tscn",
	"res://TankBattle/scenes/Maps/map_03.tscn"
]
var endless_map = "res://TankBattle/scenes/Maps/map_04.tscn"
var enemies_in_level:=0
var enemies_killed:=0
var required_kills:=0
func set_game_mode(mode: GameMode):
	current_game_mode = mode
	if mode == GameMode.ENDLESS:
		required_kills = 999999
func start_endless_mode():
	set_game_mode(GameMode.ENDLESS)
	enemies_killed = 0  # Reset điểm số
	enemies_in_level = 0
	get_tree().change_scene_to_file(endless_map)
func restart():
	current_level = 0
	enemies_killed = 0  # Reset điểm số
	enemies_in_level = 0
	get_tree().change_scene_to_file(levels[current_level])

func next_level():
	if current_game_mode == GameMode.ENDLESS:
		return
	current_level += 1
	
	if current_level < levels.size():
		get_tree().change_scene_to_file(levels[current_level])
	else:
		restart()
func register_enemy():
	enemies_in_level+=1
func enemy_killed():
	enemies_killed+=1
	if current_game_mode == GameMode.CAMPAIGN and enemies_killed >= required_kills:
		next_level()
func save_player_state():
	if current_player and current_player.has_method("save_state"):
		player_state=current_player.save_state()
func load_player_state():
	if current_player and current_player.has_method("load_state")and player_state:
		current_player.load_state(player_state)
