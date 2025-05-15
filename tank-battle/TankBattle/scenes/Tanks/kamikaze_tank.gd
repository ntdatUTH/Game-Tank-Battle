extends "res://TankBattle/scenes/Tanks/Tank.gd"

@export var damage: int = 0
@export var explosion_radius: float = 32.0
@export var speed: float = 40.0

var target: Node2D
var is_exploded: bool = false

func _ready():
	super._ready()
	add_to_group("Enemy")  # Nhận diện là enemy
	GLOBALS.register_enemy() 
	$Explosion.hide()

func _process(delta):
	if not target:
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			target = players[0]	
		else:
			return
	control(delta)

func control(delta):
	if not target or is_exploded:
		return
	velocity = (target.position - position).normalized() * speed
	look_at(target.position)
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player") or is_exploded:
		return
	print("Enemy collided with player")
	explode()
	if body.has_method('take_damage'):
		body.take_damage(damage)
func explode():
	if is_exploded:
		return
	is_exploded = true
	super.explode()
func take_damage(amount: int):
	if health <= 0:  # Đã chết thì bỏ qua
		return
	
	print("Tank Enemy took damage! HP:", health, " Damage:", amount)
	super.take_damage(amount)
	if health <= 0:
		die()

func die():
	print("Tank Enemy died!")
	super.explode()
	GLOBALS.enemy_killed()
	queue_free()
	
