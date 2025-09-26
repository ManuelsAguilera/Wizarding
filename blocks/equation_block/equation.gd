extends Node2D

class_name TextEquation

# Missing variable declarations
var equation: String = ""
var color: String = "white"
var label: Label

var base_scale:Vector2


const max_scale=0.2
const scale_speed = 5e-7

#Color inicial o principal del texto
var primary_color
#Que tanto variar la modulacion de un color
var modulation_color
var modulation
const max_modulation = 0.2

#Position Animation
var base_position: Vector2
const position_amplitude: Vector2 = Vector2(2, 1) # Ajusta la amplitud según lo que necesites
const position_speed: float = 1.0 # Ajusta la velocidad de la animación


func _ready():
	# Initialize label reference
	label = get_node("Text")  # Assuming the Label node is a direct child

	changeEquation(equation)

	if color == "white":
		primary_color = Color(0.8,0.8,0.95)
	else:
		primary_color = Color(color)
	

	modulation_color = Color(1,1,0.2)
	modulation= 0 

	base_scale= self.scale

	base_position = position 


func scaleAnimation():
	var scale = sin(Time.get_ticks_msec()* scale_speed) * max_scale

	self.scale = base_scale * scale + base_scale


func colorAnimation():
	modulation = sin(Time.get_ticks_msec() * 0.002) * max_modulation
	var modulated_color = primary_color * (Color(1, 1, 1) + modulation_color * modulation)
	label.modulate = modulated_color


func positionAnimation():
	var time = Time.get_ticks_msec() * 0.001 * position_speed
	var offset = Vector2(
		sin(time) * position_amplitude.x,
		cos(time) * position_amplitude.y
	)
	position = base_position + offset

func _process(delta):

	scaleAnimation()

	colorAnimation()

	positionAnimation()



#Metodos publicos


func getEquation()->String:
	return equation


func changeEquation(newEq: String):
	equation = newEq
	if label:
		label.text = equation

func changeColor(newColor: String):
	color = newColor
	if color == "white":
		primary_color = Color(0.8,0.8,0.95)
	else:
		primary_color = Color(color)