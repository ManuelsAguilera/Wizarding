extends Control

# Partir el juego desde el menu
func _ready():
	%Jugar.pressed.connect(jugar)
	%Salir.pressed.connect(salir_del_juego)
	

# Presionar boton de jugar
func jugar():
	get_tree().change_scene_to_file("res://devworld.tscn")

func salir_del_juego():
	get_tree().quit()


func _on_opciones_pressed():
	#Corrigiendo una linea, para testear sistema de prs
	pass
