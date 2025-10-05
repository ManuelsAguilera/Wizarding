extends Control


func _ready():
	
	var nextlvl = $BotonesNivel/NextLevel
	var lastlvl = $BotonesNivel/LastLevel
	



	if Global.dev_mode:
		nextlvl.visible = true
		lastlvl.visible = true

	
func _on_reset_pressed():
	Global.game_controller.change_to_level(Global.game_controller.getLevel(Global.level_index))
	Global.game_controller.change_gui_scene(Global.game_controller.menus["GameUI"], false, true)


func _on_menu_pressed():
	Global.game_controller.change_zoom(Vector2(1,1))
	Global.game_controller.hide_level()
	Global.game_controller.change_gui_scene(Global.game_controller.menus["MainMenu"], false, true)


func _on_next_level_pressed() -> void:
	Global.update_level_index(true)
	Global.game_controller.change_to_level(Global.game_controller.getLevel(Global.level_index))
	Global.game_controller.change_gui_scene(Global.game_controller.menus["GameUI"], false, true)

func _on_last_level_pressed() -> void:
	Global.update_level_index(false)
	Global.game_controller.change_to_level(Global.game_controller.getLevel(Global.level_index))
	Global.game_controller.change_gui_scene(Global.game_controller.menus["GameUI"], false, true)
