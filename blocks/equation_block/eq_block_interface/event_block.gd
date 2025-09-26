extends Node2D


#Todos los bloques que tengan un evento que se active cuando la ecuacion es correcta deben extender esta clase
class_name EventBlock



#Metodos que deben ser sobreescritos por las clases hijas
#Para definir comportamiento de eventos

#trigger es llamado cuando el estado de la ecuacion cambia
#Si la ecuacion pasa a estar correcta, se activa el evento
#Si la ecuacion pasa a estar incorrecta, se desactiva el evento
func trigger(solved_value:bool) -> void:
    pass

