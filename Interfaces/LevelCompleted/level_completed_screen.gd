extends Control


@onready var label: Label = $VBoxContainer/MarginContainer/Label

@onready var volver_menu_btn: Button = $VBoxContainer/VBoxContainer/MarginContainer/VolverMenu
@onready var clasificatoria_btn: Button = $VBoxContainer/VBoxContainer/MarginContainer3/Clasificatorias
@onready var siguiente_nivel_btn: Button = $VBoxContainer/VBoxContainer/MarginContainer2/SiguienteNivel
@onready var estrellas: StarContainer = $VBoxContainer/CenterContainer/ResultContainer/Stars
# Añadidos: referencias a los labels para animarlos
@onready var move_label: Label = $VBoxContainer/CenterContainer/ResultContainer/StatContainer/cantMovimientos
@onready var time_label: Label = $VBoxContainer/CenterContainer/ResultContainer/StatContainer/cantTiempo

@onready var explicacion:Label = $VBoxContainer/CenterContainer/ResultContainer/Explicacion

# Guardar colores originales para restaurar si es necesario
var move_label_original_color: Color
var time_label_original_color: Color


func _ready():
	# Llegaste al final
	if Global.level_index >= Global.game_controller.levels.size() - 1:
		label.text = "Felicidades, eres el wizarding\nAqui esta tu diploma"
		siguiente_nivel_btn.visible = false
		clasificatoria_btn.visible = true
	else:
		Global.update_level_index()

	var level_id = Global.last_level

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

		explicacion.visible = true
		# **NUEVO FLUJO REFACTORIZADO**
		# 1. Cargar nivel y calcular estrellas usando StarContainer
		var stats_result = estrellas.load_and_show_level_stats(float(time), int(moves), level_id)
		
		# 2. Aplicar colores basados en los resultados de StarContainer
		if stats_result["has_time_star"]:
			time_label.modulate = Color(0, 1, 0) # verde
		else:
			time_label.modulate = Color(1, 0, 0) # rojo

		if stats_result["has_moves_star"]:
			move_label.modulate = Color(0, 1, 0) # verde
		else:
			move_label.modulate = Color(1, 0, 0) # rojo

		# 3. Las estrellas ya se están animando automáticamente en StarContainer
		print("estrellas: ", stats_result["total_stars"])
	else:
		printerr("No se han encontrado datos del nivel")
	
	siguiente_nivel_btn.disabled = false
	volver_menu_btn.disabled = false


func format_time(time: float) -> String:
	# Formatea segundos en MM:SS.mmm
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	var milliseconds = int((time - int(time)) * 1000)
	return "%02d:%02d.%03d" % [minutes, seconds, milliseconds]


func _on_siguiente_nivel_pressed():
	
	# Carga el siguiente nivel
	Global.game_controller.change_to_level(Global.game_controller.getLevel(Global.level_index))
	Global.game_controller.change_gui_scene(Global.game_controller.menus["GameUI"])



func _on_volver_menu_pressed():
	# Vuelve al menú principal
	Global.game_controller.change_gui_scene(Global.game_controller.menus["MainMenu"])


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


func _on_clasificatorias_pressed() -> void:
	Global.game_controller.change_gui_scene(Global.game_controller.menus["Leaderboard"])
