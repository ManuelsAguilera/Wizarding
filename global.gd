extends Node


var game_controller:GameController

var level_index = 0


func update_level_index():
    level_index += 1
    if level_index >= game_controller.levels.size() or level_index < 0:
        level_index = 0


