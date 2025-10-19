extends Node

@onready var http = $HTTPRequest


func _ready():
	var save_path = "user://save_game.json"
	if not FileAccess.file_exists(save_path):
		push_error("Archivo de seiv no encontrado: " + save_path)
		return

	# Leer todo el JSON de save
	var file = FileAccess.open(save_path, FileAccess.READ)
	var all_saves = JSON.parse_string(file.get_as_text())
	file.close()

	if not all_saves:
		push_error("Error parseando JSON del archivo de save")
		return

	# Convertir a string y enviar al backend
	var body = JSON.stringify(all_saves)
	var headers = ["Content-Type: application/json"]

	http.request_completed.connect(_on_request_completed)
	var error = http.request("http://127.0.0.1:5000/save", headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("Error en la peti HTTP")

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json:
		print("Respuesta del backend:", json)
	else:
		push_error("Error parseando respuesta del backend")
