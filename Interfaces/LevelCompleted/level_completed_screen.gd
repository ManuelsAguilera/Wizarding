extends Control


@onready var label = $Label
@onready var siguiente_nivel_btn = $VBoxContainer/SiguienteNivel


func _ready():
	#Llegaste al final
	
	if Global.level_index >= Global.game_controller.levels.size()-1:
		label.text = "¡Has completado Wizarding! Vuelve al menú principal"
		siguiente_nivel_btn.visible = false
		Global.update_level_index()


	var level_id = Global.last_level



	#labels de movimientos y tiempo

	var move_label = $CenterContainer/ResultContainer/StatContainer/cantMovimientos
	var time_label = $CenterContainer/ResultContainer/StatContainer/cantTiempo



	#Obtener datos del nivel pasado

	var level_data = Global.get_level_data(level_id)



	if level_data != null:
		var moves = str(level_data["moves"]) 
		var time = str(format_time(level_data["time"]))
		move_label.text = moves
		time_label.text = time

		#Calcular estrellas
		#TODO
	else:
		printerr("No se han encontrado datos del nivel")
	

func format_time(time:float) -> String:
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
	# Vuelve al menu orincipal
	Global.game_controller.change_gui_scene(Global.game_controller.menus["MainMenu"])
