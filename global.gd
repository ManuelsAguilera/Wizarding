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

#Conexion con base de datos remota

const SupabaseLoader = preload("res://supabase_connection/supabase.tscn")
@export var supabase:Supabase = null

# Mapas temporales para relacionar data remota
var _persona_by_id: Dictionary = {}
var _jugador_by_id: Dictionary = {}

# Variables de sistema de usuarios
var current_user: String = GENERIC_USER
var current_jugador_id: int = -1
var current_persona_id: int = 4
var users_data: Dictionary = {}
var level_data: Dictionary = {}
var _sync_lock: bool = false

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

	if SupabaseLoader:
		print("instanciando")
		supabase = SupabaseLoader.instantiate()
		add_child(supabase)
		# Conectar señal para recibir respuestas asíncronas
		supabase.connect("api_response", Callable(self, "_on_supabase_response"))

	else:
		printerr("No se pudo instanciar nodo conexion remota.")


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
func login_user(email: String) -> Dictionary:
	# Intentar cargar datos desde remoto si está disponible
	if supabase != null:
		# Hacemos una búsqueda por correo exacto en la tabla persona
		var q_email = _encode_query_value(email)
		var endpoint = "/rest/v1/persona?correo=eq." + q_email + "&select=*"
		# Tag: find_persona:<email> — manejado en _on_supabase_response
		supabase.api_request(endpoint, HTTPClient.METHOD_GET, {}, "find_persona:" + email)
		return {"success": true, "message": "Buscando usuario en remoto..."}
	else:
		# Si no hay conexión remota, usar datos locales si existen
		if !users_data.has(email):
			return {"success": false, "message": "Usuario no encontrado localmente y Supabase no disponible"}
	
		user_logged_in.emit(true, "Sesión iniciada (local)")
		return {"success": true, "message": "Sesión iniciada localmente"}


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

	return {"success": true, "message": "Usuario registrado correctamente"}



