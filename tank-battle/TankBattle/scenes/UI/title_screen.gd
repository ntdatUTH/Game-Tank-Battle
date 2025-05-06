extends Control

func _ready():
	$Map1Button.connect("pressed", Callable(self, "_on_Map01Button_pressed"))
	$Map2Button.connect("pressed", Callable(self, "_on_Map02Button_pressed"))


func _on_Map01Button_pressed():
	GLOBALS.current_level = 0
	GLOBALS.next_level()

func _on_Map02Button_pressed():
	GLOBALS.current_level = 1
	GLOBALS.next_level()
