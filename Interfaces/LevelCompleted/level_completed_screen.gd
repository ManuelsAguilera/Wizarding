extends Control


@onready var label = $Label
@onready var siguiente_nivel_btn = $VBoxContainer/SiguienteNivel


func _ready():
	#Llegaste al final
	
	if Global.level_index >= Global.game_controller.levels.size()-1:
		label.text = "¡Has completado Wizarding! Vuelve al menú principal"
		siguiente_nivel_btn.visible = false
		Global.update_level_index()
	

func _on_siguiente_nivel_pressed():
	Global.update_level_index()
	# Carga el siguiente nivel
	Global.game_controller.change_to_level(Global.game_controller.getLevel(Global.level_index))
	Global.game_controller.change_gui_scene(Global.game_controller.menus["GameUI"])



func _on_volver_menu_pressed():
	# Vuelve al menu orincipal
	Global.game_controller.change_gui_scene(Global.game_controller.menus["MainMenu"])
