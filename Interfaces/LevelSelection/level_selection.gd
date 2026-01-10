extends Control


func _on_volver_pressed():
    Global.game_controller.change_gui_scene(Global.game_controller.menus["MainMenu"])