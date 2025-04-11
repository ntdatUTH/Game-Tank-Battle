extends CanvasLayer


@onready var main_bar = $MainBar
@onready var delay_bar = $DelayBar

var max_health = 100
var current_health = max_health

func take_damage(amount: int):
	current_health = clamp(current_health - amount, 0, max_health)

	# Cập nhật thanh máu chính
	main_bar.value = current_health

	# Hiệu ứng thanh delay tụt chậm
	var tween = create_tween()
	tween.tween_property(delay_bar, "value", current_health, 0.5)
