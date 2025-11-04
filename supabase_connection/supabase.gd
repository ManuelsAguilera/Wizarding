extends Node
class_name Supabase


signal api_response(tag, success, data)

@onready var http = $HTTPRequest
var env = {}
var last_request_tag : String = ""  # nueva variable para identificar la petición

# Contadores para limitar impresiones de error y evitar logs excesivos
var _error_print_counts : Dictionary = {}
const MAX_ERROR_PRINTS := 5

# Almacena la última respuesta recibida por tag para acceso sincrónico si es necesario
var last_responses : Dictionary = {}

# Almacena el método HTTP usado por tag para poder tratar GETs de forma distinta
var last_request_methods : Dictionary = {}


func _ready():
	load_env()
	http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	get_data_test()

## ENVIROMENT VARIABLES

func load_env() -> void:
	var file = FileAccess.open("res://.env", FileAccess.READ)
	if file:
		while !file.eof_reached():
			var line = file.get_line()
			if line.begins_with("#") or line.strip_edges().is_empty():
				continue
			
			var key_value = line.split("=")
			if key_value.size() == 2:
				var key = key_value[0].strip_edges().replace("\"", "")
				var value = key_value[1].strip_edges().replace("\"", "")
				env[key] = value

func get_value(key: String, default: String = "") -> String:
	return env.get(key, default)





func _on_request_completed(result, response_code, _headers, body):
	# Manejo de error de conexión/resultado
	if result != HTTPRequest.RESULT_SUCCESS:
		_printerr_limited(last_request_tag, "Error en la petición HTTP: " + str(result) + " (tag: " + last_request_tag + ")")
		# Emitir señal con información de error para que quien llame pueda manejarlo
		emit_signal("api_response", last_request_tag, false, {"error": "http_result", "code": result})
		# Guardar la última respuesta para consultas sincrónicas
		last_responses[last_request_tag] = {"success": false, "error": "http_result", "code": result}
		return
	
	# Convertir el body a string y luego a JSON
	var text = body.get_string_from_utf8()
	# Intentamos parsear JSON (manteniendo compatibilidad con cómo se usaba antes)
	var json = JSON.parse_string(text)
	var data = null
	
	# Mostrar etiqueta de la petición para saber qué respuesta llegó
	print("Request tag:", last_request_tag, " HTTP code:", response_code)
	
	if json != null:
		data = json
		# Ver detalle de la respuesta sin saturar logs: si es array, imprimir resumen y hasta 3 registros
		if data is Array:
			print("Número de registros:", data.size())
			var max_preview = min(data.size(), 3)
			for i in range(max_preview):
				print("Registro[", i, "]:", data[i])
			if data.size() > max_preview:
				print("(se omiten ", data.size() - max_preview, " registros en el log)")
		else:
			print("Respuesta JSON:", data)
		# Guardar y emitir la respuesta exitosa
		last_responses[last_request_tag] = {"success": true, "code": response_code, "data": data}
		# Si la petición fue un GET, imprimir la respuesta completa (útil para debug)
		var method = last_request_methods.get(last_request_tag, HTTPClient.METHOD_GET)
		if method == HTTPClient.METHOD_GET:
			print("Respuesta completa (tag:", last_request_tag, "):", data)
		else:
			# Para otros métodos dejamos el comportamiento resumido (preview) ya registrado
			pass
		emit_signal("api_response", last_request_tag, true, data)
		
	else:
		_printerr_limited(last_request_tag, "Error parseando JSON. Texto recibido: " + text)
		last_responses[last_request_tag] = {"success": false, "error": "json_parse", "text": text}
		emit_signal("api_response", last_request_tag, false, {"error": "json_parse", "text": text})


# Método general para realizar peticiones a la API de Supabase
func api_request(endpoint: String, method: int = HTTPClient.METHOD_GET, body: Dictionary =  {}, tag: String = "") -> void:
	# Construir URL base
	var base_url = get_value("SUPABASE_URL", "")

	if base_url == "":
		push_error("SUPABASE_URL no definido en .env")
		return
	var url = base_url + endpoint
	
	# Construir headers (incluye clave y autorización)
	var key = get_value("SUPABASE_KEY", "")
	var headers : Array = [
		"apikey: " + key,
		"Authorization: Bearer " + key
	]
	# Si se envía cuerpo, indicar JSON
	var body_data = null
	# Si se proporciona un cuerpo, lo convertimos a JSON y añadimos el header adecuado
	if not body.is_empty():
		headers.append("Content-Type: application/json")
		var body_text = JSON.stringify(body)
		body_data = body_text.to_utf8()
	
	# Guardar tag para identificar la respuesta
	last_request_tag = tag
	# Registrar el método usado para esta etiqueta
	last_request_methods[tag] = method
	
	# Realizar request (ssl_validate_domain = false para compatibilidad; ajustar según necesidad)
	if body_data != null:
		http.request(url, headers, method, false, body_data)
	else:
		http.request(url, headers, method)


# Devuelve la última respuesta conocida para una etiqueta dada (útil para comprobaciones sincrónicas)
func get_last_response(tag: String):
	return last_responses.get(tag, null)


# Imprime errores usando printerr, pero limitando la cantidad de mensajes por etiqueta para evitar logs excesivos
func _printerr_limited(tag: String, msg: String) -> void:
	var key = str(tag)
	var count = _error_print_counts.get(key, 0)
	if count < MAX_ERROR_PRINTS:
		printerr(msg)
		_error_print_counts[key] = count + 1
		if _error_print_counts[key] == MAX_ERROR_PRINTS:
			printerr("Se alcanzó el límite de impresiones de error (" + str(MAX_ERROR_PRINTS) + ") para la etiqueta: " + key)
	# Si ya alcanzamos el límite, no imprimir más


# Wrappers específicos

func get_persona():

	api_request("/rest/v1/persona", HTTPClient.METHOD_GET, {}, "get_persona")


func get_jugador():

	api_request("/rest/v1/jugador", HTTPClient.METHOD_GET, {}, "get_jugador")

func add_jugador(jugador_data:Dictionary):

	var endpoint = "/rest/v1/jugador"

	api_request(endpoint, HTTPClient.METHOD_POST, jugador_data, "add_jugador")

func add_level(level_data: Dictionary):

	var endpoint = "/rest/v1/level"

	api_request(endpoint, HTTPClient.METHOD_POST, level_data, "add_level")


func get_data_test():
	# Ahora usa el wrapper
	get_persona()
