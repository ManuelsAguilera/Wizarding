extends PanelContainer
class_name Cell

@onready var content: RichTextLabel = $MarginContainer/Content
@onready var margin_container: MarginContainer = $MarginContainer

@export var padding_horizontal: int = 8
@export var padding_vertical: int = 4

@export var type:String = "normal"

@export var text_content:String = ""

var styles = {
	"header" = {
		"fondo": Color("#572491"),
		"texto": Color("#e6d0a1"),
		"bold": true,
		"tamaño": 14
	},
	"normal" = {
		"fondo": Color("#e6d0a1"),
		"texto": Color("#230f40"),
		"bold": false,
		"tamaño": 11
	},
	"label" = {
		"fondo": Color.WHITE,
		"texto": Color("#230f40"),
		"bold": false,
		"tamaño": 11
	},
# Estilo para posición #1
	"first_place"= {
		"fondo": Color.GOLD,
		"texto": Color("#241326"),
		"bold": true,
		"tamaño": 14
	},

	# Estilo para posición #2
	"second_place"= {
		"fondo": Color.SILVER,
		"texto": Color("#230f40"),
		"bold": true,
		"tamaño": 13
	},


	"third_place" = {
		"fondo": Color(0.8, 0.5, 0.2),  # Bronce
		"texto": Color("#e6d0a1"),
		"bold": true,
		"tamaño": 12
	}
}

func _ready():
	configurar_padding()
	configurar_celda()

	
func configurar_padding():
	"""Configura el padding del MarginContainer"""
	if margin_container:
		margin_container.add_theme_constant_override("margin_left", padding_horizontal)
		margin_container.add_theme_constant_override("margin_right", padding_horizontal)
		margin_container.add_theme_constant_override("margin_top", padding_vertical)
		margin_container.add_theme_constant_override("margin_bottom", padding_vertical)


func configurar_celda():
	"""Configura la celda para comportamiento responsive"""
	# El PanelContainer se ajustará automáticamente al MarginContainer
	# que a su vez se ajusta al Label
	
	if content:
		content.autowrap_mode = TextServer.AUTOWRAP_OFF
		content.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		content.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	actualizar_contenido()
	
func actualizar_contenido():
	
	aplicar_estilo(type)
	set_cell(text_content)

func set_cell(nuevo_texto: String):
	"""Establece el texto de la celda"""
	if content:
		content.text = nuevo_texto


func aplicar_estilo(nombre_estilo: String):
	"""Aplica un estilo específico basado en el nombre del estilo del diccionario"""
	if not styles.has(nombre_estilo):
		print("Advertencia: Estilo '%s' no encontrado. Aplicando estilo normal." % nombre_estilo)
		nombre_estilo = "normal"
	
	var estilo = styles[nombre_estilo]
	
	# Configurar el texto del RichTextLabel
	if content:
		content.add_theme_font_size_override("font_size", estilo.tamaño)
		# Para RichTextLabel usar default_color en lugar de font_color
		content.add_theme_color_override("default_color", estilo.texto)
		
		# Aplicar bold usando BBCode si es necesario
		if estilo.bold:
			content.bbcode_enabled = true
			# Si ya hay texto, aplicar el formato bold
			if content.text != "":
				var texto_actual = content.text
				# Remover tags existentes para evitar duplicados
				texto_actual = texto_actual.replace("[b]", "").replace("[/b]", "")
				content.text = "[b]" + texto_actual + "[/b]"
		else:
			# Habilitar BBCode pero no aplicar formato bold
			content.bbcode_enabled = true
			if content.text.begins_with("[b]") and content.text.ends_with("[/b]"):
				content.text = content.text.replace("[b]", "").replace("[/b]", "")
	
	# Aplicar el fondo al PanelContainer
	aplicar_fondo_personalizado(estilo.fondo, estilo.texto)


	

func aplicar_fondo_personalizado(color_fondo: Color, color_borde: Color):
	"""Aplica un fondo personalizado al PanelContainer"""
	var estilo_fondo = StyleBoxFlat.new()
	
	# Color de fondo
	estilo_fondo.bg_color = color_fondo
	
	# Configurar bordes
	estilo_fondo.border_width_left = 1
	estilo_fondo.border_width_right = 1
	estilo_fondo.border_width_top = 1
	estilo_fondo.border_width_bottom = 1
	estilo_fondo.border_color = color_borde.darkened(0.3)
	
	# Esquinas ligeramente redondeadas
	estilo_fondo.corner_radius_top_left = 2
	estilo_fondo.corner_radius_top_right = 2
	estilo_fondo.corner_radius_bottom_left = 2
	estilo_fondo.corner_radius_bottom_right = 2
	
	# Aplicar el estilo
	add_theme_stylebox_override("panel", estilo_fondo)
