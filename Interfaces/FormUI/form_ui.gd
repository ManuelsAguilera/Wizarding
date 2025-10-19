extends Control


@onready var registro_cont:Control = $RegistroContainer
@onready var ingresar_cont:Control = $IngresoContainer

@onready var nombre:LineEdit  = $RegistroContainer/CampoNombre
@onready var edad:LineEdit  = $RegistroContainer/CampoEdad
@onready var correo_registro:LineEdit  = $RegistroContainer/CampoCorreo

@onready var correo_ingreso:LineEdit  = $IngresoContainer/VFlowContainer/CampoCorreo

@onready var registrar_btn:Button = $RegistroContainer/Registrar
@onready var ingresar_btn:Button = $IngresoContainer/Ingresar
@onready var cambiar_btn:Button = $Cambiar

@onready var error_label:Label = $Error

@onready var ventana_advertencia:AcceptDialog = $AcceptDialog


#	Para AcceptDialog pueda saber si guardar o omitir

var accion_actual: String = ""

#Modos son registrar, y ingresar
var modo_formulario = "registrar"

func _ready() -> void:
	ventana_advertencia.confirmed.connect(_on_ventana_confirmada)

	set_formulario()

	set_cambiar_btn()


#Para cambiar visibilidad segun tipo
func set_formulario():
	if modo_formulario == "registrar":
		registro_cont.visible=true
		ingresar_cont.visible=false
	elif modo_formulario == "ingresar":
		registro_cont.visible=false
		ingresar_cont.visible=true

func set_cambiar_btn():
	if modo_formulario == "registrar":
		cambiar_btn.text = "Ya ingrese mis datos"
	elif modo_formulario == "ingresar":
		cambiar_btn.text = "Registrate aqui"


func _on_cambiar_pressed() -> void:
	if modo_formulario == "registrar":
		modo_formulario = "ingresar"
	elif modo_formulario == "ingresar":
		modo_formulario = "registrar"

	set_formulario()
	set_cambiar_btn()

##
func notificar_error(error:String):
	error_label.visible=true
	error_label.text = error


func _es_correo_registro_valido(email:String):
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

	# Validar correo_registro
	if not _es_correo_registro_valido(correo_registro.text):
		notificar_error("El correo_registro electrónico no es válido")
		return {}
	campos["correo_registro"] = correo_registro.text.strip_edges()

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


func _on_registrar_pressed():
	var datos = revisar_campos()

	if datos.is_empty():
		registrar_btn.disabled = false
	else:
		ventana_advertencia.dialog_text = "¿Estás seguro que usaste el mismo correo_registro que el formulario?"
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
	correo_registro.text = ""
	error_label.visible = false


func _on_ingresar_pressed() -> void:
	if not _es_correo_registro_valido(correo_ingreso.text):
		notificar_error("El correo_registro electrónico no es válido")
	pass # Replace with function body.
