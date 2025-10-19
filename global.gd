extends Node

# Referencias a controladores
var game_controller:GameController

# Variables de control de nivel
var level_index: int = 0
var last_level: String = ""
var current_level_id: String = ""

# Modos de juego
var dev_mode: bool = false
var dialog_mode: bool = false

# Sistema de guardado
const SAVE_FILE_PATH: String = "user://save_game.save"
const JSON_FILE_PATH: String = "user://save_game.json"
const GENERIC_USER: String = "generic@user.com"
const MIN_AGE: int = 0
const MAX_AGE: int = 150

# Variables de sistema de usuarios
var current_user: String = GENERIC_USER
var users_data: Dictionary = {}
var level_data: Dictionary = {}

signal user_registered(success: bool, message: String)
signal user_logged_in(success: bool, message: String)



func _ready() -> void:
	# Intentar cargar datos guardados de todos los usuarios

	if !check_data_file():
		printerr("No hay datos, cargando usuario generico")

		users_data = {
				GENERIC_USER: {
					"info": {
						"name": "Usuario Genérico",
						"email": GENERIC_USER,
						"age": 0,
						"creation_date": Time.get_datetime_string_from_system(),
						"level_index": 0  
					},
					"levels": {}
				}
			}
	
	level_data = users_data[GENERIC_USER]["levels"]

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
	
	# Guardamos el nuevo level_index
	if users_data.has(current_user):
		users_data[current_user]["info"]["level_index"] = level_index
		save_data()

func set_current_level_id(id:String):
	current_level_id=id

##
func toggle_dev():
	dev_mode= !dev_mode


#Que el nivel guarde los datos de completar un nivel}

###############################################################
## Nuevo sistema para guardado y cargado
###############################################################
# Tener un diccionario de usuarios, y que sus datos de nivel esten asociados,
#  y se carguen solo si hay un usuario compatible
#
# Si se omite, o no se carga el usuario, usar un usuario generico, "generic@user.com"
# Ya que usamos el correo como id de usuario
#
#
# Hacer funciones para ingresar, y cargar datos de un usuario anterior.
#
#
#

# Sistema de manejo de usuarios
func register_user(email: String, name: String, age: int) -> Dictionary:
	# Validar datos
	if email.strip_edges().is_empty() or name.strip_edges().is_empty():
		return {"success": false, "message": "El correo y nombre no pueden estar vacíos"}
	
	if age < MIN_AGE or age > MAX_AGE:
		return {"success": false, "message": "La edad debe estar entre %d y %d años" % [MIN_AGE, MAX_AGE]}
	
	# Verificar si el usuario ya existe
	if users_data.has(email):
		return {"success": false, "message": "Este correo ya está registrado"}
	
	# Crear nuevo usuario
	users_data[email] = {
		"info": {
			"name": name,
			"email": email,
			"age": age,
			"creation_date": Time.get_datetime_string_from_system(),
			"level_index": 0  # Añadimos level_index inicial
		},
		"levels": {}
	}
	
	# Guardar datos y emitir señal
	save_data()
	user_registered.emit(true, "Usuario registrado correctamente")

	#Activar usuario registrado
	set_user(email)
	return {"success": true, "message": "Usuario registrado correctamente"}

func login_user(email: String) -> Dictionary:
	if !users_data.has(email):
		return {"success": false, "message": "Usuario no encontrado"}
	
	set_user(email)
	user_logged_in.emit(true, "Sesión iniciada correctamente")
	return {"success": true, "message": "Sesión iniciada correctamente"}

func set_user(email: String) -> void:
	if email.strip_edges().is_empty():
		return
	
	current_user = email
	if users_data.has(current_user):
		level_data = users_data[current_user]["levels"]
		level_index = users_data[current_user]["info"]["level_index"] 
	else:
		printerr("Intentando establecer un usuario que no existe: ", email)

func get_current_user() -> String:
	return current_user

func get_user_info(email: String = "") -> Dictionary:
	var user_email = email if !email.is_empty() else current_user
	if users_data.has(user_email):
		return users_data[user_email]["info"]
	return {}

func get_all_users() -> Array:
	return users_data.keys()

# Sistema de guardado de niveles
func record_level_data(level: String, moves: int, time: float) -> void:
	if level_data == null:
		level_data = {}

	level_data[level] = {
		"id": level,
		"moves": moves,
		"time": time,
		"completion_date": Time.get_datetime_string_from_system()
	}
	
	last_level = level
	users_data[current_user]["levels"] = level_data

func get_level_data(level: String = "get_all") -> Variant:
	if level == "get_all":
		return level_data
	else:
		return level_data.get(level, null)


# Sistema de persistencia de datos
func save_data() -> void:
	var save_game := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if save_game:
		save_game.store_var(users_data)
		save_game.close()
		print("Datos de usuarios guardados correctamente")
	else:
		printerr("No se ha podido guardar los datos de usuarios")
	
	if dev_mode:
		save_json()

func check_data_file() -> bool:
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		users_data = file.get_var()
		if users_data.has(current_user):
			level_data = users_data[current_user]["levels"]
		else:
			level_data = {}
		file.close()
		print("Datos de usuarios cargados correctamente")
		return true
	else:
		print("No se ha encontrado un archivo de guardado, se creará uno nuevo")
		return false

func save_json() -> void:
	var file := FileAccess.open(JSON_FILE_PATH, FileAccess.WRITE)
	if file:
		var json := JSON.stringify(users_data, "\t")
		file.store_string(json)
		file.close()
		print("Datos exportados a JSON correctamente")
	else:
		printerr("No se ha podido exportar los datos a JSON")
