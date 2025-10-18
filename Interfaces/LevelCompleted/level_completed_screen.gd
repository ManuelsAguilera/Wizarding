extends Control


@onready var label: Label = $Label
@onready var siguiente_nivel_btn: Button = $VBoxContainer/SiguienteNivel

# Referencias por nivel
var time_reference: Dictionary = {
	"test": 60.0
}

var moves_reference: Dictionary = {
	"test": 30
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

	if level_data != null:
		var moves = str(level_data["moves"])
		var time = str(format_time(level_data["time"]))
		move_label.text = moves
		time_label.text = time

		# Calcular estrellas
		var estrellas = calcular_estrellas(level_data["time"], level_data["moves"])
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
