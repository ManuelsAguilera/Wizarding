# Bloques genericos

Los bloques tienen 5 tipos principales:

- variable: x,y,z

- num: dígitos del 0-9

- =: Para el bloque '='

- operator: +,-,*,/
 
- invalid: Para cuando no cumpla ningún caso.


Estos bloques se definen segun las variables exportadas para seleccionar el sprite. Puedes
ver cuales son los correctos viendo los sprites asignados en AnimatedSprite2D, donde depende de:

- El nombre de la animación
- El frame de la animación.



Puedes obtener el tipo de bloque usando el método:

- getTypeBlock() -> String con el tipo de bloque.

Y subtipos:
- getTypeNumber() -> int con el tipo de número 0-9 (retorna null si no es tipo num)
- getTypeOperation() -> String con el tipo de operación +,-,/,* (retorna null si no es tipo operator)
- getTypeVariable() -> String con el tipo de variable x,y,z (retorna null si no es tipo variable)

# BlockManager - Lógica de encadenación

## Sistema de notificación
El BlockManager es notificado cuando un bloque se mueve a través del método `notify_block_moved()`. Esto establece `chains_searched = false` para triggear una nueva búsqueda de cadenas en el siguiente frame.

## Algoritmo para encontrar cadenas de bloques

1. **Inicialización**: En `_ready()`, se recopilan todos los bloques hijos que sean de tipo `GenericBlock` y se almacenan en `blocklist`. Los bloques de tipo "variable" se guardan en `variableBlocks`.

2. **Búsqueda de cadenas**: El método `generar_cadenas()` busca cadenas válidas:
   - Solo los bloques de tipo "variable" (x, y, z) pueden iniciar una cadena
   - Para cada variable, se busca hacia **abajo** (Vector2(0,1)) y hacia la **derecha** (Vector2(1,0))
   - Si encuentra un bloque adyacente, usa `searchBlocks()` recursivamente para encontrar toda la cadena en esa dirección

3. **Búsqueda recursiva**: `searchBlocks(initial_pos, dir)` continúa en la dirección dada hasta que no encuentra más bloques conectados.

## Posicionamiento y grid
- Los bloques se ajustan a un grid de 64x64 píxeles usando `snap_to_grid()`
- `getSnappedPosition()` retorna la posición del bloque en coordenadas de grid (dividido por 64)
- Durante el movimiento, se usa la posición inicial para evitar inconsistencias

## Validación de cadenas
Actualmente, el sistema encuentra y muestra las cadenas pero no implementa validación de sintaxis. Para una implementación completa, se debería agregar:

- Validación de sintaxis: Variable + = + expresión matemática
- Expresiones válidas: [num][operator][num][operator][num]...
- Verificación de que las cadenas terminen correctamente

## Funcionalidad adicional

### Movimiento de bloques
- Los bloques pueden ser empujados usando `push(playerDirection)`
- El movimiento es animado con `ANIMATIONSPEED = 8`
- Durante el movimiento, `is_moving` es true y se usa `percent_moved` para interpolar la posición
- Al finalizar el movimiento, se notifica al `parentManager` (BlockManager)

### Configuración de sprites
- Los bloques usan `AnimatedSprite2D` con animaciones nombradas según el tipo
- `spriteName` define el tipo de bloque ("num", "x", "y", "z", "+", "-", "*", "/", "=")
- `frame` define el frame específico (importante para números 0-9)

### Debug y visualización
- `printCadenas()` muestra en consola todas las cadenas encontradas con su estructura
- Las partículas de polvo se activan al empujar un bloque
- Método `isABlock()` para identificación de tipo de objeto 




Esta documentación fue revisada por copilot :p