extends Node2D


class_name EquationBlock

# ============================================================================
# CONSTANTES PARA SNAPPING
# ============================================================================

## Tamaño de cada tile en píxeles para el sistema de grid
const TILE_SIZE: Vector2 = Vector2(64, 64)

# ============================================================================
# VARIABLES EXPORTADAS
# ============================================================================

@export var equation: String = "default"
@export var color: String = "white"

var text: TextEquation

var event_blocks: Array = []

# ============================================================================
# MÉTODOS DE SNAPPING
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
	return global_position.snapped(TILE_SIZE) / 64

## Configura la posición inicial en el grid
func _setup_position() -> void:
	snap_to_grid()

# ============================================================================
# MÉTODOS DE INICIALIZACIÓN
# ============================================================================

func _ready():
	# Configurar posición en el grid
	_setup_position()
	
	text = get_node("TextEquation")
	if text:
		text.changeEquation(equation)
		text.color = color
		text._ready()

	#Buscar todos los EventBlock hijos
	for child in get_children():
		if child is EventBlock:
			event_blocks.append(child)
			print("Event block found: ", child)



func on_body_entered(body):
	if body is Player:
		print("Goal Block: Player entered the goal area")
		get_parent().on_player_reach_goal()
