extends Node2D

class_name LevelManager

# ============================================================================
# ARQUITECTURA DEL LEVEL MANAGER
# ============================================================================
## LevelManager coordina todos los componentes del nivel:
## - Config: Configuración específica del nivel
## - BlockManager: Gestión de bloques móviles y detección de ecuaciones
## - EquationManager: Validación de ecuaciones y gestión de soluciones
## - MainCamera: Control de cámara y visualización

# ============================================================================
# REFERENCIAS DE COMPONENTES
# ============================================================================

## Configuración específica del nivel (zoom, parámetros, etc.)
var config: Config


## Para apagar todos los prints molestos
var debug_mode:bool = false

## Gestor de ecuaciones y validación de soluciones
var eqManager: EquationManager

## Referencia a la cámara principal del nivel
@onready var mainCamera: Camera2D = _get_camera()

# ============================================================================
# VARIABLES DE ESTADO DEL NIVEL
# ============================================================================

## Indica si el nivel ha sido completado exitosamente
var level_complete: bool = false

## Contador de ecuaciones resueltas correctamente
var equations_solved: int = 0


## Datos de nivel

@export var id:String = "None"

#Para guardar el tiempo jugado
@onready var timer:LevelTimer = $LevelTimer

#Para guardar los movimientos de el jugador

var moves:int=0

# ============================================================================
# MÉTODOS DE INICIALIZACIÓN
# ============================================================================
func _get_camera() -> Camera2D:

	var cam:Camera2D
	if Global.game_controller == null:
		
		cam = get_parent().get_node("MainCamera") as Camera2D
		cam.enabled= true
	else:
			
		cam = null


	return cam


## Inicialización principal del nivel
func _ready() -> void:
	_setup_component_references()
	_apply_level_configuration()
	_initialize_level_state()

	#Esperar un tiempo para iniciar el timer
	await get_tree().create_timer(0.5).timeout
	timer.reset_timer()
	timer.unpauseTimer()

## Obtiene referencias a todos los componentes necesarios
func _setup_component_references() -> void:
	config = get_node("Config")
	eqManager = get_node("EquationManager")
	
	if debug_mode:
		if not config:
			print("LevelManager: Warning - No Config component found!")
		if not eqManager:
			print("LevelManager: Warning - No EquationManager component found!")

## Aplica la configuración inicial del nivel
func _apply_level_configuration() -> void:
	if config:
		_apply_camera_settings()
		
	else:
		if debug_mode:
			printerr("LevelManager: Cannot apply configuration - Config component missing")

## Inicializa el estado del nivel
func _initialize_level_state() -> void:
	level_complete = false
	equations_solved = 0
	

# ============================================================================
# MÉTODOS DE CONFIGURACIÓN
# ============================================================================

## Aplica configuración de zoom de la cámara
func _apply_camera_settings() -> void:
	if mainCamera and config:
		var zoom_level: Vector2 = config.getZoom()
		mainCamera.zoom = zoom_level
	else:
		#Asumir que la camara es la global
		Global.game_controller.change_zoom(config.getZoom())


## Aplica toda la configuración del nivel (método legacy)
func aplicarConf() -> void:
	_apply_camera_settings()

## Aplica zoom específico (método legacy)
func aplicarZoom() -> void:
	_apply_camera_settings()

# ============================================================================
# COMUNICACIÓN CON BLOCK MANAGER
# ============================================================================

## Resetea todas las soluciones cuando un bloque se mueve
## Llamado por BlockManager para invalidar soluciones previas

func _on_block_moved():

	#Aumentar los movimientos del nivel
	moves+=1

	reset_solutions()


func reset_solutions() -> void:
	
	
	if eqManager:
		eqManager.reset_all_solutions()
		equations_solved = 0
	else:
		if debug_mode:
			print("LevelManager: Cannot reset solutions - EquationManager not found!")

## Procesa una ecuación válida encontrada por BlockManager
## Llamado cuando BlockManager detecta una cadena de bloques válida
func equation_found(equation: String) -> void:
	if debug_mode:
		print("LevelManager: Processing equation: ", equation)
	
	if not eqManager:
		printerr("LevelManager: Error - EquationManager not available!")
		return
	
	var is_correct: bool = eqManager.verify_equation(equation)
	
	if debug_mode:
			
		if is_correct:
			print("LevelManager: Equation solved correctly! Total solved: ", equations_solved)

		else:
			print("LevelManager: Equation is incorrect: ", equation)

# ============================================================================
# GESTIÓN DE FINALIZACIÓN DEL NIVEL
# ============================================================================


## Maneja la llegada del jugador a la meta
## Llamado cuando el player entra en contacto con un GoalBlock activo
func on_player_reach_goal() -> void:
	if debug_mode:
		print("LevelManager: Player reached goal")
	_complete_level()

## Ejecuta la lógica de finalización del nivel
func _complete_level() -> void:
	if level_complete:
		return
	
	level_complete = true

	timer.pauseTimer()
	#Guardar info del nivel
	Global.record_level_data(id,moves,timer.getTime())
	
	_on_level_complete()

## Evento personalizable para cuando se completa el nivel
func _on_level_complete() -> void:
	
	Global.game_controller.change_zoom(Vector2(1,1))
	Global.game_controller.change_gui_scene(Global.game_controller.menus["LevelCompleted"])
	Global.game_controller.hide_level()





# ============================================================================
# MÉTODOS DE DEBUG Y UTILIDADES
# ============================================================================

## Imprime el estado actual del nivel
func debug_print_level_state() -> void:
	print("=== LEVEL STATE DEBUG ===")
	print("Level Complete: ", level_complete)
	print("Equations Solved: ", equations_solved)
	print("Config Available: ", config != null)
	print("EquationManager Available: ", eqManager != null)
	print("MainCamera Available: ", mainCamera != null)

## Fuerza el reseteo completo del nivel
func force_level_reset() -> void:
	level_complete = false
	equations_solved = 0
	reset_solutions()
	print("LevelManager: Level forcefully reset")
