extends Node

class_name EventBlock

var equation_correct: bool = false

# Base methods that can be overridden by child classes
func trigger(solved_value: bool) -> void:
	pass

