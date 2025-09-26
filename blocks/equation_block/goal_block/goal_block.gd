extends EventBlock

class_name GoalBlock


var body: GoalPostBody

var activated:bool = false

#Sobreescribir metodos de EventBlock

#Dejar pasar al jugador, pero sigue viendo si entra o no
func trigger(solved_value:bool) -> void:
	activated = solved_value

	
	if activated:
		body.activate()
	else:
		body.deactivate()

func _ready():
	body = get_node("GoalBody")
	
	body.deactivate()
