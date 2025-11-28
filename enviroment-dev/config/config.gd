extends Node2D

class_name Config

@export var zoom: Vector2 = Vector2(1, 1)

const LEVEL_DIALOG:DialogueResource = preload("res://dialogos/level_popup.dialogue")


# Variables exportadas para controlar cuándo mostrar diálogos
@export_group("Configuración de Diálogos")
@export var mostrar_dialogo_nivel_inicio: bool = false
@export var mostrar_dialogo_jugador_en_posicion: bool = false
@export var mostrar_dialogo_primera_ecuacion_resuelta: bool = false
@export var mostrar_dialogo_nivel_completado: bool = false

# Títulos de los diálogos a mostrar
@export_group("Títulos de Diálogos")
@export var titulo_dialogo_nivel_inicio: String = "¡Bienvenido!"
@export var titulo_dialogo_posicion: String = "¡Bienvenido!"
@export var titulo_dialogo_primera_ecuacion: String = "¡Primera ecuación resuelta!"
@export var titulo_dialogo_nivel_completado: String = "¡Nivel completado!"

# Control de diálogos ya mostrados para evitar repetición
var dialogo_posicion_mostrado: bool = false
var dialogo_primera_ecuacion_mostrado: bool = false
var dialogo_nivel_completado_mostrado: bool = false
var dialogo_nivel_inicio_mostrado: bool = false

func _ready():
    # Conectar señales del padre LevelManager si existen
    var level_manager = get_parent()
    if level_manager and level_manager.has_signal("nivel_inicio"):
        level_manager.nivel_inicio.connect(_on_nivel_inicio)

    if level_manager and level_manager.has_signal("jugador_en_posicion"):
        level_manager.jugador_en_posicion.connect(_on_jugador_en_posicion)
    
    if level_manager and level_manager.has_signal("primera_ecuacion_resuelta"):
        level_manager.primera_ecuacion_resuelta.connect(_on_primera_ecuacion_resuelta)
    
    if level_manager and level_manager.has_signal("nivel_completado"):
        level_manager.nivel_completado.connect(_on_nivel_completado)

func getZoom() -> Vector2: 
    return zoom

# Función llamada cuando el jugador llega a una posición específica
func _on_jugador_en_posicion(posicion: Vector2):
    """Maneja el evento cuando el jugador llega a una posición específica"""
    if mostrar_dialogo_jugador_en_posicion and not dialogo_posicion_mostrado:
        mostrar_dialogo(titulo_dialogo_posicion)
        dialogo_posicion_mostrado = true

# Función llamada cuando se resuelve la primera ecuación
func _on_primera_ecuacion_resuelta():
    """Maneja el evento cuando se resuelve la primera ecuación del nivel"""
    if mostrar_dialogo_primera_ecuacion_resuelta and not dialogo_primera_ecuacion_mostrado:
        mostrar_dialogo(titulo_dialogo_primera_ecuacion)
        dialogo_primera_ecuacion_mostrado = true

# Función llamada cuando se inicia el nivel
func _on_nivel_inicio():
    print("LLAMDO NIVEL INICIO")
    """Maneja el evento cuando se completa el nivel"""
    if mostrar_dialogo_nivel_inicio and not dialogo_nivel_inicio_mostrado:
        mostrar_dialogo(titulo_dialogo_nivel_inicio)
        dialogo_nivel_inicio_mostrado = true



# Función llamada cuando se completa el nivel
func _on_nivel_completado():
    """Maneja el evento cuando se completa el nivel"""
    if mostrar_dialogo_nivel_completado and not dialogo_nivel_completado_mostrado:
        mostrar_dialogo(titulo_dialogo_nivel_completado)
        dialogo_nivel_completado_mostrado = true

# Función para mostrar el diálogo
func mostrar_dialogo(titulo: String):
    """Muestra un diálogo con el título especificado"""
    # Aquí puedes implementar la lógica para mostrar el diálogo
    # Por ejemplo, si tienes un sistema de diálogos global:
    if Global.has_method("invoke_dialog"):
        Global.invoke_dialog(LEVEL_DIALOG,titulo)
    else:
        print("Mostrando diálogo: ", titulo)

# Función para resetear el estado de diálogos mostrados
func resetear_dialogos():
    """Resetea el estado de todos los diálogos para permitir que se muestren nuevamente"""
    dialogo_posicion_mostrado = false
    dialogo_primera_ecuacion_mostrado = false
    dialogo_nivel_completado_mostrado = false

# Función para forzar mostrar un diálogo específico
func forzar_dialogo_posicion():
    """Fuerza la visualización del diálogo de posición"""
    if mostrar_dialogo_jugador_en_posicion:
        mostrar_dialogo(titulo_dialogo_posicion)

func forzar_dialogo_primera_ecuacion():
    """Fuerza la visualización del diálogo de primera ecuación"""
    if mostrar_dialogo_primera_ecuacion_resuelta:
        mostrar_dialogo(titulo_dialogo_primera_ecuacion)

func forzar_dialogo_nivel_completado():
    """Fuerza la visualización del diálogo de nivel completado"""
    if mostrar_dialogo_nivel_completado:
        mostrar_dialogo(titulo_dialogo_nivel_completado)