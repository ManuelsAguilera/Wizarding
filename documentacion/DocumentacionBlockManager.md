# Bloques Genericos (GenericBlock)

Los bloques tienen 5 tipos principales:

- **variable**: x, y, z
- **num**: dígitos del 0-9
- **=**: Para el bloque de igualdad
- **operator**: +, -, *, /
- **invalid**: Para cuando no cumpla ningún caso

## Configuración de Bloques

Los bloques se definen según las variables exportadas:
- `spriteName`: Nombre de la animación del sprite
- `frame`: Frame específico (importante para números 0-9)

## Métodos de Identificación

### Método principal:
- `getTypeBlock() -> String`: Retorna el tipo de bloque

### Métodos específicos:
- `getTypeNumber() -> int`: Número 0-9 (retorna -1 si no es tipo num)
- `getTypeOperation() -> String`: Operación +,-,/,* (retorna "" si no es tipo operator)  
- `getTypeVariable() -> String`: Variable x,y,z (retorna "" si no es tipo variable)

## Sistema de Grid y Posicionamiento

- **TILE_SIZE**: Vector2(64, 64) píxeles por tile
- `snap_to_grid()`: Ajusta posición al grid más cercano
- `getSnappedPosition() -> Vector2`: Posición en coordenadas de grid (dividido por 64)

## Sistema de Movimiento

### Constantes:
- `ANIMATION_SPEED`: 8.0 (velocidad de animación)

### Métodos de movimiento:
- `push(player_direction: Vector2)`: Inicia movimiento del bloque
- `is_block_moving() -> bool`: Verifica si está en movimiento
- `move(delta: float)`: Ejecuta animación de movimiento

### Variables de estado:
- `is_moving`: bool - Indica si está en movimiento
- `percent_moved`: float (0.0-1.0) - Progreso del movimiento
- `initial_position`: Vector2 - Posición antes del movimiento
- `direction`: Vector2 - Dirección actual de movimiento

## Sistema de Cadenas Visuales

### Nuevo sistema de resaltado:
- `set_in_chain(bool)`: Cambia la modulación visual del sprite
  - `true`: Color normal (1, 1, 1)
  - `false`: Color opaco (0.5, 0.5, 0.5)
- `is_in_chain`: bool - Estado actual del bloque en cadena

## Efectos Visuales

- **Partículas de polvo**: `CPUParticles2D` activadas al empujar bloques
- **Modulación de color**: Resalta bloques que forman cadenas válidas

# BlockManager - Lógica de Encadenación y Gestión

## Variables de Configuración

### Exportadas:
- `map_size: Vector2(10, 10)`: Tamaño del mapa para futura implementación de grid

### Variables de estado:
- `concatBlocks: Array[Array]`: Lista de listas de bloques encadenados encontrados
- `blocklist: Array[GenericBlock]`: Todos los GenericBlock en la escena
- `variableBlocks: Array[GenericBlock]`: Bloques de tipo variable (x,y,z)
- `chains_searched: bool`: Flag para evitar búsquedas innecesarias

## Sistema de Notificación

El BlockManager es notificado cuando un bloque se mueve mediante:
- `notify_block_moved()`: Establece `chains_searched = false` y resetea soluciones en LevelManager

## Inicialización del Sistema

`_initialize_blocks()`: Recopila todos los GenericBlock hijos:
- Almacena en `blocklist` para búsquedas rápidas
- Filtra variables (x,y,z) en `variableBlocks`

## Algoritmo de Búsqueda de Cadenas

### 1. Generación de cadenas (`generar_cadenas()`):
- Solo bloques "variable" pueden iniciar cadenas
- Busca hacia **abajo** (Vector2(0,1)) y **derecha** (Vector2(1,0))
- Usa búsqueda recursiva para cadenas completas

### 2. Búsqueda recursiva (`searchBlocks()`):
- Continúa en dirección específica hasta no encontrar bloques
- Retorna Array[GenericBlock] con la cadena completa

### 3. Procesamiento en tiempo real (`_process()`):
- Ejecuta búsqueda cuando `chains_searched = false`
- Deselecciona cadenas previas (set_in_chain(false))
- Valida sintaxis de cada cadena encontrada
- Activa resaltado visual para cadenas válidas

## Posicionamiento y grid
- Los bloques se ajustan a un grid de 64x64 píxeles usando `snap_to_grid()`
- `getSnappedPosition()` retorna la posición del bloque en coordenadas de grid (dividido por 64)
- Durante el movimiento, se usa la posición inicial para evitar inconsistencias

## Validación de Sintaxis (IMPLEMENTADO)

El sistema ahora incluye validación completa de sintaxis mediante `revisar_sintaxis(cadena: Array[GenericBlock]) -> String`:

### Reglas de validación:
- **Mínimo 3 bloques**: Variable + = + número/expresión
- **Debe comenzar con variable**: x, y, o z
- **Segundo bloque debe ser "="**: Operador de igualdad
- **Alternancia correcta**: número → operador → número → operador...
- **No puede terminar con operador**: Debe finalizar con número

### Proceso de validación:
1. Verifica estructura mínima (≥3 bloques)
2. Confirma inicio con variable
3. Confirma segundo bloque como "="
4. Valida alternancia de números y operadores
5. Retorna ecuación completa como String o "invalid"

### Ejemplo de cadenas válidas:
- `x = 5`
- `y = 3 + 2`
- `z = 10 - 4 * 2`

## Comunicación con LevelManager

### Notificación de ecuaciones válidas:
- `equation_found(equation: String)`: Envía ecuaciones válidas al LevelManager padre
- Integración completa con sistema de soluciones del nivel

## Métodos de Debug y Visualización

### BlockManager:
- `printCadenas()`: Muestra estructura detallada de cadenas en consola
- `_debug_print_blocks()`: Información de todos los bloques encontrados

### GenericBlock:
- Partículas de polvo (`CPUParticles2D`) al empujar bloques
- Sistema visual de cadenas con modulación de color
- Método `isABlock()` para identificación de tipo

## Flujo Completo del Sistema

1. **Inicialización**: Recolección de bloques en `_ready()`
2. **Movimiento**: Player empuja bloque → `notify_block_moved()`
3. **Búsqueda**: `generar_cadenas()` encuentra nuevas conexiones
4. **Validación**: `revisar_sintaxis()` verifica ecuaciones
5. **Comunicación**: Ecuaciones válidas se envían a LevelManager
6. **Visual**: Bloques en cadenas válidas se resaltan

## Arquitectura del Sistema

```
LevelManager
    ├── BlockManager (gestión de cadenas)
    │   ├── GenericBlock (variables, números, operadores)
    │   ├── GenericBlock
    │   └── ...
    └── Otros componentes del nivel
```

## Notas de Implementación

- Sistema optimizado: solo busca cadenas cuando `chains_searched = false`
- Manejo de estados visuales automático
- Integración completa con sistema de física de Godot
- Soporte para debug y desarrollo mediante métodos de impresión

---

**Documentación actualizada - Septiembre 2025**  
*Incluye validación de sintaxis, sistema de resaltado visual y comunicación con LevelManager*