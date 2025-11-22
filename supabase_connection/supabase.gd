extends Node
class_name Supabase


signal api_response(tag, success, data)

var env = {}
var last_request_tag : String = ""  # nueva variable para identificar la petición
var dev_mode: bool = false

# Contadores para limitar impresiones de error y evitar logs excesivos
var _error_print_counts : Dictionary = {}
const MAX_ERROR_PRINTS := 5

# Almacena la última respuesta recibida por tag para acceso sincrónico si es necesario
var last_responses : Dictionary = {}

# Almacena el método HTTP usado por tag para poder tratar GETs de forma distinta
var last_request_methods : Dictionary = {}


func _ready():
	load_env()
	# No instanciamos un HTTPRequest global aquí.
	# Ahora se crea un `HTTPRequest` por cada llamada para evitar reuse/concurrencia.

func set_dev_mode(v: bool) -> void:
	dev_mode = v

func _dprint(args) -> void:
	if not dev_mode:
		return
	var out := ""
	for a in args:
		out += str(a) + " "
	print(out.strip_edges())


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





func _on_request_completed(result, response_code, _headers, body, tag: String = "", req: HTTPRequest = null):
	# `tag` y `req` se pasan como binds al conectar la señal.
	var use_tag = tag if tag != "" else last_request_tag

	# Manejo de error de conexión/resultado
	if result != HTTPRequest.RESULT_SUCCESS:
		_printerr_limited(use_tag, "Error en la petición HTTP: " + str(result) + " (tag: " + use_tag + ")")
		emit_signal("api_response", use_tag, false, {"error": "http_result", "code": result})
		last_responses[use_tag] = {"success": false, "error": "http_result", "code": result}
		if req and is_instance_valid(req):
			req.queue_free()
		return

	# Convertir el body a string y luego a JSON
	var text = body.get_string_from_utf8()
	var parsed = JSON.parse_string(text)
	var data = null
	var parse_ok: bool = false

	_dprint(["Request tag:", use_tag, " HTTP code:", response_code])

	# JSON.parse_string may return either a JSONParseResult object or the parsed value
	# depending on engine/version/overloads. Handle both safely.
	if typeof(parsed) == TYPE_ARRAY or typeof(parsed) == TYPE_DICTIONARY:
		data = parsed
		parse_ok = true
	elif typeof(parsed) == TYPE_OBJECT and parsed.get_class() == "JSONParseResult":
		if parsed.error == OK:
			data = parsed.result
			parse_ok = true
		else:
			_printerr_limited(use_tag, "JSON parse error code: " + str(parsed.error))
			parse_ok = false
	else:
		_printerr_limited(use_tag, "Unexpected JSON.parse_string() return type: " + str(typeof(parsed)))
		parse_ok = false

	if parse_ok:
		if data is Array:
			_dprint(["Número de registros:", data.size()])
			var max_preview = min(data.size(), 3)
			for i in range(max_preview):
				_dprint(["Registro[", i, "]:", data[i]])
			if data.size() > max_preview:
				_dprint(["(se omiten ", data.size() - max_preview, " registros en el log)"])
		else:
			_dprint(["Respuesta JSON:", data])

		last_responses[use_tag] = {"success": true, "code": response_code, "data": data}
		var method = last_request_methods.get(use_tag, HTTPClient.METHOD_GET)
		if method == HTTPClient.METHOD_GET:
			_dprint(["Respuesta completa (tag:", use_tag, "):", data])
		emit_signal("api_response", use_tag, true, data)
		if req and is_instance_valid(req):
			req.queue_free()
		return

	# Si no se pudo parsear JSON correctamente
	_printerr_limited(use_tag, "Error parseando JSON. Texto recibido: " + text)
	last_responses[use_tag] = {"success": false, "error": "json_parse", "text": text}
	emit_signal("api_response", use_tag, false, {"error": "json_parse", "text": text})
	if req and is_instance_valid(req):
		req.queue_free()


