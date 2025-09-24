# Bloques genericos



Los bloques tienen 5 tipos principales:

- variable: x,y,z

- num: digitos del 0-9

- =: Para el bloque '='

- operation: +,-,*,/
 
- invalid/null: Para cuando no cumpla ningun caso.


Estos bloques se definen segun las variables exportadas para seleccionar el sprite. Puedes
ver cuales son los correctos viendo los sprites asignados en AnimatedSprite2D, donde depende de:

- El nombre de la animación
- El frame de la animación.



Puedes obtener el tipo de bloque usando el metodo:

- getTypeBlock() -> String con el tipo de bloque.

Y subtipos:
- getTypeNum() -> int con el tipo de numero 0-9
- getTypeOperation() -> String con el tipo de operacion +,-,/,*
- getTypeVariable() -> String con el tipo de variable x,y,z

# Pseudocódigo de logica de encadenación


##  Algoritmo para encontrar cadena de bloques.

Buscar solo los bloques que pueden iniciar una cadena:

	- Buscar x,y,z solo hacia abajo, y derecha.
	

Inspeccionar si tien bloques adyacentes a su posicion.

si tiene bloques, añadir a una pila de posible cadena, y seguir buscando en la misma direccion.

## Algoritmo para encontrar si cadena es valida.

revisar las cadenas de bloques:
	
	- Revisar si tiene sintaxis correcta:
	
	- Primer bloque tiene que ser X, segundo bloque tiene que ser =, 
	despues tiene que ser o operacion, o numero.
	
	
	- Empieza con un num, despues de num siempre hay op, despues de op siempre hay num, termina en num.
	[num][op][num][op][num]
	
Quizas 


