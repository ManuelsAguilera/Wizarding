extends ScrollContainer
class_name LeaderboardTable

@onready var grid = $CenterContainer/GridContainer




var columns = 1


var table_data:Array = []
var table_cells:Array[Cell] = []

var current_data_title = ""


func _ready() -> void:

	# Conectar la señal de respuesta de Supabase
	Global.supabase.api_response.connect(_on_supabase_response)
	
	table_data = ["Esperando que llegue la información.."]
	grid.columns = columns

	insert_data()


############################
#Seleccion de niveles
















######### Carga de tabla y datos remotos


func cargar_leaderboard_nivel(nombre_nivel: String, limite: int = 10):
	if nombre_nivel != current_data_title:
		current_data_title=nombre_nivel
		Global.supabase.get_players_by_level(nombre_nivel, limite, "leaderboard_nivel")

#Drop the cells, and data
func clear_table():
	# Limpiar celdas del array
	for cell in table_cells:
		if cell and is_instance_valid(cell):
			cell.queue_free()
	
	# Limpiar todos los hijos del grid
	for child in grid.get_children():
		child.queue_free()
	
	# Limpiar el array
	table_cells.clear()


# Insertar data en table_cells
func insert_data():
	print("insertando")
	clear_table()
	
	if table_data.is_empty():
		print("No hay datos para insertar en la tabla")
		return
	
	# Calcular número de filas basado en el total de elementos y columnas
	var total_rows = ceil(float(table_data.size()) / float(columns))
	
	# Crear celdas para cada posición en la tabla
	for row_index in total_rows:
		for col_index in columns:
			var data_index = row_index * columns + col_index
			var cell_content = ""
			var cell_type = "normal"
			
			# Obtener contenido si existe
			if data_index < table_data.size():
				cell_content = str(table_data[data_index])
			
			# Determinar el tipo de celda
			if row_index == 0:  # Primera fila - headers
				cell_type = "header"
			elif col_index == 0 and row_index > 0:  # Primera columna (excluyendo header) - posiciones
				cell_type = determinar_tipo_celda_ranking(row_index)
			
			# Crear y configurar la celda
			var nueva_celda = crear_celda(cell_content, cell_type)
			table_cells.append(nueva_celda)
			grid.add_child(nueva_celda)

func crear_celda(contenido: String, tipo: String = "normal") -> Cell:
	"""Crea una nueva celda con el contenido y tipo especificados"""
	var celda_scene = preload("res://Interfaces/LeaderBoard/Cell.tscn")
	var nueva_celda: Cell = celda_scene.instantiate()
	
	# Configurar la celda
	nueva_celda.text_content = contenido
	nueva_celda.type = tipo
	
	return nueva_celda

func determinar_tipo_celda_ranking(posicion: int) -> String:
	"""Determina el tipo de celda basado en la posición en el ranking"""
	match posicion:
		1:
			return "first_place"
		2:
			return "second_place" 
		3:
			return "third_place"
		_:
			return "normal"



#Respuesta api
func _on_supabase_response(tag: String, success: bool, data):
	match tag:
		"leaderboard_nivel":
			if success and data is Array:
				print(data)
				print("procesado")
				procesar_datos_leaderboard(data)
				
			else:
				print("Error cargando leaderboard del nivel: ", data)

func procesar_datos_leaderboard(datos_api: Array):
	"""Convierte los datos de la API al formato de la tabla y actualiza la vista"""
	# Limpiar datos anteriores
	table_data.clear()
	
	print("datos_borrados")
	
	# Agregar headers
	table_data.append("Posición")
	table_data.append("Usuario") 
	table_data.append("Movimientos")
	table_data.append("Tiempo")
	
	# Procesar cada jugador
	for i in range(datos_api.size()):
		var jugador = datos_api[i]
		
		# Posición en el ranking (empezando desde 1)
		table_data.append(str(i + 1))
		
		# Nombre del usuario (ajustar según la estructura de tu API)
		var nombre_usuario = jugador.get("username", "Usuario")
		nombre_usuario = truncar_nombre_usuario(nombre_usuario)
		table_data.append(str(nombre_usuario))
		
		# Movimientos (ajustar según el nombre del campo en tu API)
		var movimientos = jugador.get("movimientos", jugador.get("moves", "N/A"))
		table_data.append(str(movimientos))
		
		# Tiempo (ajustar según el nombre del campo en tu API)
		var tiempo = jugador.get("tiempo", jugador.get("time", "N/A"))
		table_data.append(str(tiempo))
	
	# Actualizar columnas para el nuevo formato
	columns = 4
	grid.columns = columns
	
	# Insertar los datos procesados en la tabla
	insert_data()

func truncar_nombre_usuario(nombre: String, limite: int = 25) -> String:
	"""Trunca el nombre de usuario intentando mantener palabras completas"""
	if nombre.length() <= limite:
		return nombre
	
	# Si el nombre tiene espacios, intentar truncar por palabras
	if " " in nombre:
		var palabras = nombre.split(" ")
		var nombre_truncado = ""
		
		# Agregar palabras mientras no se supere el límite
		for palabra in palabras:
			var nombre_temporal = nombre_truncado
			if nombre_temporal.is_empty():
				nombre_temporal = palabra
			else:
				nombre_temporal += " " + palabra
			
			# Si agregar esta palabra supera el límite, parar
			if nombre_temporal.length() > limite:
				break
			
			nombre_truncado = nombre_temporal
		
		# Si logramos un nombre truncado válido, usarlo
		if not nombre_truncado.is_empty() and nombre_truncado.length() <= limite:
			return nombre_truncado
	
	# Si no hay espacios o no se pudo truncar por palabras, cortar a 25 caracteres
	return nombre.substr(0, limite)
