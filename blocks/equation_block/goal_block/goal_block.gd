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
var goal_reached: bool = false


# ============================================================================
# MÉTODOS DE INICIALIZACIÓN
# ============================================================================

## Inicialización del GoalBlock
func _ready() -> void:
	super._ready()  # Llamar al _ready() del padre (EventBlock)
	body = get_child(0)




# ============================================================================
# IMPLEMENTACIÓN DE EVENTBLOCK (OVERRIDE)
# ============================================================================

func _trigger_solved():
	body.activate()
	


func _trigger_unsolved():
	body.deactivate()
