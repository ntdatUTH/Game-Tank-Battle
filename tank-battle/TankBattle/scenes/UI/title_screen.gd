extends Control

func _ready():
	var ip = get_lan_ip()
	$LabelIP.text = "LAN IP: " + ip

func get_lan_ip() -> String:
	var ip_list = IP.get_local_addresses()
	for ip in ip_list:
		if ip.begins_with("192.168."):
			return ip
	return "Không tìm thấy IP 192.168"
	
func _on_host_pressed() -> void:
	MultiPlayer.host_game()


func _on_join_pressed() -> void:
	var ip = $IPtext.text.strip_edges()
	MultiPlayer.join_game(ip)
