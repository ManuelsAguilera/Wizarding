extends Node


var game_controller:GameController

var level_index = 0

var dev_mode:bool=false





#Guardado de datos por nivel
var level_data:Dictionary



func _ready():
	if level_data == null:
		level_data = {}

func update_level_index(next:bool=true):

	if next:
		level_index += 1
	else:
		level_index -=1
	
	if level_index >= game_controller.levels.size() or level_index < 0:
		level_index = 0


func toggle_dev():
	dev_mode= !dev_mode


#Que el nivel guarde los datos de completar un nivel
func record_level_data(level:String,moves:int,time:float):
	if level_data == null:
		level_data = {}


	level_data[level] = {
						"id":level,
						"moves":moves,
						"time":time
						}

	print(level_data)
#Obtener los datos de algun nivel guardado

func get_level_data(level:String="get_all"):
	if level == "get_all":
		print("Obtener todo")

	else:
		print(level_data[level])

	
#Guardar persitentemente los datos actuales


