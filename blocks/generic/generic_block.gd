extends CharacterBody2D

class_name GenericBlock




@onready var particleEffect = $DustParticles


#Variables exportadas de sprites

@onready var sprite = $sprite
@export var spriteName:String="default"
@export var frame:int = 0


var typeBlock:String=""

const Tile_Size:Vector2 = Vector2(64,64)

const ANIMATIONSPEED = 8

var initial_position = Vector2()
var is_moving=false
var percent_moved = 0.0
var direction:Vector2 = Vector2()



func snap_to_grid():
	#Revisar si ya esta snapped pq sino se bugea
	var snapped_pos = global_position.snapped(Tile_Size)

	if global_position == snapped_pos:
		return
	else:
		global_position = snapped_pos+ Vector2(1,-1)*Tile_Size/2
		

func setTypeBlock():
	if spriteName == "default":
		typeBlock="invalid"
	elif spriteName == "num":
		if frame>9 and frame < 0:
			#Comprobar de que este en los frames de numeros
			typeBlock="invalid"
		else:
			typeBlock="num"


	elif spriteName in [ "+", "-", "/", "*"]:
			typeBlock="operator"

	elif spriteName == "=":
		typeBlock="="
	elif spriteName in ["x", "y", "z"]:
		typeBlock="variable"

	else:
		typeBlock="invalid"

# Called when the node enters the scene tree for the first time.
func _ready():
	setSprite()
	snap_to_grid()
	initial_position = global_position

	setTypeBlock()	


#Para identificar objeto
func isABlock():
	pass


func getTypeBlock():
	return typeBlock

#Subtipos, o obtener string exacto que represente el bloque
func getTypeOperation():
	if typeBlock=="operator":
		return spriteName
	else:
		return null

func getTypeNumber():
	if typeBlock=="num":
		return frame
	else:
		return null


func getTypeVariable():
	if typeBlock=="variable":
		return spriteName
	else:
		return null

func setSprite():
	
	
	sprite.play(spriteName)
	sprite.frame = frame
	sprite.pause()



#Funciones de movimiento del bloque


func set_direction(dir):
	direction = dir

func is_block_moving():
	return is_moving

func _physics_process(delta):

	if is_moving and direction != Vector2.ZERO:
		move(delta)
	else:
		is_moving=false

func push(playerDirection):
	if not is_moving:
		particleEffect.emitting=false #Reiniciar particula
		particleEffect.emitting=true
		direction = playerDirection
		is_moving = true
		percent_moved = 0.0
		initial_position = global_position



func move(delta):
	percent_moved += ANIMATIONSPEED*delta
	if percent_moved >= 1:		
		global_position = initial_position + (Tile_Size * direction)
		is_moving = false
		direction = Vector2.ZERO
		percent_moved = 0.0
		print("Moving")
	else:
		global_position = initial_position + (Tile_Size * direction*percent_moved)
func _process(delta):
	pass
