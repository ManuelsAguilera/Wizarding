extends Node2D

#Necesitas un config para cambiar variables de cada nivel, en caso de
var config:Config;
var eqManager:EquationManager = get_node("EquationManager");

#Variables del nivel
var level_complete: bool = false;

### Flujo de Level Manager ##################################################
# Level Manager
# - Config
# - BlockManager
	# Padre de todos los genreic Block
	# Notifica a LevelManager cuando encuentra una ecuacion valida
# - Equation Manager
	#- Equation
		# Tiene un bloque el cual tiene un evento que se activa cuando 
		# EquationManager notifica que la ecuacion es correcta
# - MainCamera
	#- Camera2D
	# Control de la camara






func aplicarZoom():
	var cam:Camera2D = get_node("MainCamera")
	if (cam):
		cam.zoom = config.getZoom();

func aplicarConf():
	aplicarZoom()



# Called when the node enters the scene tree for the first time.
func _ready():
	
	config = get_node("Config")
	
	if (config):
		aplicarConf()
	

#Invocado por su hijo, el BlockManager cuando encuentra ecuacion valida
func equation_found():

	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
