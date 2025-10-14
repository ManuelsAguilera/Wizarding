extends Control


const TEST_DIALOG:DialogueResource = preload("res://dialogos/test.dialogue")

func _ready():

	#Conectar al viewport
	var current_zoom = Global.game_controller.getCurrentZoom()


	
	var aspect_container = $AspectContainer

	aspect_container.size = aspect_container.size * (Vector2.ONE/current_zoom)

	var devContainer = $AspectContainer/BotonesDev
	if Global.dev_mode:
		devContainer.visible = true


	
func _on_reset_pressed():
	Global.game_controller.change_to_level(Global.game_controller.getLevel(Global.level_index))
	Global.game_controller.change_gui_scene(Global.game_controller.menus["GameUI"], false, true)


func _on_menu_pressed():
	Global.game_controller.change_zoom(Vector2(1,1))
	Global.game_controller.hide_level(true)
	Global.game_controller.change_gui_scene(Global.game_controller.menus["MainMenu"], false, true)


func _on_next_level_pressed() -> void:
	Global.update_level_index(true)
	Global.game_controller.change_to_level(Global.game_controller.getLevel(Global.level_index))
	Global.game_controller.change_gui_scene(Global.game_controller.menus["GameUI"], false, true)

func _on_last_level_pressed() -> void:
	Global.update_level_index(false)
	Global.game_controller.change_to_level(Global.game_controller.getLevel(Global.level_index))
	Global.game_controller.change_gui_scene(Global.game_controller.menus["GameUI"], false, true)


func _on_help_test_pressed() -> void:

	Global.invoke_dialog(TEST_DIALOG)
