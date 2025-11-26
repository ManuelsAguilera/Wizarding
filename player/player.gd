extends CharacterBody2D


class_name Player

@onready var sprite:AnimatedSprite2D = $PlayerSprite
@onready var magicParticlePush:CPUParticles2D = $MagicParticlePush
@onready var magicParticlePull:CPUParticles2D = $MagicParticlePull
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

var is_pulling: bool = false

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
		magicParticlePush.emitting=false
		magicParticlePush.emitting=true
		
		if detected_block == null:
			return
		
		push()

	if (Input.is_action_just_pressed("secondary") and is_moving==false and Global.dialog_mode==false):
		
		if detected_block == null:
			return
		print("[INFO] Entro a _process secondary")
		pull()

# Empujar bloques
func pull():

	print("[INFO] Empezo pull()")
	var block_to_pull = detected_block

	if block_to_pull == null:
		return
	
	if not can_pull_block(block_to_pull):
		print("cannot pull")
		return
	
	# Teletransportar jugador
	is_pulling = true
	var target_position = global_position - facedDirection * Tile_Size
	global_position = target_position
	is_moving = false
	direction = Vector2.ZERO
	percent_moved = 0.0
	initial_position = global_position

	magicParticlePull.emitting=false
	magicParticlePull.emitting=true
	
	block_to_pull.pull(facedDirection)

	var block_manager:BlockManager = block_to_pull.get_parent()
	if block_to_pull.get_parent() != null:
		block_manager.notify_block_moved()
	if block_manager != null:
		block_manager.notify_block_moved()
	print("[INFO] Termino pull()")
	

#Hacemos la logica de solo mover un bloque, controlando aqui de que manera se hace.
func push():
	var blocks_to_push = get_blocks_to_push(detected_block, facedDirection)

	
	for block in blocks_to_push:
		if block.is_block_moving():
			return
		if not can_push_blocks(blocks_to_push, facedDirection):
			print("cannot push")
			return
		
	for i in range(blocks_to_push.size() - 1, -1, -1):
			blocks_to_push[i].push(facedDirection)
	
	#Obtener BlockManager
	var block_manager:BlockManager = blocks_to_push[0].get_parent()
	
	block_manager.notify_block_moved()

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

func can_pull_block(block: GenericBlock) -> bool:
	
	if block == null:
		return false
	if block.is_block_moving():
		return false
	

	var space_state = get_world_2d().direct_space_state
	
	# Primero revisar si hay algo detras del jugador
	var player_back_pos = global_position - facedDirection * Tile_Size
	var q_player = PhysicsRayQueryParameters2D.create(block.global_position, player_back_pos)
	q_player.exclude = [self]
	q_player.collide_with_bodies = true
	var col_player = space_state.intersect_ray(q_player)	
	
	# Terminar de revisar si hay algo detras del jugador
	if not col_player.is_empty():
		return false

	# Luego revisar si hay algo detras del bloque (caso de barrera)
	var block_target_pos = block.global_position - facedDirection * Tile_Size
	var q_block = PhysicsRayQueryParameters2D.create(block.global_position, block_target_pos)
	q_block.exclude = [block, self]
	q_block.collide_with_bodies = true
	var col_block = space_state.intersect_ray(q_block)
	if not col_block.is_empty():
		return false


	return true

func get_blocks_to_push(start_block: GenericBlock, direction: Vector2) -> Array:
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
