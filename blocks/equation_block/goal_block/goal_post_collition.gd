extends CharacterBody2D


class_name GoalPostCollision


var collision: CollisionShape2D
var sprite: AnimatedSprite2D
var area: Area2D


func _ready():
	for child in get_children():
		if child is CollisionShape2D:
			collision = child
		elif child is AnimatedSprite2D:
			sprite = child
		elif child is Area2D:
			area = child


func activate():

	#Cambiar modulacion para ponerlo en gris
	sprite.modulate = Color(0.5, 0.5,0.5)

	#No dejar pasar al jugador
	#Ni detectarlo
	collision.disabled = false
	area.monitoring = false
	area.monitorable = false
	sprite.visible = true

func deactivate():

	#Cambiar modulacion para ponerlo con color
	sprite.modulate = Color(1, 1,1)

	#Dejar pasar al jugador
	#Pero detectarlo
	collision.disabled = true
	area.monitoring = true
	area.monitorable = true
	sprite.visible = true
