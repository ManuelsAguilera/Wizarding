extends Control

@onready var nombre:LineEdit  = $CampoNombre
@onready var edad:LineEdit  = $CampoEdad
@onready var correo:LineEdit  = $CampoCorreo


@onready var error_label:Label = $Error

@onready var ventana_advertencia:AcceptDialog = $AcceptDialog


#	Para AcceptDialog pueda saber si guardar o omitir

var accion_actual: String = ""
func _ready() -> void:
	ventana_advertencia.confirmed.connect(_on_ventana_confirmada)

func notificar_error(error:String):
	error_label.visible=true
	error_label.text = error


func _es_correo_valido(email:String):
	var regex = RegEx.new()
	regex.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$")
	return regex.search(email) != null

func revisar_campos():

	var campos  = {}

	# Validar nombre
	if nombre.text.strip_edges().is_empty():
		notificar_error("El nombre no puede estar vacío")
		return {}
	campos["nombre"] = nombre.text.strip_edges()

	# Validar edad
	if not edad.text.is_valid_int():
		notificar_error("La edad debe ser un número válido")
		return {}
	var edad_num = edad.text.to_int()
	if edad_num < 0 or edad_num > 150:
		notificar_error("La edad debe estar entre 0 y 150 años")
		return {}
	campos["edad"] = edad_num

	# Validar correo
	if not _es_correo_valido(correo.text):
		notificar_error("El correo electrónico no es válido")
		return {}
	campos["correo"] = correo.text.strip_edges()

	error_label.visible = false
	return campos



## Chequeo en tiempo real

func _on_campo_correo_text_changed(new_text:String) -> void:
	error_label.visible = false


func _on_campo_edad_text_changed(new_text:String) -> void:
	
	if not new_text.is_empty() and not new_text.is_valid_int():
		edad.text = new_text.substr(0, new_text.length() - 1)
		edad.caret_column = edad.text.length()


## Botones y advertencia


func _on_guardar_pressed():
	var datos = revisar_campos()

	if datos.is_empty():
		var guardar = $Guardar
		guardar.disabled = false
	else:
		ventana_advertencia.dialog_text = "¿Estás seguro que usaste el mismo correo que el formulario?"
		accion_actual = "guardar" 

		ventana_advertencia.popup_centered()


func _on_omitir_pressed():
	ventana_advertencia.dialog_text = "¿Estás seguro que deseas omitir?\nSi estas completando la encuesta pon tus datos."
	accion_actual = "omitir" 
	ventana_advertencia.popup_centered()
	


func _on_ventana_confirmada():
	match accion_actual:
		"guardar":
			_procesar_guardado()
		"omitir":
			_procesar_omision()



func _procesar_guardado() -> void:
	var datos = revisar_campos()
	if not datos.is_empty():
		print("Guardando datos:", datos)
		# Aquí puedes agregar la lógica de guardado
		limpiar_campos()

func _procesar_omision() -> void:
	limpiar_campos()

func limpiar_campos() -> void:
	nombre.text = ""
	edad.text = ""
	correo.text = ""
	error_label.visible = false
