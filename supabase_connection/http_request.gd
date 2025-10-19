extends Node

@onready var http = $HTTPRequest
var env = {}

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





func _on_request_completed(result, response_code, headers, body):
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("Error en la petición HTTP: " + str(result))
		return
		
	# Convertir el body a string y luego a JSON
	var text = body.get_string_from_utf8()
	var json = JSON.parse_string(text)
	
	if json != null:
		# Verificar si es un array (Supabase devuelve array de resultados)
		if json is Array:
			print("Número de registros: ", json.size())
			for record in json:
				print("Registro: ", record)
		else:
			print("Respuesta JSON: ", json)
	else:
		push_error("Error parseando JSON. Texto recibido: " + text)



func get_data_test():
	var url = get_value("SUPABASE_URL", "") + "/rest/v1/player?select=*"
	
	var headers = [
		"apikey: " + get_value("SUPABASE_KEY", "")
	]
	
	http.request(url, headers, HTTPClient.METHOD_GET)
