extends Control


@export var level_name ="" #indice del level
@export var level_label = "" # El nombre de el boton
var level_selector_index


@onready var stars:StarContainer = $PanelContainer/MarginContainer/VSplitContainer/Stars
@onready var btn:Button = $PanelContainer/MarginContainer/VSplitContainer/Button

func _ready():

	btn.text = level_label

	level_selector_index = Global.game_controller.levels_by_name[level_name]

	# Si esta disponible
	if level_selector_index > Global.max_level:
		btn.disabled = true
		stars.show_stars(Vector3(0,0,0),false)
		return

	var star_vector = null
	
	if Global.level_data.has(level_name):
		var data = Global.level_data[level_name]
		star_vector = stars.calculate_stars(data.time,data.moves,level_name)
	else:
		star_vector = Vector3(0,0,0)
	
	stars.show_stars(star_vector,false)
	

	


func _on_button_pressed() -> void:
	Global.game_controller.change_gui_scene(Global.game_controller.menus["GameUI"])
	var index = level_selector_index
	Global.game_controller.change_to_level(Global.game_controller.levels[index])
	
