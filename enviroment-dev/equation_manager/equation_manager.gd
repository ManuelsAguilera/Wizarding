extends Node2D

class_name EquationManager

var solutions: Array = []

# ============================================================================
# METODOS DE INICIALIZACION
# ============================================================================


func _ready():
	for child in get_children():
		if child is EquationBlock:
			solutions.append(child)
# ============================================================================
# Llamado por level manager, para que verifque si es una respuesta correcta
# y notifique a los bloques de eventos
# ============================================================================
func verify_equation(equation: String) -> bool:

	#Revisar cada bloque EquationBlock
	for solution in solutions:

		var is_solved = compare_solutions(equation,solution)
		

		# Notify event blocks
		solution.triggerEvents(is_solved)
		print("EquationManager: Triggered events for equation: ", equation)


		# Asumimos que una sola solucion es correcta
		if is_solved:
			print("EquationManager: Correct solution for equation: ", equation)			
			return true

	print("EquationManager: No correct solution found for equation: ", equation)
	return false

# ============================================================================
# MÉTODOS DE CALCULO Y PROCESADO DE ECUACIONES
# ============================================================================


func calculate_from_string(equation:String) -> Variant:
	#Usar clase Expression de Godot
	#Bastante util la verda
	#https://docs.godotengine.org/es/4.x/tutorials/scripting/evaluating_expressions.html



	var expr = Expression.new()
	var error = expr.parse(equation)
	if error != OK:
		#print("EquationManager: Error parsing equation: ", equation)
		return null
	var result = expr.execute()
	if expr.has_execute_failed():
		#print("EquationManager: Error executing equation: ", equation)
		return null
	return result



func compare_solutions(eq_found:String,solution:EquationBlock) -> bool:

	#Ver que sea la variable correcta
	if eq_found[0] != solution.variableType:
		return false

	
	#Calcular el valor de la ecuacion
	var result_eq = calculate_from_string(eq_found.substr(2, eq_found.length()))

	if result_eq == null:
		return false

	#Comparar el resultado con la solucion
	if float(result_eq) == solution.get_solution():
		return false

	return true
