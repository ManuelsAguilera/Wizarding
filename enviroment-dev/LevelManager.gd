extends Node2D

#Necesitas un config para cambiar variables de cada nivel, en caso de
var config:Config;

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
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
