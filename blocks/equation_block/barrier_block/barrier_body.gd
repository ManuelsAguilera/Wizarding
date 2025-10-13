extends CharacterBody2D


class_name BarrierBody


var collision: CollisionShape2D
var sprite: Sprite2D


func _ready():
	set_physics_process(false)
	for child in get_children():
		if child is CollisionShape2D:
			collision = child
		elif child is Sprite2D:
			sprite = child



func activate():
	# Aparecer cuando se activa
	sprite.modulate = Color(1,1,1,1)
	# Dejar pasar al jugador
	# Pero detectarlo
	collision.disabled = false

func deactivate():
	# Desaparecer al desactivar
	sprite.modulate = Color(0.7,0.9,1,0.2)
	# No dejar pasar al jugador
	# Ni detectarlo
	collision.disabled = true
	
