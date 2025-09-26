extends EventBlock

class_name GoalBlock

# ============================================================================
# GOALBLOCK - EVENTO DE META DE NIVEL
# ============================================================================
## GoalBlock es un tipo específico de EventBlock que controla las metas
## del nivel. Se activa cuando se resuelve correctamente la ecuación asociada,
## permitiendo al jugador completar el nivel.

# ============================================================================
# REFERENCIAS DE COMPONENTES
# ============================================================================

## Referencia al cuerpo físico de la meta que controla colisiones
var body: GoalPostBody

# ============================================================================
# VARIABLES DE ESTADO
# ============================================================================

## Estado de activación de la meta (true = jugador puede pasar)
var activated: bool = false

## Contador de veces que el jugador ha tocado esta meta
var touch_count: int = 0

# ============================================================================
# MÉTODOS DE INICIALIZACIÓN
# ============================================================================

## Inicialización del GoalBlock
func _ready() -> void:
	super._ready()  # Llamar al _ready() del padre (EventBlock)
	_setup_goal_components()
	_initialize_goal_state()

## Configura las referencias a componentes específicos del goal
func _setup_goal_components() -> void:
	body = get_node("GoalBody")
	
	if not body:
		print("GoalBlock: Warning - GoalBody component not found!")
	else:
		print("GoalBlock: GoalBody component found and configured")

## Inicializa el estado de la meta
func _initialize_goal_state() -> void:
	activated = false
	touch_count = 0
	
	if body:
		body.deactivate()
	
	print("GoalBlock: Goal initialized in deactivated state")

# ============================================================================
# IMPLEMENTACIÓN DE EVENTBLOCK (OVERRIDE)
# ============================================================================

## Sobrescribe el método trigger de EventBlock para controlar la meta
func _execute_event_logic(solved_value: bool) -> void:
	var previous_activation: bool = activated
	activated = solved_value
	
	_update_goal_physical_state()
	_log_activation_change(previous_activation, activated)

## Actualiza el estado físico de la meta
func _update_goal_physical_state() -> void:
	if not body:
		return
	
	if activated:
		body.activate()
		print("GoalBlock: Goal ACTIVATED - Player can now complete the level")
	else:
		body.deactivate()
		print("GoalBlock: Goal DEACTIVATED - Player must solve equations first")

## Registra cambios en el estado de activación
func _log_activation_change(previous: bool, current: bool) -> void:
	if previous != current:
		if current:
			print("GoalBlock: 🎯 Goal became accessible!")
		else:
			print("GoalBlock: ❌ Goal became inaccessible")

# ============================================================================
# MÉTODOS DE INTERACCIÓN CON EL JUGADOR
# ============================================================================

## Llamado cuando el jugador intenta interactuar con la meta
func on_player_interaction() -> void:
	touch_count += 1
	
	if activated:
		_handle_successful_goal_reach()
	else:
		_handle_unsuccessful_goal_attempt()

## Maneja el caso cuando el jugador alcanza una meta activa
func _handle_successful_goal_reach() -> void:
	print("GoalBlock: Player successfully reached active goal! (Touch #", touch_count, ")")
	
	# Notificar al LevelManager
	var level_manager: LevelManager = _find_level_manager()
	if level_manager:
		level_manager.on_player_reach_goal()
	else:
		print("GoalBlock: Warning - Could not find LevelManager to notify goal completion")

## Maneja el caso cuando el jugador intenta alcanzar una meta inactiva
func _handle_unsuccessful_goal_attempt() -> void:
	print("GoalBlock: Player touched inactive goal - equations must be solved first (Touch #", touch_count, ")")
	
	# Aquí se pueden agregar efectos visuales o sonoros de "acceso denegado"
	_show_access_denied_feedback()

## Busca el LevelManager en la jerarquía de nodos
func _find_level_manager() -> LevelManager:
	var current_node: Node = self
	
	# Buscar hacia arriba en la jerarquía
	while current_node:
		if current_node is LevelManager:
			return current_node
		current_node = current_node.get_parent()
	
	return null

## Muestra feedback visual/sonoro cuando se niega el acceso
func _show_access_denied_feedback() -> void:
	# Implementar efectos de "acceso denegado":
	# - Shake de la cámara
	# - Sonido de error
	# - Partículas rojas
	# - Mensaje en pantalla
	pass

# ============================================================================
# MÉTODOS DE CONSULTA Y ESTADO
# ============================================================================

## Verifica si la meta está actualmente accesible
func is_goal_accessible() -> bool:
	return activated and body != null

## Obtiene estadísticas de interacción con la meta
func get_goal_stats() -> Dictionary:
	return {
		"activated": activated,
		"touch_count": touch_count,
		"has_body": body != null,
		"equation_solved": equation_correct
	}

# ============================================================================
# MÉTODOS DE DEBUG
# ============================================================================

## Fuerza la activación de la meta (solo para testing)
func debug_force_activation(force_active: bool) -> void:
	print("GoalBlock: DEBUG - Forcing activation to: ", force_active)
	activated = force_active
	_update_goal_physical_state()

## Imprime información completa de debug
func debug_print_goal_info() -> void:
	super.debug_print_event_info()  # Llamar debug del padre
	print("=== GoalBlock Specific Debug ===")
	print("Activated: ", activated)
	print("Touch Count: ", touch_count)
	print("Has Body Component: ", body != null)
	var stats: Dictionary = get_goal_stats()
	print("Goal Stats: ", stats)
