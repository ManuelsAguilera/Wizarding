extends EventBlock

class_name GoalBlock


var collision: GoalPostCollision


#Sobreescribir metodos de EventBlock

#Dejar pasar al jugador, pero sigue viendo si entra o no
func set_equation_correct():
	collision.deactivate()


#No ddejar pasar al jugador
func set_equation_incorrect():
	collision.activate()


func _ready():
	collision = get_node("GoalCollision")
	collision.activate()
