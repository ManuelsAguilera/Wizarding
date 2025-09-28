extends Control

func _ready():
	$CenterContainer/MenuOpciones/PantallaCompleta.button_pressed = true if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN else false
	$CenterContainer/MenuOpciones/VolumenGeneral.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	$CenterContainer/MenuOpciones/VolumenMusica.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Musica")))
	$CenterContainer/MenuOpciones/VolumenSFX.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))


func _on_jugar_pressed():
	# Cambiar escena a escena principal del juego
	get_tree().change_scene_to_file("res://Levels/tutorial2.tscn")

func _on_opciones_pressed():
	# Esconder menu principal y mostrar opciones
	$CenterContainer/BotonesPrincipales.visible = false
	$CenterContainer/MenuOpciones.visible = true
	

func _on_creditos_pressed():
	# Esconder menu principal y mostrar Creditos
	$CenterContainer/BotonesPrincipales.visible = false
	$CenterContainer/MenuCreditos.visible = true


func _on_salir_pressed():
	# Salir del juego
	get_tree().quit()

func _on_volver_pressed():
	# Volver creditos o opciones invisible y mostrar menu principal
	$CenterContainer/MenuCreditos.visible = false
	$CenterContainer/MenuOpciones.visible = false
	$CenterContainer/BotonesPrincipales.visible = true


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
