extends Node2D

# Guardar los bloques en un mapa segun su posicion Vector2

# Usar un dictionary: 	
@export var map_size = Vector2(10,10)



 
var blockmap = Dictionary()

#Lista de lista de bloques encadenados.
var concatBlocks = []

#Todos los bloques, para buscarlos facilmente
var blocklist = []

#Lista de variables, que son candidatos a cadenas.
var variableBlocks = []


func _ready():
	
	for i in get_children():
		if i is GenericBlock:
			blocklist.append(i)

			if i.getTypeBlock() == "variable":
				variableBlocks.append(i)

	print("all",blocklist)
	print("vars",variableBlocks)
