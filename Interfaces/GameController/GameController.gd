class_name GameController extends Node

@export var world_2d: Node2D
@export var gui: Control

var levels:Array = [
	"res://Levels/tutorial.tscn",
	"res://Levels/tutorial2.tscn",
	"res://Levels/lvl1.tscn",
	"res://Levels/lvl2.tscn",
	"res://Levels/lvl3.tscn",
]


var menus:Dictionary = {
	"MainMenu":"res://Interfaces/MainMenu/MainMenu.tscn",
	"GameUI":"res://Interfaces/GameUI/GameUI.tscn",
	"LevelCompleted":"res://Interfaces/LevelCompleted/LevelCompletedScreen.tscn"
}


var camera:Camera2D

var current_gui_scene:Control
var current_lvl:Node2D

func _ready() -> void:
	Global.game_controller = self
	camera = $World2D/Camera2D
	print("GameController: Camera assigned",camera)
	change_gui_scene(menus["MainMenu"])



##Getters

func get_camera() -> Camera2D:
	print("GameController: Getting camera",camera)

	return self.camera
	

func getLevel(index:int):
	return levels[index]




##Changing scenes

func change_zoom(zoom:Vector2):
	if camera != null:
		camera.zoom = zoom
	else:
		print("GameController: Warning - No Camera found in the scene!")


func change_gui_scene(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	if current_gui_scene != null:
		if delete:
			current_gui_scene.queue_free()
		elif keep_running:
			current_gui_scene.visible = false
		else:
			gui.remove_child(current_gui_scene)
	var new = load(new_scene).instantiate()
	gui.add_child(new)
	current_gui_scene = new

func change_to_level(new_scene: String, delete: bool = true, keep_running: bool = false) -> void:
	

	if current_lvl != null:
		if delete:
			current_lvl.queue_free()
		elif keep_running:
			current_lvl.visible = false
		else:
			gui.remove_child(current_lvl)
	var new = load(new_scene).instantiate()
	world_2d.add_child(new)
	current_lvl = new


func hide_level(delete: bool = false):
	if current_lvl != null:
		if delete:
			current_lvl.queue_free()
		else:
			current_lvl.visible = false
