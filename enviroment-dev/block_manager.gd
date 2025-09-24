extends Node2D

# Guardar los bloques en un mapa segun su posicion Vector2

# Usar un dictionary: 	
@export var map_size = Vector2(10,10)

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

	for i in blocklist:
		print(i.getTypeBlock()," ",i.getSnappedPosition())

#busca en una direccion dada todos los bloques conectados
func searchBlocks(inital_pos:Vector2, dir:Vector2):
	pass


func _process(delta):
	
	#Buscar abajo y derecha de los bloques si es que hay mas

	for variable in variableBlocks:
		var v_pos = variable.getSnappedPosition()
		var v_down = v_pos + Vector2(0,1)
		var v_right = v_pos + Vector2(1,0)

		#Revisar en la lista si hay algun bloque abajo o derecha
		#Si hay, seguir esa direccion y añadir a lista de concatBlocks
		#No importa si no es eficiente buscar en la lista, porque nunca
		#habra muchos bloques en pantalla

		for block in blocklist:
			var b_pos = block.getSnappedPosition()
			if b_pos == v_down:
				print("Block connected:", variable.getTypeVariable(), " to ", block.getTypeBlock())
			if b_pos == v_right:
				print("Block connected:", variable.getTypeVariable(), " to ", block.getTypeBlock())
