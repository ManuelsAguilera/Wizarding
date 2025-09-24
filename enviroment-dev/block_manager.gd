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


#Solo buscar cadenas despues de que un bloque se haya movido
var chains_searched = false


func _ready():
	
	for i in get_children():
		if i is GenericBlock:
			blocklist.append(i)

			if i.getTypeBlock() == "variable":
				variableBlocks.append(i)


	for i in blocklist:
		print(i.getTypeBlock()," ",i.getSnappedPosition())


# Metodo para que GenericBlock hijo llame cuando se mueva
func notify_block_moved():
	chains_searched = false




#busca en una direccion dada todos los bloques conectados
func searchBlocks(initial_pos: Vector2, dir: Vector2) -> Array:
	var cadena = []
	var current_pos = initial_pos + dir
	
	# Buscar bloque en la posición actual
	for block in blocklist:
		if block.getSnappedPosition() == current_pos:
			cadena.append(block)
			# Continuar búsqueda recursiva
			cadena += searchBlocks(current_pos, dir)
			break

	return cadena




func generar_cadenas():

	#Vaciar lista de cadenas
	concatBlocks.clear()

	for variable in variableBlocks:
		var v_pos = variable.getSnappedPosition()
		var v_down = v_pos + Vector2(0,1)
		var v_right = v_pos + Vector2(1,0)

		#Revisar en la lista si hay algun bloque abajo o derecha
		#Si hay, seguir esa direccion y añadir a lista de concatBlocks
		#No importa si no es eficiente buscar en la lista, porque nunca
		#habra muchos bloques en pantalla

		for block in blocklist:
			#Candidato a estar conectado
			var candidate = [variable,block]
			var b_pos = block.getSnappedPosition()
			if b_pos == v_down:
				concatBlocks.append( candidate + searchBlocks(b_pos, Vector2(0,1)))
			elif b_pos == v_right:
				concatBlocks.append( candidate + searchBlocks(b_pos, Vector2(1,0)))

			# Si no hay bloques conectados, no anadir nada



func printCadenas():
	print("Cadenas encontradas:")
	for c in concatBlocks:
		var s = ""
		for b in c:
			var type = b.getTypeBlock()


			s +=  type + " "

			if type == "num":
				s += str(b.getTypeNumber()) + ","
			elif type == "var":
				s += b.getTypeVariable() + ","
			elif type == "op":
				s += b.getTypeOperation() + ","

		print("[",s,"]")

func _process(delta):
	
	#Buscar abajo y derecha de los bloques si es que hay mas

	if not chains_searched:
		chains_searched = true
		generar_cadenas()

		printCadenas()
		
	#Vaciar lista para la siguiente iteracion
