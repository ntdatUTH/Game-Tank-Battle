extends Node

#lưu địa chỉ khi đăng nhập thành công
var firebase_token: String = ""
var user_data: Dictionary = {}
var is_connected: bool 

#lưu email
var player_email: String = ""

var slow_terrain = [
	Vector2i(1,10),
	Vector2i(20,6),
]
enum GameMode {
	CAMPAIGN,  # Chế độ vượt map level
	ENDLESS    # Chế độ bất tận
}
# Cấu trúc dữ liệu mỗi người chơi ở rank
class PlayerRecord:
	var email: String
	var score: int
	
	func _init(p_email: String, p_score: int):
		email = p_email
		score = p_score

var leaderboard_data = [
	{"email": "player1@example.com", "score": 150},
	{"email": "player2@example.com", "score": 120}
]

func add_current_player_to_leaderboard():
	if player_email != "" and enemies_killed > 0:
		leaderboard_data.append({"email": player_email, "score": enemies_killed})
		
		
		
		#tới đây là hết
		
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

var enemies_in_level: int =0
var enemies_killed: int =0 
var required_kills: int =0
var endless_score: int = 0  # Khai báo rõ kiểu int và giá trị mặc định

func set_game_mode(mode: GameMode):
	current_game_mode = mode
	if mode == GameMode.ENDLESS:
		required_kills = 999999
func start_endless_mode():
	set_game_mode(GameMode.ENDLESS)
	enemies_killed = 0  # Reset điểm số
	enemies_in_level = 0
	get_tree().change_scene_to_file(endless_map)
	
func restart(_current_level:int):
	current_level = _current_level
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
		restart(0)
func register_enemy():
	enemies_in_level+=1
func enemy_killed():
	enemies_killed+=1
	if current_game_mode == GameMode.CAMPAIGN and enemies_killed >= required_kills and current_level<levels.size()-1:
		next_level()
func save_player_state():
	if current_player and current_player.has_method("save_state"):
		player_state=current_player.save_state()
func load_player_state():
	if current_player and current_player.has_method("load_state")and player_state:
		current_player.load_state(player_state)
