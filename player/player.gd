extends CharacterBody2D


class_name Player

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
	# Verifica si el jugador tiene un bloque movible frente a el usando el raycast nearRay
	var collider = nearRay.get_collider()
	
	# Si no hay colision, no hay bloque detectado
	if collider == null:
		detected_block = null
		cannot_move = false
		return

	# Si el collider es un bloque movible, lo asigna a detected_block
	if collider is GenericBlock:
		detected_block = collider
	else:
		detected_block = null
	
	# Actualiza los flags de movimiento
	cannot_move = true
	is_moving = false

func _physics_process(delta):

	if Global.dialog_mode:
		return

	# Actualiza el sprite segun el estado del jugador
	chooseSprite()

	
	# Si el jugador no se esta moviendo, obtiene direccion y verifica bloques
	if not is_moving:
		get_direction()
		changeRayDirection()
		checkRayCast()
		
	# Si el jugador se esta moviendo y hay direccion
	if is_moving and direction != Vector2.ZERO:
		
		# Si hay bloque detectado y esta moviendose, espera a que termine
		if detected_block != null and detected_block.is_block_moving():
			# Espera a que el bloque termine de moverse
			return
		# Verifica si hay bloque frente al jugador
		checkRayCast()
		# Mueve al jugador segun delta
		move(delta)
	else:
		# Marca que el jugador ya no se esta moviendo
		is_moving=false


func move(delta):
	percent_moved += WALKSPEED * delta

	if percent_moved >= 1:
		global_position = initial_position + (Tile_Size * direction)
		is_moving = false
		direction = Vector2.ZERO
		percent_moved = 0.0
	


# Logic

# Movimiento de los bloques
# gestiona la interaccion del jugador con bloques movibles.
func _process(delta):
	# Movimiento de los bloques
	if (Input.is_action_just_pressed("primary") and is_moving==false and Global.dialog_mode==false):
		magicParticle.emitting=false
		magicParticle.emitting=true
		
		if detected_block == null:
			return
		
		var blocks_to_push = get_blocks_in_path(detected_block, facedDirection)

		for block in blocks_to_push:
			if block.is_block_moving():
				return
		if not can_push_blocks(blocks_to_push, facedDirection):
			return
		
		for i in range(blocks_to_push.size() - 1, -1, -1):
			if i > 0:
				##Para que el bloque no notifique como movimiento
				blocks_to_push[i].push(facedDirection,true)
			else:
				##Notificar en el ultimo bloque
				blocks_to_push[i].push(facedDirection)	


func can_push_blocks(blocks: Array, direction: Vector2) -> bool:
	if blocks.size() == 0:
		return false
	
	var last_block = blocks[blocks.size() - 1]
	var next_pos = last_block.global_position + direction * Tile_Size
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(last_block.global_position, next_pos)
	#query.exclude[self] ## ignorar jugador
	query.collide_with_bodies = true
	
	var collision = space_state.intersect_ray(query)
	if collision.is_empty():
		return true
	elif collision.collider is GenericBlock:
		return false
	else:
		return false


func get_blocks_in_path(start_block: GenericBlock, direction: Vector2) -> Array:
	var blocks = []
	if start_block == null:
		return blocks
	
	blocks.append(start_block)
	var current_block = start_block
	
	while true:
		var next_position = current_block.global_position + direction * Tile_Size
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(current_block.global_position, next_position)
		query.exclude = [self]
		query.collide_with_bodies = true
		var collision = space_state.intersect_ray(query)
		
		if collision.is_empty() or !(collision.collider is GenericBlock):
			break
		
		current_block = collision.collider
		blocks.append(current_block)
		
	return blocks
	
	
