extends Node2D

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
	_initialize_blocks()
	#_debug_print_blocks()

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

## Método para que GenericBlock hijo llame cuando se mueva
func notify_block_moved() -> void:
	chains_searched = false

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

func _process(_delta: float) -> void:
	if not chains_searched:
		chains_searched = true
		generar_cadenas()
		printCadenas()
