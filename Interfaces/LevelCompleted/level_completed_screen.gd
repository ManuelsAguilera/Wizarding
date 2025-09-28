extends Control


func _on_siguiente_nivel_pressed():
	# Por el momento solo pasara al nivel 2
	get_tree().change_scene_to_file("res://Levels/lvl2.tscn")


func _on_volver_menu_pressed():
	# Vuelve al menu orincipal
	get_tree().change_scene_to_file("res://Interfaces/MainMenu/MainMenu.tscn")
