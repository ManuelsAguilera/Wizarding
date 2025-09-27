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
var equation_correct: bool;


func _ready() -> void:
	equation_correct = false;

#Estas se tienen que hacer override
func _trigger_solved():
	pass


func _trigger_unsolved():
	pass

#Esta la ejecuta su padre, no es necesario sobreescribir
func trigger(solved_value: bool) -> void:
	if equation_correct == solved_value:
		return # si es el mismo valor no cambiar
	
	equation_correct = solved_value
	
	if equation_correct:
		_trigger_solved()
	else:
		_trigger_unsolved()



