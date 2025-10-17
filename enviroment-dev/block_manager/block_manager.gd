extends Node2D
class_name BlockManager


# ============================================================================
# VARIABLES DE CONFIGURACIÓN
# ============================================================================

## Tamaño del mapa para futura implementación de grid
@export var map_size: Vector2 = Vector2(10, 10)

# ============================================================================
# VARIABLES DE ESTADO
# ============================================================================

## Lista de listas de bloques encadenados encontrados
var concatBlocks: Array[Array] = []

## Todos los bloques GenericBlock en la escena para búsquedas rápidas
var blocklist: Array[GenericBlock] = []

## Bloques de tipo variable (x,y,z) que pueden iniciar cadenas
var variableBlocks: Array[GenericBlock] = []

## Flag para evitar búsquedas innecesarias de cadenas
var chains_searched: bool = false


# ============================================================================
# MÉTODOS DE INICIALIZACIÓN
# ============================================================================

func _ready() -> void:
	# Recolecta referencias a `GenericBlock` hijos y realiza la primera búsqueda de cadenas válidas
	_initialize_blocks()
	#_debug_print_blocks()

	search()

## Inicializa las listas de bloques buscando todos los GenericBlock hijos
func _initialize_blocks() -> void:
	for child in get_children():
		if child is GenericBlock:
			blocklist.append(child)
			if child.getTypeBlock() == "variable":
				variableBlocks.append(child)

## Imprime información de debug de todos los bloques encontrados
func _debug_print_blocks() -> void:
	for block in blocklist:
		print(block.getTypeBlock(), " ", block.getSnappedPosition())

# ============================================================================
# MÉTODOS DE NOTIFICACIÓN
# ============================================================================

## Método que debe llamarse cuando se mueva un bloque o varios.
## Ejemplo de uso: `Player` invoca `block_manager.notify_block_moved()` justo
## después de lanzar la animación de movimiento en los bloques.
##
## Comportamiento:
## 1) Espera (polling por frame) hasta que TODOS los `GenericBlock` reporten
##    `is_block_moving() == false`.
## 2) Notifica al `LevelManager` con `_on_block_moved()` para que restablezca
##    el estado de soluciones si es necesario.
## 3) Ejecuta `search()` para detectar nuevas cadenas válidas.
func notify_block_moved() -> void:
	await _wait_for_blocks_to_finish_moving()
	# Avisar a LevelManager para que resetee las soluciones
	get_parent()._on_block_moved()
	search()
	chains_searched = false

## Implementación actual: polling por frame.
## Recomendación: si performance es un problema, cambiar a señales desde
## `GenericBlock` (p. ej. `movement_finished`) y contar emisiones pendientes.
func _wait_for_blocks_to_finish_moving() -> void:
	while true:
		var any_moving: bool = false
		for block in blocklist:
			# Se llama al método público del bloque; `GenericBlock` implementa esto
			if block.is_block_moving():
				any_moving = true
				break
		if not any_moving:
			return
		# Espera un frame antes de comprobar de nuevo
		await get_tree().process_frame

# ============================================================================
# MÉTODOS DE BÚSQUEDA DE CADENAS
# ============================================================================

## Busca recursivamente bloques conectados en una dirección específica
func searchBlocks(initial_pos: Vector2, direction: Vector2) -> Array[GenericBlock]:
	var chain: Array[GenericBlock] = []
	var current_pos: Vector2 = initial_pos + direction
	
	# Buscar bloque en la posición actual
	for block in blocklist:
		if block.getSnappedPosition() == current_pos:
			chain.append(block)
			# Continuar búsqueda recursiva en la misma dirección
			chain.append_array(searchBlocks(current_pos, direction))
			break
	
	return chain

