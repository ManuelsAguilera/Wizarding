extends CharacterBody2D

@onready var sprite:AnimatedSprite2D = $PlayerSprite
@onready var magicParticle:CPUParticles2D = $MagicParticle
@onready var nearRay:RayCast2D =$NearRay
@onready var farRay:RayCast2D = $FarRay
#Siguiendo el tutorial de movimiento de pokemon

const Tile_Size:Vector2 = Vector2(64,64)
const WALKSPEED = 4.0

var initial_position = Vector2()
var is_moving=false
var cannot_move=false #Para paredes y objetos


var detected_block:GenericBlock=null

var percent_moved = 0.0
var direction:Vector2 = Vector2()
var facedDirection:Vector2 = Vector2(0,1)


func snap_to_grid():
	#Revisar si ya esta snapped pq sino se bugea
	var snapped_pos = global_position.snapped(Tile_Size)

	if global_position == snapped_pos:
		return
	else:
		global_position = snapped_pos+ Vector2(1,-1)*Tile_Size/2
		

func _ready():
	snap_to_grid()
	initial_position = global_position
	


func get_direction():
	if is_moving:
		return # No tomar input si está moviéndose
	direction = Vector2.ZERO
	if Input.is_action_pressed("up"):
		direction.y = -1
	elif Input.is_action_pressed("down"):
		direction.y = 1
	elif Input.is_action_pressed("left"):
		direction.x = -1
	elif Input.is_action_pressed("right"):
		direction.x = 1
	
	if direction != Vector2.ZERO:
		facedDirection=direction
		is_moving = true
		percent_moved = 0.0
		initial_position = global_position


func chooseSprite() -> void:
	# No sobrescribir direction aquí
	if direction.y == -1:
		sprite.flip_h = false
		sprite.play("BackWalk")
	elif direction.y == 1:
		sprite.flip_h = false
		sprite.play("FrontWalk")
	elif direction.x == -1:
		sprite.flip_h = true
		sprite.play("SideWalk")
	elif direction.x == 1:
		sprite.flip_h = false
		sprite.play("SideWalk")
	else:
		sprite.stop()

func changeRayDirection():
	if direction == Vector2.ZERO:
		return
	nearRay.target_position = direction * Tile_Size
	farRay.target_position = direction * Tile_Size*2
	
func checkRayCast():
	var collider  = nearRay.get_collider()
	
	if collider == null:
		detected_block=null
		cannot_move=false
		return

	#si no he visto bloques, y es tipo bloque
	if (collider is GenericBlock) and (collider != null):

		detected_block = collider
	
	else:
		detected_block = null
	
	cannot_move=true

	is_moving=false


func _physics_process(delta):
	chooseSprite()

	if not is_moving:
		get_direction()
		changeRayDirection()
		checkRayCast()
	if is_moving and direction != Vector2.ZERO:
		# Si hay bloque detectado y no está moviéndose, empuja el bloque
		if detected_block != null and detected_block.is_block_moving():
			# Espera a que el bloque termine de moverse
			return
		checkRayCast()
		move(delta)
	else:
		is_moving=false


func move(delta):
	percent_moved += WALKSPEED * delta

	if percent_moved >= 1:
		global_position = initial_position + (Tile_Size * direction)
		is_moving = false
		direction = Vector2.ZERO
		percent_moved = 0.0
	


# Logic

func _process(delta):	
	if (Input.is_action_just_pressed("primary") and is_moving==false):
		magicParticle.emitting=false
		magicParticle.emitting=true

		if detected_block != null and not detected_block.is_block_moving():
			farRay.add_exception(detected_block)
			farRay.force_raycast_update() 
			
			if !farRay.is_colliding():
				detected_block.push(facedDirection)
			print("block pushed")
			farRay.remove_exception(detected_block)