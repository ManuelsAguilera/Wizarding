extends HBoxContainer
class_name StarContainer

# StarContainer se encarga de:
# 1. Cargar las estadísticas del nivel completado
# 2. Calcular si las estadísticas superan los thresholds para obtener estrellas
# 3. Mostrar y animar las estrellas obtenidas
# 4. Proveer información sobre el estado de las estrellas a otros componentes

# Exporta las texturas para poder asignarlas desde el Inspector.
# Se usan preloads como valores por defecto.
@export var star_filled: Texture2D = preload("res://assets/star/Star_filled.png")
@export var star_void: Texture2D = preload("res://assets/star/Star_void.png")

# Referencias por nivel
var time_reference: Dictionary = {
	"tuto_1": 65,
	"tuto_2": 65,
	"level_1":65,
	"level_2":77,
	"level_3":105,
	"level_4":270,
	"level_5":320,
	"level_6": 555,
	"test":999999.0
}

var moves_reference: Dictionary = {
	"tuto_1": 20,
	"tuto_2": 20,
	"level_1":20,
	"level_2":26,
	"level_3":39,
	"level_4":73,
	"level_5":115,
	"level_6": 145,
	"test":999999.0
}




# Nodos que muestran la estrella
var stars: Array[TextureRect] = []

# Variables para almacenar los resultados del último cálculo
var last_stars: Vector3
var last_level_id: String

var is_animating: bool = false

func _ready() -> void:
	for child in get_children():
		if child is TextureRect:
			stars.append(child)

# Muestra las estrellas según el Vector3 (x,y,z -> 0/1).
# Resetea las texturas y lanza la animación con 0.5s entre cada estrella.
func show_stars(shown: Vector3) -> void:
	if is_animating:
		return

	# Resetear a vacío
	for child in get_children():
		if child is TextureRect:
			child.texture = star_void

	# Iniciar animación
	_animate_stars(shown)


# Función principal para cargar estadísticas, calcular y mostrar estrellas
func load_and_show_level_stats(time: float, moves: int, level_id: Variant) -> Dictionary:
	# Convertir level_id a String para consistencia
	var id_str: String = str(level_id)
	last_level_id = id_str
	
	# Calcular estrellas
	last_stars = calcular_estrellas(time, moves, id_str)
	
	# Mostrar las estrellas con animación
	show_stars(last_stars)
	
	# Retornar información para que level_completed_screen pueda usar
	return {
		"stars": last_stars,
		"has_time_star": has_time_star(id_str),
		"has_moves_star": has_moves_star(id_str),
		"total_stars": cant_stars()
	}

# Calcula 3 estrellas: completado, tiempo y movimientos.
func calcular_estrellas(time: float, moves: int, id: String) -> Vector3:
	var estrellas := Vector3(0, 0, 0)

	# Primera estrella: siempre otorgada por completar el nivel
	estrellas.x = 1

	# Estrella de tiempo (medio)
	if time_reference.has(id):
		var time_thr: float = float(time_reference[id])
		if time <= time_thr:
			estrellas.y = 1
 
	# Estrella de movimientos (última)
	if moves_reference.has(id):
		var moves_thr: int = int(moves_reference[id])
		if moves <= moves_thr:
			estrellas.z = 1

	return estrellas

# Verifica si el tiempo supera el threshold para obtener la estrella
func has_time_star(level_id: String) -> bool:
	if not time_reference.has(level_id):
		return false
	return last_stars.y == 1

# Verifica si los movimientos superan el threshold para obtener la estrella
func has_moves_star(level_id: String) -> bool:
	if not moves_reference.has(level_id):
		return false
	return last_stars.z == 1

# Retorna el número total de estrellas obtenidas
func cant_stars() -> int:
	return int(last_stars.x + last_stars.y + last_stars.z)

# Función interna que anima la aparición de cada estrella con delay de 0.5s.
func _animate_stars(shown: Vector3) -> void:
	is_animating = true
	var vals: Array = [int(shown.x), int(shown.y), int(shown.z)]
	print_debug("Animating")

	for i in range(3):
		
		var star = stars[i]
		if star is TextureRect:
			if vals[i] == 1:
				star.texture = star_filled
				
			star.visible = true

		await get_tree().create_timer(0.6).timeout
	is_animating = false
