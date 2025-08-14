extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()

func _draw():
	var white : Color = Color.WHITE

	draw_circle(Vector2.ZERO,50.0,white,filled=false)
