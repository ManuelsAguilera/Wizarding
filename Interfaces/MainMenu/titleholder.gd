extends Control


@onready var title:Label = $titlelabel

# Variables para la animación de sombra
const shadow_amplitude: Vector2 = Vector2(10,15) # Amplitud del movimiento de la sombra
const base_shadow_offset = Vector2(-10,0)
const shadow_speed: float = 1.5 # Velocidad de la animación

func _ready():
	# Asegurar que el título tenga configuraciones de fuente
	if title.label_settings == null:
		title.label_settings = LabelSettings.new()
	
	title.label_settings.shadow_size = 20

func shadowAnimation():
	var time = Time.get_ticks_msec() * 0.001 * shadow_speed
	var shadow_offset = base_shadow_offset+Vector2(
		sin(time) * shadow_amplitude.x,
		cos(time * 0.8) * shadow_amplitude.y  # Diferente frecuencia para efecto más orgánico
	)
	title.label_settings.shadow_offset = shadow_offset

func _process(delta):
	
	shadowAnimation()
	pass
