extends Node2D

class_name EquationManager

# ============================================================================
# VARIABLES DE ESTADO
# ============================================================================

## Lista de bloques EquationBlock que representan las soluciones del nivel
var solutions: Array[EquationBlock] = []

# ============================================================================
# MÉTODOS DE INICIALIZACIÓN
# ============================================================================

## Inicializa el manager recolectando todos los EquationBlock hijos
func _ready() -> void:
	_collect_equation_blocks()

## Recolecta todos los bloques de ecuación disponibles en el nivel
func _collect_equation_blocks() -> void:
	solutions.clear()
	for child in get_children():
		if child is EquationBlock:
			solutions.append(child)
	
	print("EquationManager: Found ", solutions.size(), " equation blocks")

# ============================================================================
# MÉTODOS DE VALIDACIÓN PRINCIPAL
# ============================================================================

## Verifica si una ecuación encontrada corresponde a alguna solución del nivel
## Llamado por LevelManager cuando BlockManager encuentra una ecuación válida
func verify_equation(equation: String) -> bool:
	print("EquationManager: Verifying equation: ", equation)
	
	var any_solution_found: bool = false
	
	# Revisar cada bloque EquationBlock
	for solution in solutions:
		var is_solved: bool = compare_solutions(equation, solution)
		
		# Notificar estado a los bloques de eventos
		solution.triggerEvents(is_solved)
		
		if is_solved:
			print("EquationManager: Correct solution found for equation: ", equation)
			any_solution_found = true
			# No hacer break - permitir que múltiples ecuaciones se resuelvan
	
	if not any_solution_found:
		print("EquationManager: No correct solution found for equation: ", equation)
	
	return any_solution_found

# ============================================================================
# MÉTODOS DE COMPARACIÓN DE ECUACIONES
# ============================================================================

## Compara una ecuación encontrada con un bloque de solución específico
func compare_solutions(eq_found: String, solution: EquationBlock) -> bool:
	# Validar formato mínimo de ecuación (ej: "x=5")
	if eq_found.length() < 3:
		return false
	
	# Verificar que la variable coincida (primer carácter)
	var equation_variable: String = eq_found[0]
	if equation_variable != solution.variableType:
		return false
	
	# Verificar que el segundo carácter sea '='
	if eq_found[1] != "=":
		return false
	
	# Extraer la parte derecha de la ecuación (después del '=')
	var right_side: String = eq_found.substr(2)
	
	# Calcular el valor de la expresión
	var calculated_result: Variant = calculate_from_string(right_side)
	if calculated_result == null:
		return false
	
	# Comparar el resultado con la solución esperada
	var expected_solution: float = solution.get_solution()
	var result_float: float = float(calculated_result)
	
	# Usar comparación con tolerancia para números flotantes
	const EPSILON: float = 0.0001
	var is_equal: bool = abs(result_float - expected_solution) < EPSILON
	
	if is_equal:
		print("EquationManager: Match found - Variable: ", equation_variable, 
			  ", Calculated: ", result_float, ", Expected: ", expected_solution)
	
	return is_equal

# ============================================================================
# MÉTODOS DE CÁLCULO MATEMÁTICO
# ============================================================================

## Evalúa una expresión matemática string usando la clase Expression de Godot
## Referencia: https://docs.godotengine.org/es/4.x/tutorials/scripting/evaluating_expressions.html
func calculate_from_string(equation: String) -> Variant:
	var expr: Expression = Expression.new()
	
	# Intentar parsear la expresión
	var parse_error: int = expr.parse(equation)
	if parse_error != OK:
		print("EquationManager: Parse error in equation: ", equation, " - Error: ", parse_error)
		return null
	
	# Ejecutar la expresión
	var result: Variant = expr.execute()
	if expr.has_execute_failed():
		print("EquationManager: Execution error in equation: ", equation)
		return null
	
	return result

# ============================================================================
# MÉTODOS DE DEBUG Y UTILIDADES
# ============================================================================

## Imprime información de debug sobre todas las soluciones disponibles
func debug_print_solutions() -> void:
	print("EquationManager: Available solutions:")
	for i in range(solutions.size()):
		var solution: EquationBlock = solutions[i]
		print("  [", i, "] Variable: ", solution.variableType, 
			  " = ", solution.get_solution(), " (", solution.equation, ")")

## Resetea el estado de todas las soluciones
func reset_all_solutions() -> void:
	for solution in solutions:
		solution.triggerEvents(false)
	print("EquationManager: All solutions reset")