# Método general para realizar peticiones a la API de Supabase
func api_request(endpoint: String, method, body: Dictionary =  {}, tag: String = "", additional_headers: Array = []) -> void:
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
	# Añadir headers adicionales (por ejemplo Prefer para upsert)
	if additional_headers and additional_headers.size() > 0:
		for h in additional_headers:
			headers.append(h)
	# Si se envía cuerpo, indicar JSON
	var body_data = null
	# Si se proporciona un cuerpo, lo convertimos a JSON y añadimos el header adecuado
	if not body.is_empty():
		headers.append("Content-Type: application/json")
		var body_text = JSON.stringify(body)
		body_data = body_text
	
	# Guardar tag para identificar la respuesta
	last_request_tag = tag
	# Registrar el método usado para esta etiqueta
	last_request_methods[tag] = method
	# Crear un HTTPRequest temporal para esta petición y conectarlo con binds (tag, req)
	var req = HTTPRequest.new()
	add_child(req)

	# Usar Callable.bind evita problemas con la sobrecarga de `connect`.
	req.request_completed.connect(Callable(self, "_on_request_completed").bind(tag, req))

	# Convertir headers a PackedStringArray (requerido por Godot 4.x)
	var pheaders: PackedStringArray = PackedStringArray()
	for h in headers:
		pheaders.append(str(h))

	# Realizar request en la instancia creada usando la firma de HTTPRequest:
	# request(url: String, custom_headers: PackedStringArray = PackedStringArray(), method: Method = 0, request_data: String = "")
	if body_data != null:
		req.request(url, pheaders, method, str(body_data))
	else:
		req.request(url, pheaders, method)


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
	# GET /rest/v1/persona?select=*
	api_request("/rest/v1/persona?select=*", HTTPClient.METHOD_GET, {}, "get_persona")


func get_jugador():
	# GET /rest/v1/jugador?select=*
	api_request("/rest/v1/jugador?select=*", HTTPClient.METHOD_GET, {}, "get_jugador")


func get_level():
	# GET /rest/v1/level?select=*
	api_request("/rest/v1/level?select=*", HTTPClient.METHOD_GET, {}, "get_level")

func add_jugador(jugador_data:Dictionary):
	# POST simple para insertar en jugador
	var endpoint = "/rest/v1/jugador"
	api_request(endpoint, HTTPClient.METHOD_POST, jugador_data, "add_jugador")


func upsert_jugador(jugador_data: Dictionary):
	# Upsert en tabla jugador usando Prefer: resolution=merge-duplicates
	# Asegúrate de incluir el campo primary key (id) si quieres actualizar
	var endpoint = "/rest/v1/jugador"
	var prefer = ["Prefer: resolution=merge-duplicates", "Prefer: return=representation"]
	api_request(endpoint, HTTPClient.METHOD_POST, jugador_data, "upsert_jugador", prefer)


func upsert_jugador_with_tag(jugador_data: Dictionary, tag: String = "upsert_jugador"):
	var endpoint = "/rest/v1/jugador"
	var prefer = ["Prefer: resolution=merge-duplicates", "Prefer: return=representation"]
	api_request(endpoint, HTTPClient.METHOD_POST, jugador_data, tag, prefer)

func add_level(level_data: Dictionary):
	# POST simple para insertar en level
	var endpoint = "/rest/v1/level"
	api_request(endpoint, HTTPClient.METHOD_POST, level_data, "add_level")


func upsert_level(level_data: Dictionary):
	# Upsert en tabla level usando Prefer: resolution=merge-duplicates
	# Incluir id para actualizar; Prefer devuelve la representación insertada/actualizada
	var endpoint = "/rest/v1/level"
	var prefer = ["Prefer: resolution=merge-duplicates", "Prefer: return=representation"]
	api_request(endpoint, HTTPClient.METHOD_POST, level_data, "upsert_level", prefer)


func upsert_level_with_tag(level_data: Dictionary, tag: String = "upsert_level"):
	var endpoint = "/rest/v1/level"
	var prefer = ["Prefer: resolution=merge-duplicates", "Prefer: return=representation"]
	api_request(endpoint, HTTPClient.METHOD_POST, level_data, tag, prefer)


func add_persona(persona_data: Dictionary, tag: String = "add_persona"):
	# Insertar persona y pedir representación para obtener el id
	var endpoint = "/rest/v1/persona"
	var prefer = ["Prefer: return=representation"]
	api_request(endpoint, HTTPClient.METHOD_POST, persona_data, tag, prefer)


func get_data_test():
	# Ahora usa el wrapper
	get_persona()
