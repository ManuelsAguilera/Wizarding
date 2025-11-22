extends Control


var color: String = "white"


var base_scale:Vector2 = Vector2(1,1)

@onready var label:Label = $username


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
	visible = false
	if Global.current_user != "generic@user.com":
		visible = true

	primary_color=Color("White")
	

	modulation_color = Color(1,1,0.2)
	modulation= 1.5

	self.scale=base_scale

	base_position = position

	label.text = "Jugador: "+Global.users_data[Global.current_user]["info"]["username"]
	self.scale = base_scale
	base_position = self.position


	#Conectar con logged in

	Global.user_logged_in.connect(_on_user_logged_in)


func scaleAnimation():
	var lscale = sin(Time.get_ticks_msec()* scale_speed) * max_scale

	self.scale = base_scale * lscale + base_scale


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

	pass



func changeColor(newColor: String):
	
	color = newColor
	if color == "white":
		primary_color = Color(0.8,0.8,0.95)
	else:
		primary_color = Color(color)


func changeBaseScale(newScale:Vector2):
	base_scale=newScale
	scale=base_scale


func _on_user_logged_in(_success:bool,_msg:String):
	label.text = "jugador: " + Global.current_user
	print("current user: ",Global.current_user)
	visible = true
