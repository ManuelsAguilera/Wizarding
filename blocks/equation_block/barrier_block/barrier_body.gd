extends CharacterBody2D


class_name BarrierBody


var collision: CollisionShape2D
var sprite: Sprite2D


func _ready():
	for child in get_children():
		if child is CollisionShape2D:
			collision = child
		elif child is Sprite2D:
			sprite = child



func activate():
	# Aparecer cuando se activa
	print("Activado barrier##########################")
	sprite.modulate = Color(1,1,1)
	# Dejar pasar al jugador
	# Pero detectarlo
	collision.disabled = true

func deactivate():
	# Desaparecer al desactivar
	print("Desactivar #####################################")
	sprite.modulate = Color(0.2,0.2,0.2)
	# No dejar pasar al jugador
	# Ni detectarlo
	collision.disabled = false

	#No dejar pasar al jugador
	#Ni detectarlo
	collision.disabled = false
	sprite.visible = true
	
