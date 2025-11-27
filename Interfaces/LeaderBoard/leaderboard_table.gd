extends ScrollContainer
class_name LeaderboardTable

@onready var grid = $CenterContainer/GridContainer




@export var columns = 3


var table_data:Array = []
var table_cells:Array[Cell] = []




func _ready() -> void:
	print("testdata")
	#test_data

	table_data = ["Usuario","Movimientos","Tiempo","vicente","-1","-99"]
	grid.columns = columns

	insert_data()


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
	var celda_scene = preload("res://Interfaces/LeaderBoard/cell.tscn")
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
