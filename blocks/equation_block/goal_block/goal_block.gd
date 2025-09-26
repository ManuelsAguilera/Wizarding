extends EventBlock

class_name GoalBlock


var collision: GoalPostCollision


#Sobreescribir metodos de EventBlock

#Dejar pasar al jugador, pero sigue viendo si entra o no
func trigger():
	equation_correct = !equation_correct
	if equation_correct:
		collision.activate()
	else:
		collision.deactivate()

func _ready():
	collision = get_node("GoalCollision")

	collision.activate()
