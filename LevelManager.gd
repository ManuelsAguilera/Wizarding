extends Node2D

@onready var eq:Equation = $FinalEq


# Called when the node enters the scene tree for the first time.
func _ready():
	eq.changeEquation("1+X=3X")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
