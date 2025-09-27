extends CharacterBody2D

class_name GenericBlock

# ============================================================================
# CONSTANTES
# ============================================================================

## Tamaño de cada tile en píxeles para el sistema de grid
const TILE_SIZE: Vector2 = Vector2(64, 64)

## Velocidad de animación para el movimiento de bloques
const ANIMATION_SPEED: float = 8.0

# ============================================================================
# VARIABLES EXPORTADAS
# ============================================================================

## Nombre del sprite que determina el tipo de bloque
@export var spriteName: String = "default"

## Frame específico del sprite (importante para números 0-9)
@export var frame: int = 0

# ============================================================================
# REFERENCIAS DE NODOS
# ============================================================================

## Referencia al sprite animado del bloque
@onready var sprite: AnimatedSprite2D = $sprite

## Efecto de partículas al mover el bloque
@onready var particleEffect: CPUParticles2D = $DustParticles

# ============================================================================
# VARIABLES DE ESTADO
# ============================================================================

## Referencia al manager padre que contiene este bloque
var parentManager: Node = null

## Tipo de bloque determinado según spriteName y frame
var typeBlock: String = ""

## Posición inicial antes de comenzar un movimiento
var initial_position: Vector2 = Vector2()

## Indica si el bloque está en movimiento
var is_moving: bool = false

## Porcentaje de progreso del movimiento (0.0 a 1.0)
var percent_moved: float = 0.0

## Dirección del movimiento actual
var direction: Vector2 = Vector2()

## Indica si el bloque está en una cadena
var is_in_chain: bool = false



# ============================================================================
# MÉTODOS DE INICIALIZACIÓN
# ============================================================================

## Inicialización principal del bloque
func _ready() -> void:
	_setup_sprite()
	_setup_position()
	_setup_type()
	_setup_parent_reference()

	#Inicializar modulación
	set_in_chain(false)

## Configura el sprite inicial del bloque
func _setup_sprite() -> void:
	sprite.play(spriteName)
	sprite.frame = frame
	sprite.pause()

## Configura la posición inicial en el grid
func _setup_position() -> void:
	snap_to_grid()
	initial_position = global_position

## Determina y asigna el tipo de bloque
func _setup_type() -> void:
	typeBlock = _calculate_block_type()

## Establece la referencia al manager padre
func _setup_parent_reference() -> void:
	parentManager = get_parent()

# ============================================================================
# MÉTODOS DE TIPOS DE BLOQUE
# ============================================================================

## Calcula el tipo de bloque basado en spriteName y frame
func _calculate_block_type() -> String:
	match spriteName:
		"default":
			return "invalid"
		"num":
			if frame >= 0 and frame <= 9:
				return "num"
			else:
				return "invalid"
		"+", "-", "/", "*":
			return "operator"
		"=":
			return "="
		"x", "y", "z":
			return "variable"
		_:
			return "invalid"

## Devuelve el tipo de bloque actual
func getTypeBlock() -> String:
	return typeBlock

## Devuelve el tipo de operación si es un bloque operator
func getTypeOperation() -> String:
	if typeBlock == "operator":
		return spriteName
	return ""

## Devuelve el número si es un bloque num
func getTypeNumber() -> int:
	if typeBlock == "num":
		return frame
	return -1

## Devuelve la variable si es un bloque variable
func getTypeVariable() -> String:
	if typeBlock == "variable":
		return spriteName
	return ""

## Método de identificación para polimorfismo
func isABlock() -> void:
	pass

# ============================================================================
# MÉTODOS DE POSICIÓN Y GRID
# ============================================================================

## Ajusta la posición del bloque al grid más cercano
func snap_to_grid() -> void:
	var snapped_pos: Vector2 = global_position.snapped(TILE_SIZE)
	
	if global_position == snapped_pos:
		return
	else:
		global_position = snapped_pos + Vector2(1, -1) * TILE_SIZE / 2

## Devuelve la posición del bloque en coordenadas de grid
func getSnappedPosition() -> Vector2:
	if is_moving:
		return initial_position.snapped(TILE_SIZE) / 64
	else:
		return global_position.snapped(TILE_SIZE) / 64

# ============================================================================
# MÉTODOS DE MOVIMIENTO
# ============================================================================

## Inicia el movimiento del bloque en una dirección específica
func push(player_direction: Vector2) -> void:
	if not is_moving:
		_activate_particles()
		direction = player_direction
		is_moving = true
		percent_moved = 0.0
		initial_position = global_position

## Activa el efecto de partículas
func _activate_particles() -> void:
	particleEffect.emitting = false
	particleEffect.emitting = true

## Establece la dirección de movimiento (método legacy)
func set_direction(dir: Vector2) -> void:
	direction = dir

## Verifica si el bloque está en movimiento
func is_block_moving() -> bool:
	return is_moving

## Ejecuta la animación de movimiento
func move(delta: float) -> void:
	percent_moved += ANIMATION_SPEED * delta
	
	if percent_moved >= 1.0:
		_finish_movement()
	else:
		_update_movement_position()

## Finaliza el movimiento y notifica al manager
func _finish_movement() -> void:
	global_position = initial_position + (TILE_SIZE * direction)
	is_moving = false
	direction = Vector2.ZERO
	percent_moved = 0.0
	#Quitar de cadena si es que esta en una

	if is_in_chain:
		set_in_chain(false)
		is_in_chain = false
	parentManager.notify_block_moved()

## Actualiza la posición durante el movimiento
func _update_movement_position() -> void:
	global_position = initial_position + (TILE_SIZE * direction * percent_moved)


# ============================================================================
# MÉTODOS DEL MOTOR GODOT
# ============================================================================

## Maneja la física del movimiento
func _physics_process(delta: float) -> void:
	if is_moving and direction != Vector2.ZERO:
		move(delta)
	else:
		is_moving = false


# ============================================================================
# MÉTODOS DE CAMBIO ESTETICO
# ============================================================================

#Cambiar modulacion del sprite cuando este en una cadena
#Este metodo debe ser invocado por su manager
func set_in_chain(in_chain: bool) -> void:
	if in_chain:
		sprite.modulate = Color(1, 1, 1) # Color normal
	else:
		sprite.modulate = Color(0.5, 0.5, 0.5) # Color opaco
	
	is_in_chain = in_chain
