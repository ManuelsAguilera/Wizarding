extends Node2D


class_name EquationBlock


@export var equation: String = "default"
@export var color: String = "white"

var text: TextEquation

var event_blocks: Array = []
func _ready():
	text = get_node("TextEquation")
	if text:
		text.changeEquation(equation)
		text.color = color
		text._ready()

	#Buscar todos los EventBlock hijos
	for child in get_children():
		if child is EventBlock:
			event_blocks.append(child)
			print("Event block found: ", child)



