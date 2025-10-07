extends CharacterBody2D


class_name GoalPostBody


var collision: CollisionShape2D
var sprite: AnimatedSprite2D
var area: Area2D

var animation_finished:bool=false

func _on_animation_finished():
	print("finishAnim")
	animation_finished=true

func opening_anim():

	if sprite != null:
		sprite.play("Opening")
		# Esperar a que termine la animación de apertura
		await sprite.animation_finished
		# Cambiar a la animación de puerta abierta
		sprite.play("DoorOpen")

func closing_anim():
	
	if sprite != null:
		sprite.play("Closing")
		# Esperar a que termine la animación de apertura
		await sprite.animation_finished
		# Cambiar a la animación de puerta abierta
		sprite.play("DoorClosed")


func _ready():
	for child in get_children():
		if child is CollisionShape2D:
			collision = child
		elif child is AnimatedSprite2D:
			sprite = child
		elif child is Area2D:
			area = child
	if !sprite:
		sprite.animation_finished.connect(_on_animation_finished)
	#Inicialmente desactivar manualmente
	sprite.play("DoorClosed")
	collision.disabled = false
	area.monitoring = false
	sprite.visible = true


func activate():
	#Abrir puerta
	opening_anim()

	#Dejar pasar al jugador
	#Pero detectarlo
	collision.disabled = true
	area.monitoring = true
	sprite.visible = true

func deactivate():
	#Cerrar puerta
	closing_anim()
	#No dejar pasar al jugador
	#Ni detectarlo
	collision.disabled = false
	area.monitoring = false
	sprite.visible = true
	
