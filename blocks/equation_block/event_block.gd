extends Node

class_name EventBlock

# ============================================================================
# CLASE BASE PARA EVENTOS DE ECUACIONES
# ============================================================================
## EventBlock proporciona una interfaz común para todos los eventos que
## se activan cuando se resuelve o resetea una ecuación.
## Utiliza el patrón Template Method para permitir comportamientos específicos.

# ============================================================================
# VARIABLES DE ESTADO
# ============================================================================

## Estado actual de la ecuación asociada a este evento
var equation_correct: bool = false

## Referencia opcional al EquationBlock padre que contiene este evento
var parent_equation: EquationBlock

# ============================================================================
# MÉTODOS DE INICIALIZACIÓN
# ============================================================================

## Configuración inicial del evento
func _ready() -> void:
	_setup_parent_reference()
	_initialize_event_state()

## Establece la referencia al EquationBlock padre
func _setup_parent_reference() -> void:
	var parent: Node = get_parent()
	if parent is EquationBlock:
		parent_equation = parent

## Inicializa el estado del evento
func _initialize_event_state() -> void:
	equation_correct = false

# ============================================================================
# MÉTODOS PRINCIPALES (TEMPLATE METHOD PATTERN)
# ============================================================================

## Método principal llamado cuando cambia el estado de la ecuación
## Este método DEBE ser sobrescrito por las clases hijas
func trigger(solved_value: bool) -> void:
	_update_internal_state(solved_value)
	_execute_event_logic(solved_value)

## Actualiza el estado interno del evento
func _update_internal_state(solved_value: bool) -> void:
	var previous_state: bool = equation_correct
	equation_correct = solved_value
	
	# Solo imprimir cambios de estado para debug
	if previous_state != equation_correct:
		print("EventBlock: State changed from ", previous_state, " to ", equation_correct)

## Ejecuta la lógica específica del evento (debe ser sobrescrita)
func _execute_event_logic(solved_value: bool) -> void:
	# Este método debe ser implementado por las clases hijas
	# Ejemplo de implementaciones:
	# - Activar/desactivar objetos
	# - Reproducir sonidos/animaciones
	# - Modificar propiedades físicas
	# - Enviar señales a otros sistemas
	pass

# ============================================================================
# MÉTODOS DE CONSULTA
# ============================================================================

## Verifica si la ecuación asociada está correctamente resuelta
func is_equation_solved() -> bool:
	return equation_correct

## Obtiene información del EquationBlock padre si está disponible
func get_parent_equation_info() -> Dictionary:
	if parent_equation:
		return {
			"variable": parent_equation.variableType,
			"solution": parent_equation.get_solution(),
			"equation_text": parent_equation.equation,
			"solved": parent_equation.solved
		}
	return {}

# ============================================================================
# MÉTODOS DE DEBUG
# ============================================================================

## Imprime información de debug del evento
func debug_print_event_info() -> void:
	print("=== EventBlock Debug Info ===")
	print("Type: ", get_script().resource_path.get_file())
	print("Equation Correct: ", equation_correct)
	print("Parent Equation: ", parent_equation != null)
	if parent_equation:
		var info: Dictionary = get_parent_equation_info()
		print("Parent Info: ", info)

