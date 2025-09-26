extends Node2D

class_name LevelManager


#Necesitas un config para cambiar variables de cada nivel, en caso de
var config:Config;
var eqManager:EquationManager;

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
	eqManager = get_node("EquationManager");
	if (config):
		aplicarConf()
	

func reset_solutions():
	#Llamado por BlockManager cuando un bloque se mueve
	#Resetea todas las soluciones de los bloques EquationBlock
	if (eqManager):
		for child in eqManager.get_children():
			if child is EquationBlock:
				child.triggerEvents(false) # Notificar que la ecuacion ya no es correcta
				print("LevelManager: Resetting solution for equation: ", child.equation)
	else:
		print("LevelManager: No EquationManager found to reset solutions!")



#Invocado por su hijo, el BlockManager cuando encuentra ecuacion valida
func equation_found(equation:String):
	print("LevelManager: Equation found: ", equation)
	if (eqManager):
		var correct:bool = eqManager.verify_equation(equation)
		if (correct):
			print("LevelManager: Equation is correct!")
		else:
			print("LevelManager: Equation is incorrect.")
	else:
		print("LevelManager: No EquationManager found!")



func on_player_reach_goal():
	if not level_complete:
		level_complete = true
		print("LevelManager: Level Complete!")
		#Aqui puedes agregar logica para finalizar el nivel, como cargar la siguiente escena o mostrar una pantalla de victoria.






# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