func set_user(email: String,persona_id:int) -> void:
	if email.strip_edges().is_empty():
		return
	
	current_user = email
	current_persona_id = persona_id
	if users_data.has(current_user):
		level_data = users_data[current_user]["levels"]
		print("level_index:", users_data[current_user]["info"]["level_index"])
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
func record_level_data(level: String, moves: int, time: float, level_name: String = "") -> void:
	# Registra los datos del nivel en memoria; ahora guarda también level_name
	if level_data == null:
		level_data = {}

	level_data[level] = {
		"id": level,
		"moves": moves,
		"time": time,
		"level_name": level_name,
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
		print("datos de usuario: ",users_data)
		print("Datos de usuarios guardados correctamente")
	else:
		printerr("No se ha podido guardar los datos de usuarios")
	
	save_json()
	# Opcional: sincronizar con supabase si está disponible
	if supabase != null:
		# Solo sincronizar el usuario actual
		sync_user_to_supabase(current_user, true)

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


##############################################
## Integración con Supabase
##############################################




func _on_supabase_response(tag: String, success: bool, data) -> void:
	# Manejar respuestas de las distintas peticiones remotas
	if !success:
		printerr("Supabase returned error for tag:", tag, "->", data)
		return

	# Manejar búsquedas específicas por fragmento de correo
	if tag.begins_with("find_persona:"):
		# data esperado: array de personas que coinciden
		if data is Array and data.size() > 0:
			var persona = data[0]
			var pid = str(persona.get("id", ""))
			_persona_by_id[pid] = persona
			var correo = persona.get("correo", "")
			if correo != "":
				# Primero comprobar si ya existe localmente y actualizar
				var name = persona.get("nombre", "")
				if name.strip_edges().is_empty():
					name = correo.split("@")[0]
				var age = int(persona.get("edad", 0))
				if users_data.has(correo):
					# Actualizar campos locales mínimos
					users_data[correo]["info"]["name"] = name
					users_data[correo]["info"]["email"] = correo
					users_data[correo]["info"]["age"] = age
				else:
					# Registrar usuario localmente (esto guarda y establece el usuario)
					register_user(correo, name, age)


				# Asegurar que el usuario está activo
				set_user(correo,pid.to_int())
				# Refrescar jugador y levels relacionados
				if supabase != null:
					supabase.get_jugador()
					supabase.get_level()
				user_logged_in.emit(true, "Usuario cargado y activado desde Supabase")
		else:
			printerr("No se encontró ninguna persona para el fragmento:", tag.replace("find_persona:", ""))
		return

	match tag:
		"get_persona":
			# Data esperado: Array de personas
			_persona_by_id.clear()
			if data is Array:
				for persona in data:
					var pid = str(persona.get("id", ""))
					_persona_by_id[pid] = persona
					# Crear/actualizar usuario local con correo como clave
					var correo = persona.get("correo", "")
					if correo != "":
						users_data[correo] = users_data.get(correo, {
							"info": {},
							"levels": {}
						})
						users_data[correo]["info"]["name"] = persona.get("nombre", "")
						users_data[correo]["info"]["email"] = correo
						users_data[correo]["info"]["age"] = persona.get("edad", 0)
			else:
				printerr("Unexpected persona payload:", data)

		"get_jugador":
			# Data esperado: Array de jugadores
			_jugador_by_id.clear()
			if data is Array:
				for jugador in data:
					var jid = str(jugador.get("id", ""))				
					
					_jugador_by_id[jid] = jugador
					if current_persona_id == jugador.get("persona_id",0):
						current_jugador_id = jid.to_int()
						level_index = jugador.get("level_index",0)
						print("[Aviso, aqui es donde se actualiza level_index en get_jugador lol] ", level_index)
					
					
					# Relacionar con persona (persona_id -> correo)
					var persona_id = str(jugador.get("persona_id", ""))
					var correo = ""
					if _persona_by_id.has(persona_id):
						correo = _persona_by_id[persona_id].get("correo", "")
					# Si no existe el usuario local, crear entrada mínima
					if correo == "":
						correo = "generic@user.com"
					users_data[correo] = users_data.get(correo, {
						"info": {},
						"levels": {}
					})
					users_data[correo]["info"]["username"] = jugador.get("username", "")
					users_data[correo]["info"]["level_index"] = jugador.get("level_index", 0)
					users_data[correo]["info"]["jugador_id"] = jugador.get("id", null)
			else:
				printerr("Unexpected jugador payload:", data)

		"get_level":
			# Data esperado: Array de levels
			if data is Array:
				# Construir un mapa global de levels por id
				var remote_levels := {}
				for lvl in data:
					var lid = str(lvl.get("id", ""))
					remote_levels[lid] = {
						"id": lid,
						"moves": lvl.get("moves", 0),
						"time": lvl.get("time", ""),
						"level_name": lvl.get("level_name", "")
					}
				# Para simplicidad, si current_user está en users_data, asignar estos niveles a su nivel_data
				# (si prefieres otro comportamiento, lo adaptamos)
				if users_data.has(current_user):
					users_data[current_user]["levels"] = remote_levels
					if current_user == GENERIC_USER:
						level_data = users_data[current_user]["levels"]
				else:
					# Si no existe, asignarlos a generic
					users_data[GENERIC_USER] = users_data.get(GENERIC_USER, {"info": {}, "levels": remote_levels})
					level_data = users_data[GENERIC_USER]["levels"]
			else:
				printerr("Unexpected level payload:", data)

		_:
			# Otros tags (upsert/add) — guardar respuesta en último registro
			print("Supabase response (", tag, "):", data)


func sync_user_to_supabase(email: String, only_last: bool = true) -> void:
	# Evitar reentradas concurrentes
	if _sync_lock:
		print("sync_user_to_supabase: ya en progreso, ignorando llamada duplicada")
		return
	_sync_lock = true

	if supabase == null:
		printerr("Supabase no inicializado, no se puede sincronizar")
		_sync_lock = false
		return

	if !users_data.has(email):
		printerr("Usuario no encontrado para sincronizar:", email)
		_sync_lock = false
		return

	print("[AVISO] sync_user_to_supabase llamado para:", email, "only_last=", only_last)

	var info = users_data[email]["info"]
	# Construir jugador payload
	var jugador_payload := {}
	if info.has("jugador_id"):
		var jid = _to_int_id(info["jugador_id"])
		if jid != null:
			jugador_payload["id"] = jid
	jugador_payload["username"] = info.get("username", email.split("@")[0])
	jugador_payload["level_index"] = info.get("level_index", 0)

	# Intentar obtener persona_id existente
	var persona_id = current_persona_id
	
	if persona_id != null:
		var pid_int = _to_int_id(persona_id)
		if pid_int != null:
			jugador_payload["persona_id"] = pid_int
		else:
			jugador_payload["persona_id"] = persona_id

	# Hacer upsert en jugador
	print("[AVISO] supabase.upsert_jugador payload:", jugador_payload)
	supabase.upsert_jugador(jugador_payload)

	# Subir niveles del usuario
	var user_levels = users_data[email].get("levels", {})
	var lids_to_sync := []
	only_last = true
	if only_last:
		if last_level != "" and user_levels.has(last_level):
			lids_to_sync = [last_level]
		else:
			print("[AVISO] sync_user_to_supabase: no hay ultimo nivel para sincronizar")
			_sync_lock=false
			return
	else:
		lids_to_sync = user_levels.keys()

	print("[AVISO] lids_to_sync:", lids_to_sync)
	for lid in lids_to_sync:
		# imprimir informacion de cada elemento en user level
		print("#---------------#")
		print("Level ID:", lid)
		print("Level Data:", user_levels[lid])
		print("#---------------#")
		var lvl = user_levels[lid]
		var level_payload := {}
		# Mantener id numérico si es posible (convertir o eliminar si no es válido)
		var raw_id = lvl.get("id", lid)
		var id_int = _to_int_id(raw_id)
		if id_int != null:
			level_payload["id"] = id_int
		# Asegurar que moves sea entero
		level_payload["moves"] = int(lvl.get("moves", 0))
		# FORMATEAR el tiempo para que sea compatible con el tipo time de Postgres (HH:MM:SS[.ms])
		level_payload["time"] = _format_time_for_supabase(lvl.get("time", ""))
		# Enviar level_name exactamente como está (no forzar un fallback con str(lid))
		level_payload["level_name"] = lvl.get("id", "")
		#Enviar fk de jugador
		
		print("[AVISO] Current user: ",current_user)
		print("[AVISO] Current user id: ",current_jugador_id)
		if current_jugador_id < 0:
			level_payload["jugador_id"] = 0
		else:
			level_payload["jugador_id"] = current_jugador_id
		# Debug: imprimir payload antes del upsert
		print("DEBUG supabase.upsert_level payload:", level_payload)
		# Llamada al upsert de level
		supabase.upsert_level(level_payload)
		print("[AVISO MOSTRAR LIDS_TO_SYNC] ",lids_to_sync)

	_sync_lock = false
func save_json() -> void:
	var file := FileAccess.open(JSON_FILE_PATH, FileAccess.WRITE)
	if file:
		var json := JSON.stringify(users_data, "\t")
		file.store_string(json)
		file.close()
		print("Datos exportados a JSON correctamente")
	else:
		printerr("No se ha podido exportar los datos a JSON")


func _encode_query_value(val: String) -> String:
	# Codificación mínima para incluir en la query de Supabase (percent-encoding básico)
	var s = val.replace("%", "%25")
	s = s.replace(" ", "%20")
	s = s.replace("@", "%40")
	s = s.replace("+", "%2B")
	s = s.replace("/", "%2F")
	return s

# Nueva función auxiliar para sanitizar ids (int/real/string -> int o null)
func _to_int_id(val) -> Variant:
	# Devuelve un int si puede convertir, o null si no es convertible
	if val == null:
		return null
	var t := typeof(val)
	if t == TYPE_INT:
		return val
	elif t == TYPE_FLOAT:
		return int(val)
	elif t == TYPE_STRING:
		var s: String = String(val).strip_edges()
		# "1" -> entero, "1.0" -> float -> int, otros -> null
		if s.is_valid_int():
			return int(s)
		elif s.is_valid_float():
			return int(s.to_float())
		else:
			return null
	else:
		return null

# Convierte un valor numérico/str de segundos a "HH:MM:SS[.ms]" aceptable por Postgres time.
func _format_time_for_supabase(val) -> String:
	# val puede ser float (segundos), int (segundos) o string ("HH:MM:SS" o numérico)
	if val == null:
		return ""
	var total_seconds: float = 0.0
	var t := typeof(val)
	if t == TYPE_FLOAT or t == TYPE_INT:
		total_seconds = float(val)
	elif t == TYPE_STRING:
		var s: String = String(val).strip_edges()
		# Si ya tiene ":", asumimos formato válido y lo devolvemos tal cual
		if s.find(":") != -1:
			return s
		if s.is_valid_float():
			total_seconds = s.to_float()
		else:
			# no es numérico ni formato con ":", devolver cadena tal cual
			return s
	else:
		return String(val)

	var hours = int(total_seconds / 3600.0)
	var minutes = int(fmod(total_seconds, 3600.0) / 60.0)
	var seconds_f = fmod(total_seconds, 60.0)
	var secs = int(seconds_f)
	var frac = seconds_f - secs
	var ms3 = int(round(frac * 1000)) # milisegundos (3 decimales)
	var frac_str = ""
	if ms3 > 0:
		frac_str = "." + ("%03d" % [ms3])
		# quitar ceros finales si los hubiera
		while frac_str.ends_with("0"):
			frac_str = frac_str.substr(0, frac_str.length() - 1)
		if frac_str == ".":
			frac_str = ""

	return "%02d:%02d:%02d%s" % [hours, minutes, secs, frac_str]
