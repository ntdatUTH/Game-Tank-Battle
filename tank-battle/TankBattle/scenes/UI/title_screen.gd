extends Control

func _ready():
	$Map1Button.connect("pressed", Callable(NetworkManager, "host_game"))
	$Map2Button.connect("pressed", Callable(self, "_on_join_game"))


func _on_Map01Button_pressed():
	GLOBALS.current_level = 0
	GLOBALS.next_level()

func _on_Map02Button_pressed():
	GLOBALS.current_level = 1
	GLOBALS.next_level()

func _on_join_game():
	var ip = $inputIP.text.strip_edges()
	if ip.is_empty():
		ip = "localhost"  # Giá trị mặc định nếu không nhập gì
	NetworkManager.join_game(ip)
