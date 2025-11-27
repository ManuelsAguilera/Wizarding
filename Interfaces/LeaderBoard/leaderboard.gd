extends Control

@onready var table:LeaderboardTable = $AspectRatioContainer/CenterContainer/Panel/VBoxContainer/Table

@onready var selector_label:Cell = $AspectRatioContainer/CenterContainer/Panel/VBoxContainer/Panel/VBoxContainer/MarginContainer/HBoxContainer/Margin/Mostrar

func _ready():
	print("Inicio XD")
	# Asegurar que la tabla esté conectada antes de cargar datos
	if not Global.supabase.api_response.is_connected(table._on_supabase_response):
		Global.supabase.api_response.connect(table._on_supabase_response)
	selector_label.type="label"
	selector_label.text_content = "Sin selección"
	selector_label.actualizar_contenido()



func _on_volver_pressed() -> void:
	Global.game_controller.change_gui_scene(Global.game_controller.menus["MainMenu"])





func _on_level_selector_pressed(extra_arg_0:String) -> void:
	table.cargar_leaderboard_nivel(extra_arg_0,15)
	actualizar_selector_label(extra_arg_0)

func actualizar_selector_label(nivel: String):
	"""Actualiza el texto del selector con el nivel actual"""
	if selector_label:
		# Formatear el nombre del nivel de manera más legible
		var nivel_formateado = formatear_nombre_nivel(nivel)
		selector_label.text_content = "Mostrando: " + nivel_formateado
		selector_label.actualizar_contenido()

func formatear_nombre_nivel(nivel: String) -> String:
	"""Convierte el nombre técnico del nivel a uno más legible"""
	# Reemplazar guiones bajos por espacios y capitalizar
	var nombre_formateado = nivel.replace("_", " ")
	
	# Capitalizar primera letra de cada palabra
	var palabras = nombre_formateado.split(" ")
	var resultado = ""
	
	for i in range(palabras.size()):
		var palabra = palabras[i]
		if palabra.length() > 0:
			palabra = palabra.capitalize()
		
		if i > 0:
			resultado += " "
		resultado += palabra
	
	return resultado
