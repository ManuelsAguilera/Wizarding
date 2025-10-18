extends HBoxContainer
class_name StarContainer

# Exporta las texturas para poder asignarlas desde el Inspector.
# Se usan preloads como valores por defecto.
@export var star_filled: Texture2D = preload("res://assets/star/Star_filled.png")
@export var star_void: Texture2D = preload("res://assets/star/Star_void.png")

# Nodos que muestran la estrella
var stars: Array[TextureRect] = []


var is_animating: bool = false

func _ready() -> void:
	for child in get_children():
		if child is TextureRect:
			stars.append(child)

# Muestra las estrellas según el Vector3 (x,y,z -> 0/1).
# Resetea las texturas y lanza la animación con 0.5s entre cada estrella.
func show_stars(shown: Vector3) -> void:
	if is_animating:
		return

	# Resetear a vacío
	for child in get_children():
		if child is TextureRect:
			child.texture = star_void

	# Iniciar animación
	_animate_stars(shown)


# Función interna que anima la aparición de cada estrella con delay de 0.5s.
func _animate_stars(shown: Vector3) -> void:
	is_animating = true
	var vals: Array = [int(shown.x), int(shown.y), int(shown.z)]
	print("Animating")

	for i in range(3):
		
		var star = stars[i]
		if star is TextureRect:
			if vals[i] == 1:
				star.texture = star_filled
				
			star.visible = true

		await get_tree().create_timer(0.6).timeout
	is_animating = false
