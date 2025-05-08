extends Node

func _ready():
	# Tắt UI khi đã kết nối
	if get_tree().get_nodes_in_group("player").size() > 0:
		$UI.hide()
