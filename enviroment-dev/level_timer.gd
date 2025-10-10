extends Node2D

class_name LevelTimer

var time_elapsed:float = 0
var is_paused:bool = true


func _process(delta: float) -> void:
    if !is_paused:
        time_elapsed+=delta

func getTime():
    return time_elapsed

func pauseTimer():
    is_paused=true

func unpauseTimer():
    is_paused = false

func reset_timer():
    time_elapsed = 0