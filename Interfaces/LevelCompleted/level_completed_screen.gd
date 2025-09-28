extends Control

var levels = [
	"res://Levels/tutorial.tscn",
	"res://Levels/tutorial2.tscn",
	"res://Levels/lvl1.tscn",
	"res://Levels/lvl2.tscn",
	"res://Levels/lvl3.tscn"
]

var actual_level = 0

func _on_siguiente_nivel_pressed():
	Global.game_controller.change_scene_to_packed("")


func _on_volver_menu_pressed():
	# Vuelve al menu orincipal
	get_tree().change_scene_to_file("res://Interfaces/MainMenu/MainMenu.tscn")
