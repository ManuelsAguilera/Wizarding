extends Node


var game_controller:GameController

var level_index = 0
var last_level:String = ""

var current_level_id = ""

var dev_mode:bool=false


var dialog_mode=false

#Guardado de datos por nivel
var level_data:Dictionary



func _ready():

	#Intentar cargar datos guardados
	if !check_data_file():
		# Inicializar diccionario vacío si no se pudo cargar

		level_data = {}

### Dialogos


func invoke_dialog(DIALOG:DialogueResource,title:String=""):

	# Conectar la señal solo si no está ya conectada
	if !DialogueManager.dialogue_ended.is_connected(disable_dialog_mode):
		DialogueManager.dialogue_ended.connect(disable_dialog_mode)
	
	DialogueManager.show_dialogue_balloon(DIALOG, title)
	dialog_mode = true



func disable_dialog_mode(DIALOG:DialogueResource):
	#Desactivar el modo dialogo
	dialog_mode=false

###

func update_level_index(next:bool=true):

	if next:
		level_index += 1
	else:
		level_index -=1
	
	if level_index >= game_controller.levels.size() or level_index < 0:
		level_index = 0


func set_current_level_id(id:String):
	current_level_id=id

##
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

	#Asociar id a nivel si no existe
	last_level=level

	
#Obtener los datos de algun nivel guardado

func get_level_data(level:String="get_all"):
	if level == "get_all":
		return level_data

	else:
		return level_data.get(level, null)

	
#Guardar persitentemente los datos actuales
func save_data():
	var save_game = FileAccess.open("user://save_game.save", FileAccess.WRITE)
	if save_game:
		save_game.store_var(level_data)
		save_game.close()
		print("Juego guardado correctamente")
	else:
		printerr("No se ha podido guardar la partida")
		

func check_data_file():
	var file = FileAccess.open("user://save_game.save", FileAccess.READ)
	if file:
		level_data = file.get_var()
		file.close()
		print("Datos cargados correctamente")
		print(level_data)
		return true
	else:
		print("No se ha encontrado un archivo de guardado, se creará uno nuevo al guardar la partida")
		return false


func save_json():
	var file = FileAccess.open("user://save_game.json", FileAccess.WRITE)
	if file:
		var json = JSON.stringify(level_data)
		file.store_string(json)
		file.close()
		print("Datos exportados a JSON correctamente")
	else:
		printerr("No se ha podido exportar los datos a JSON")