
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


