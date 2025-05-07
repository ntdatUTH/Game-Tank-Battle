extends Node

func _on_Player_dead():
	GLOBALS.restart()

func _on_Tank_shoot(bullet, _position, _direction, _target = null):
	var b = bullet.instantiate()
	add_child(b)
	b.start(_position, _direction, _target)
