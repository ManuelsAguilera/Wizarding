extends Control

func _ready():
	$VSplitContainer/CenterContainer/MenuOpciones/PantallaCompleta.button_pressed = true if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN else false
	$VSplitContainer/CenterContainer/MenuOpciones/VolumenGeneral.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	$VSplitContainer/CenterContainer/MenuOpciones/VolumenMusica.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Musica")))
	$VSplitContainer/CenterContainer/MenuOpciones/VolumenSFX.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))

	# Desactivar botones de juego
	var jugar_btn  = $VSplitContainer/CenterContainer/BotonesPrincipales/Jugar

	#Modo dev
	if Global.dev_mode:
		var dev_btn = $VSplitContainer/CenterContainer/BotonesPrincipales/NivelTest
		dev_btn.visible = true

func _on_jugar_pressed():
	# Cambiar escena a escena principal del juego
	Global.game_controller.change_gui_scene(Global.game_controller.menus["LevelSelection"])


func _on_opciones_pressed():
	# Esconder menu principal y mostrar opciones
	$VSplitContainer/CenterContainer/BotonesPrincipales.visible = false
	$VSplitContainer/CenterContainer/MenuOpciones.visible = true
	

func _on_creditos_pressed():
	# Esconder menu principal y mostrar Creditos
	$VSplitContainer/CenterContainer/BotonesPrincipales.visible = false
	$VSplitContainer/CenterContainer/MenuCreditos.visible = true


func _on_salir_pressed():
	# Salir del juego
	get_tree().quit()

func _on_volver_pressed():
	# Volver creditos o opciones invisible y mostrar menu principal
	$VSplitContainer/CenterContainer/MenuCreditos.visible = false
	$VSplitContainer/CenterContainer/MenuOpciones.visible = false
	$VSplitContainer/CenterContainer/BotonesPrincipales.visible = true


func _on_nivel_test_pressed():
	Global.level_index = -1
	Global.game_controller.change_to_level(Global.game_controller.getTestLevel())
	Global.game_controller.change_gui_scene(Global.game_controller.menus["GameUI"])



func _on_pantalla_completa_toggled(toggled_on: bool) -> void:
	if (toggled_on):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)


func _on_volumen_general_value_changed(value: float):
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)


func _on_volumen_musica_value_changed(value: float):
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Musica"), value)


func _on_volumen_sfx_value_changed(value: float):
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), value)






func _on_formulario_pressed() -> void:
	Global.game_controller.change_gui_scene(Global.game_controller.menus["Form"])


func _on_guardar_pressed():
	Global.save_data()


func _on_clasificatoria_pressed() -> void:
	Global.game_controller.change_gui_scene(Global.game_controller.menus["Leaderboard"])
