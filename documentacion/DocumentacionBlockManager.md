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
- `notify_block_moved()`: llamado por quien inicie el movimiento (por ejemplo `Player`).

Comportamiento actual en el código:

- `notify_block_moved()` espera a que todos los `GenericBlock` acaben su animación antes de
  ejecutar `search()`. Concretamente usa `_wait_for_blocks_to_finish_moving()` que hace polling
  por frame consultando `is_block_moving()` en cada bloque.

- El flag `chains_searched` existe en el código y se pone a `false` por compatibilidad, pero
  actualmente no se usa como condición para ejecutar búsquedas (la búsqueda se lanza desde
  `_ready()` y desde `notify_block_moved()` cuando termina el movimiento).

Recomendación (mejora):

- Migrar a señales: que cada `GenericBlock` emita `signal movement_finished` al terminar su
  desplazamiento y que `BlockManager` conecte a esa señal para contar movimientos pendientes
  (esto evita el polling y es más eficiente).

## Inicialización del Sistema

`_initialize_blocks()`: Recopila todos los GenericBlock hijos:
- Almacena en `blocklist` para búsquedas rápidas
- Filtra variables (x,y,z) en `variableBlocks`

Adicionalmente `_initialize_blocks()` es un buen lugar para realizar conexiones a señales
de los `GenericBlock` si se adopta la variante por señales. Ejemplo de comportamiento recomendado:

- conectar `generic_block.connect("movement_finished", self, "_on_block_movement_finished")`
- llevar un contador `pending_movements` que se incremente cuando comience un movimiento y
  se decremente al recibir la señal; cuando llegue a 0, ejecutar `search()`.

## Algoritmo de Búsqueda de Cadenas

### 1. Generación de cadenas (`generar_cadenas()`):
- Solo bloques "variable" pueden iniciar cadenas
- Busca hacia **abajo** (Vector2(0,1)) y **derecha** (Vector2(1,0))
- Usa búsqueda recursiva para cadenas completas

### 2. Búsqueda recursiva (`searchBlocks()`):
- Continúa en dirección específica hasta no encontrar bloques
- Retorna Array[GenericBlock] con la cadena completa

### 3. Procesamiento y cuándo se ejecuta la búsqueda

- La búsqueda de cadenas no está ligada a `_process()` en `BlockManager`. Actualmente las ejecuciones
  relevantes son:
  - `_ready()` — búsqueda inicial al cargar la escena.
  - Después de `notify_block_moved()` — tras esperar a que todos los bloques terminen su movimiento.

La espera en `notify_block_moved()` (polling) garantiza que `getSnappedPosition()` devuelva valores
estables antes de generar y validar cadenas.

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

### Ejemplo de cadenas válidas (limitación actual)

Nota: actualmente cada bloque `num` representa un dígito (0-9). El parser de `revisar_sintaxis`
interpreta cada bloque `num` como un número independiente. Por tanto **no hay soporte nativo para
números de varios dígitos** (como `10`) a menos que se agregue lógica adicional para concatenar
bloques num en un número multi-dígito.

Ejemplos válidos (con dígitos simples):
- `x = 5`
- `y = 3 + 2`
- `z = 9 - 4 * 2`

## Comunicación con LevelManager

### Notificación de ecuaciones válidas:
- `equation_found(equation: String)`: Envía ecuaciones válidas al LevelManager padre
- Integración completa con sistema de soluciones del nivel

### Interacción con `Player`

- `Player` (o quien provoque el movimiento) debe llamar `block_manager.notify_block_moved()` después de
  iniciar el movimiento de los bloques. En el código actual `Player.push()` hace esto inmediatamente
  después de llamar `push()` en los bloques.

- Observación: `Player` actualmente comprueba `detected_block.is_block_moving()` al querer moverse
  para evitar solapamientos. Esto es correcto, pero se detectaron un par de advertencias en `player.gd`:
  - `_process(delta)` declara `delta` y no lo usa — renombrarlo a `_delta` si se mantiene intencional.
  - Parámetros `direction` en `can_push_blocks` y `get_blocks_in_path` shadowean la variable
    de instancia `direction` del `Player`. Se recomienda renombrarlos a `dir` o `_direction`.

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

- El flag `chains_searched` está presente en `block_manager.gd` pero **no** controla actualmente
  cuándo se ejecuta la búsqueda; se deja por compatibilidad o uso futuro.
- Manejo de estados visuales automático mediante `set_in_chain()` en `GenericBlock`.
- Integración completa con sistema de física de Godot (las detecciones de colisión se hacen desde `Player`).
- Soporte para debug y desarrollo mediante métodos de impresión

### Recomendaciones de mejora (próximos pasos)

1. Migrar de polling a señales:
  - Añadir `signal movement_finished` en `generic_block.gd` y emitirla en `_finish_movement()`.
  - Conectar cada `GenericBlock` en `_initialize_blocks()` a un handler en `BlockManager`.
  - Mantener un contador de movimientos pendientes y llamar `search()` sólo cuando llegue a 0.

2. Añadir tests básicos (si se desea):
  - Unit test/escena pequeña donde se simula push de 1-3 bloques y se verifica que
    `notify_block_moved()` resulta en `equation_found()` cuando corresponde.

3. Depurar advertencias de `player.gd` para mantener el proyecto limpio de warnings.

---

**Documentación actualizada - Octubre 17 2025**  