## Genera todas las cadenas de bloques válidas
func generar_cadenas() -> void:
	concatBlocks.clear()
	
	for variable in variableBlocks:
		var variable_pos: Vector2 = variable.getSnappedPosition()
		var down_pos: Vector2 = variable_pos + Vector2(0, 1)
		var right_pos: Vector2 = variable_pos + Vector2(1, 0)
		var up_pos: Vector2 = variable_pos + Vector2(-1,0)
		var left_pos: Vector2 = variable_pos + Vector2(0,-1)

		# Buscar bloques conectados hacia abajo y hacia la derecha
		for block in blocklist:
			var block_pos: Vector2 = block.getSnappedPosition()
			var initial_chain: Array[GenericBlock] = [variable, block]
			
			if block_pos == down_pos:
				var complete_chain = initial_chain + searchBlocks(block_pos, Vector2(0, 1))
				concatBlocks.append(complete_chain)
			elif block_pos == right_pos:
				var complete_chain = initial_chain + searchBlocks(block_pos, Vector2(1, 0))
				concatBlocks.append(complete_chain)
			elif block_pos == up_pos:
				var complete_chain = initial_chain + searchBlocks(block_pos, Vector2(-1, 0))
				concatBlocks.append(complete_chain)
			elif block_pos == left_pos:
				var complete_chain = initial_chain + searchBlocks(block_pos, Vector2(0, -1))
				concatBlocks.append(complete_chain)


func search() -> void:
	# Deseleccionar cadenas previas
	if concatBlocks.size() > 0:
		for block in blocklist:
			block.set_in_chain(false)


	generar_cadenas()

	for chain in concatBlocks:

		# No se puede enviar chain, porque se modifica en revisar_sintaxis
		var result = revisar_sintaxis(chain.duplicate())
		if result != "invalid":
			# Notificar a LevelManager
			equation_found(result)
			
			# Activar color de bloques en cadena
			for block in chain:
				block.set_in_chain(true)
			


# ============================================================================
# MÉTODOS DE REVISION SINTAXIS
# ============================================================================


func revisar_sintaxis(cadena: Array[GenericBlock]) -> String:
	# La cadena debe tener al menos 3 bloques (variable, operador, número/variable)
	if cadena.size() < 3:
		return "invalid"
	
	# La respuesta final para luego ser devuelta a una clase encargada de evaluar la cadena
	var final_string = ""

	# La cadena debe comenzar con una variable
	var first_block = cadena[0]
	if first_block.getTypeBlock() != "variable":
		return "invalid"

	final_string += first_block.getTypeVariable()

	var second_block = cadena[1]
	# El segundo bloque debe ser un operador (en este caso '=')
	if second_block.getTypeBlock() != "=":
		return "invalid"

	final_string += "="
	
	# Variables para rastrear el estado esperado
	var expecting_number = true
	
	# Iterar desde el índice 2 en adelante
	for i in range(2, cadena.size()):
		var block = cadena[i]
		var block_type = block.getTypeBlock()
		
		if expecting_number:
			if block_type == "num":
				expecting_number = false
				final_string += str(block.getTypeNumber())
			else:
				return "invalid"
		else:
			if block_type == "operator":
				expecting_number = true
				final_string += block.getTypeOperation()
			else:
				return "invalid"
	
	# La cadena no debe terminar esperando un número
	return final_string if not expecting_number else "invalid"


# ============================================================================
# MÉTODOS DE DEBUG Y VISUALIZACIÓN
# ============================================================================

## Imprime todas las cadenas encontradas en formato legible
func printCadenas() -> void:
	print("Cadenas encontradas:")
	for chain in concatBlocks:
		var chain_string: String = ""
		for block in chain:
			var block_type: String = block.getTypeBlock()
			chain_string += block_type + " "
			
			match block_type:
				"num":
					chain_string += str(block.getTypeNumber()) + ","
				"variable":
					chain_string += str(block.getTypeVariable()) + ","
				"operator":
					chain_string += str(block.getTypeOperation()) + ","
		
		print("[", chain_string, "]")

# ============================================================================
# MÉTODOS DEL MOTOR GODOT
# ============================================================================



# ============================================================================
# Metodos a el padre LevelManager
# ============================================================================




func equation_found(equation: String) -> void:
	print("BlockManager: Ecuacion valida encontrada!")
	var level_manager = get_parent()
	if level_manager and level_manager is LevelManager:
		level_manager.equation_found(equation)
