extends EventBlock

class_name BarrierBlock



## Referencia al cuerpo físico de la barrera que controla colisiones
var body: BarrierBody

# ============================================================================
# VARIABLES DE ESTADO
# ============================================================================



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
	body.deactivate()
	


func _trigger_unsolved():
	body.activate()

