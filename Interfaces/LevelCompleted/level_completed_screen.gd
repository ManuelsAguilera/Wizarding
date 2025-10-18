extends Control


@onready var label: Label = $Label
@onready var siguiente_nivel_btn: Button = $VBoxContainer/SiguienteNivel
@onready var star_container: StarContainer = $CenterContainer/ResultContainer/StarContainer
# Añadidos: referencias a los labels para animarlos
@onready var move_label: Label = $CenterContainer/ResultContainer/StatContainer/cantMovimientos
@onready var time_label: Label = $CenterContainer/ResultContainer/StatContainer/cantTiempo

# Guardar colores originales para restaurar si es necesario
var move_label_original_color: Color
var time_label_original_color: Color

# Referencias por nivel
var time_reference: Dictionary = {
	"tuto_1": 60.0,
	"tuto_2": 60.0,
	"level_1":24.0*3,
	"level_2":23.0*3,
	"level_3":31.55*3,
	"level_4":55.5*3,
	"level_5":(1 * 60 + 15.8) *3,
	"level_6": (1 * 60 + 15.8) *3,
	"test":999999.0
}

var moves_reference: Dictionary = {
	"tuto_1": 2,
	"tuto_2": 10,
	"level_1":21*2,
	"level_2":22*2,
	"level_3":30*2,
	"level_4":51*2,
	"level_5":72*2,
	"level_6":80*2,
	"test":999999
}


func _ready():
	# Llegaste al final
	if Global.level_index >= Global.game_controller.levels.size() - 1:
		label.text = "¡Has completado Wizarding! Vuelve al menú principal"
		siguiente_nivel_btn.visible = false
		Global.update_level_index()

	var level_id = Global.last_level

	# labels de movimientos y tiempo
	var move_label = $CenterContainer/ResultContainer/StatContainer/cantMovimientos
	var time_label = $CenterContainer/ResultContainer/StatContainer/cantTiempo

	# Obtener datos del nivel pasado
	var level_data = Global.get_level_data(level_id)

	# Guardar colores originales al inicio
	move_label_original_color = move_label.modulate
	time_label_original_color = time_label.modulate

	if level_data != null:
		var moves = level_data["moves"]
		var time = level_data["time"]
		# Iniciar animaciones de los valores y esperar a que terminen

		await animate_time(float(time), 0.5)
		await animate_moves(int(moves), 0.8)

		# Normalizar id a String para comprobaciones
		var id_str: String = str(level_id)

		# Cambiar color a verde si se supera (mejora) la referencia
		if time_reference.has(id_str):
			var time_thr: float = float(time_reference[id_str])
			if time <= time_thr:
				time_label.modulate = Color(0, 1, 0) # verde
			else:
				time_label.modulate = Color(1, 0, 0) # red

		if moves_reference.has(id_str):
			var moves_thr: int = int(moves_reference[id_str])
			if moves <= moves_thr:
				move_label.modulate = Color(0, 1, 0) # verde
			else:
				move_label.modulate = Color(1, 0, 0) # red

		# Calcular estrellas (usar level_id para referencias correctas)
		var estrellas = calcular_estrellas(time, moves, level_id)
		star_container.show_stars(estrellas)

		print("estrellas: ", estrellas)
	else:
		printerr("No se han encontrado datos del nivel")


func format_time(time: float) -> String:
	# Formatea segundos en MM:SS.mmm
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	var milliseconds = int((time - int(time)) * 1000)
	return "%02d:%02d.%03d" % [minutes, seconds, milliseconds]


func _on_siguiente_nivel_pressed():
	Global.update_level_index()
	# Carga el siguiente nivel
	Global.game_controller.change_to_level(Global.game_controller.getLevel(Global.level_index))
	Global.game_controller.change_gui_scene(Global.game_controller.menus["GameUI"])

	if Global.dev_mode:
		Global.save_data()


func _on_volver_menu_pressed():
	# Vuelve al menú principal
	Global.game_controller.change_gui_scene(Global.game_controller.menus["MainMenu"])


func calcular_estrellas(time: float, moves: int, id: Variant = "test") -> Vector3:
	# Calcula 3 estrellas: completado, tiempo y movimientos.
	# Asegura que la clave usada para buscar en los diccionarios sea una String.
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


# Anima un entero (movimientos) desde 0 hasta target en 'duration' segundos.
func animate_moves(target: int, duration: float = 0.8) -> void:
	# Evitar divisiones por cero
	if duration <= 0:
		move_label.text = str(target)
		return

	var start: int = 0
	var steps: int = max(1, int(duration / 0.02)) # ~50 fps
	for i in range(steps + 1):
		var t: float = float(i) / steps
		var val: int = int(lerp(start, target, t))
		move_label.text = str(val)
		# esperar pequeño intervalo
		if i < steps:
			await get_tree().create_timer(duration / steps).timeout

# Anima un tiempo (segundos float) desde 0.0 hasta target_seconds y actualiza con format_time.
func animate_time(target_seconds: float, duration: float = 1.0) -> void:
	if duration <= 0:
		time_label.text = format_time(target_seconds)
		return

	var start: float = 0.0
	var steps: int = max(1, int(duration / 0.02))
	for i in range(steps + 1):
		var t: float = float(i) / steps
		var current: float = lerp(start, target_seconds, t)
		time_label.text = format_time(current)
		if i < steps:
			await get_tree().create_timer(duration / steps).timeout
