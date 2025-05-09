extends AnimatedSprite2D

@onready var audio_player = $AudioStreamPlayer2D

func _ready():
	audio_player.stop()

	# Dùng cách này cho Godot 4 trở lên
	connect("frame_changed", self._on_frame_changed)
	connect("animation_finished", self._on_animation_finished)

func _on_frame_changed():
	if animation == "fire" or animation == "smoke" :
		audio_player.play()

func _on_animation_finished():
	audio_player.stop()
