extends Node


#Todos los bloques que tengan un evento que se active cuando la ecuacion es correcta deben extender esta clase
class_name EventBlock

var equation_correct:bool = false

#Metodos que deben ser sobreescritos por las clases hijas
#Para definir comportamiento de eventos

#set_equation_correct es llamado por EquationManager cuando la ecuacion es correcta
func set_equation_correct():
    pass


#set_equation_incorrect es llamado por EquationManager cuando la ecuacion deja de ser correcta
func set_equation_incorrect():
    pass


func get_equation_state() -> bool:
    return equation_correct