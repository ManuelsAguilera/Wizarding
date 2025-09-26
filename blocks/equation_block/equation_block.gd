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
var event_blocks: Array[Node] = []  # Agregar esta línea de vuelta




#La variable que debe ser solucionada
@export var variableType:String = "x"
#El valor que debe tener la variable
@export var solution: float = 0.0/0.0


#estado de solucion

var solved:bool = false
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
		text.changeColor(color)
		text._ready()
	



# Para que equation manager pueda obtener la solucion
# y verificar si es correcta
func get_solution() -> float:
	return solution


# ============================================================================
# MÉTODOS DE NOTIFICACIÓN
# ============================================================================

## Notifica a los bloques de evento que la ecuación ha sido resuelta correctamente
func triggerEvents(solved_value:bool) -> void:
	
	if solved == solved_value:
		return # No hay cambio en el estado, no hacer nada
	
	solved = solved_value

	for event in get_children():
		if event is EventBlock:
			event.trigger(solved)
			print("Triggered event: ", event)


	if solved:
		color="green"
		if text:
			text.changeColor("green")
	else:
		color="white"
		if text:
			text.changeColor("white")
