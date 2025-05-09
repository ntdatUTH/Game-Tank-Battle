extends Node

var current_body_index: int = 0
var current_barrel_index: int = 0

func save_settings() -> bool:
	var config = ConfigFile.new()
	config.set_value("skin", "body_index", current_body_index)
	config.set_value("skin", "barrel_index", current_barrel_index)
	
	var err = config.save("user://settings.cfg")

	if err != OK:
		push_error("Lỗi khi lưu cài đặt: %s" % error_string(err))
		
		return false
	return true

func load_settings() -> bool:
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	
	if err == OK:
		current_body_index = config.get_value("skin", "body_index", 0)
		current_barrel_index = config.get_value("skin", "barrel_index", 0)
		return true
	else:
		push_warning("Không tải được cài đặt: %s" % error_string(err))
		# Khởi tạo giá trị mặc định
		current_body_index = 0
		current_barrel_index = 0
		return false
