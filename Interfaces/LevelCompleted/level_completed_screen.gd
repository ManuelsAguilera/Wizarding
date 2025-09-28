extends Control

var levels = [
	"res://Levels/tutorial.tscn",
	"res://Levels/tutorial2.tscn",
	"res://Levels/lvl1.tscn",
	"res://Levels/lvl2.tscn",
	"res://Levels/lvl3.tscn"
]



func _on_siguiente_nivel_pressed():
	Global.level_index+=1
	Global.game_controller.change_to_level(Global.game_controller.getLevel(Global.level_index))
	Global.game_controller.change_gui_scene(Global.game_controller.menus["GameUI"])


func _on_volver_menu_pressed():
	# Vuelve al menu orincipal
	Global.game_controller.change_gui_scene(Global.game_controller.menus["MainMenu"])
