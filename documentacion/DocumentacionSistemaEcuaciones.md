# Documentación del Sistema de Ecuaciones

## Arquitectura General

El sistema de ecuaciones está compuesto por tres componentes principales que trabajan en conjunto para gestionar la lógica de resolución de puzzles matemáticos:

```
LevelManager (Coordinador principal)
├── Config (Configuración del nivel)
├── BlockManager (Gestión de bloques móviles)
├── EquationManager (Validación de ecuaciones)
│   ├── EquationBlock (Objetivos del nivel)
│   │   ├── TextEquation (Visualización animada)
│   │   └── EventBlock (Eventos al resolver)
│   │       └── GoalBlock (Meta del nivel)
└── MainCamera (Control de cámara)
```

---

# LevelManager - Coordinador Principal

## Propósito
`LevelManager` actúa como el coordinador central del nivel, gestionando la comunicación entre todos los componentes y controlando el flujo del juego.

## Variables de Estado

### Referencias de componentes:
- `config: Config` - Configuración específica del nivel
- `eqManager: EquationManager` - Gestor de validación de ecuaciones
- `level_complete: bool` - Estado de finalización del nivel

## Métodos Principales

### Inicialización:
- `_ready()` - Configura referencias y aplica configuración inicial
- `aplicarConf()` - Aplica configuraciones del nivel
- `aplicarZoom()` - Configura zoom de la cámara según Config

### Comunicación con BlockManager:
- `equation_found(equation: String)` - Recibe ecuaciones válidas del BlockManager
- `reset_solutions()` - Resetea todas las soluciones cuando se mueve un bloque

### Control de nivel:
- `on_player_reach_goal()` - Maneja la finalización del nivel


- Por implementar en un futuro..

## Flujo de Comunicación

1. **BlockManager encuentra ecuación válida** → `equation_found()`
2. **LevelManager verifica con EquationManager** → `verify_equation()`
3. **EquationManager notifica a EquationBlocks** → `triggerEvents()`
4. **EventBlocks ejecutan acciones** (activar metas, etc.)

---

# EquationManager - Validador de Ecuaciones

## Propósito
`EquationManager` se encarga de validar las ecuaciones encontradas por el BlockManager y determinar si corresponden a las soluciones requeridas del nivel.

## Variables de Estado

- `solutions: Array` - Lista de EquationBlocks que representan las soluciones del nivel

## Métodos de Inicialización

- `_ready()` - Recolecta todos los EquationBlock hijos en el array de soluciones

## Métodos de Validación

### `verify_equation(equation: String) -> bool`
**Propósito**: Valida si una ecuación encontrada corresponde a alguna solución del nivel

**Proceso**:
1. Itera por todas las soluciones disponibles
2. Compara cada solución usando `compare_solutions()`
3. Notifica resultados a los EquationBlocks mediante `triggerEvents()`
4. Retorna `true` si encuentra coincidencia, `false` si no

### `compare_solutions(eq_found: String, solution: EquationBlock) -> bool`
**Propósito**: Compara una ecuación específica con un EquationBlock

**Validaciones**:
1. **Variable correcta**: Verifica que la variable (x,y,z) coincida
2. **Cálculo de ecuación**: Evalúa la expresión matemática
3. **Comparación de resultado**: Compara con la solución esperada

**⚠️ NOTA**: Hay un error en el código actual - la comparación final retorna `false` cuando debería retornar `true` en caso de coincidencia.

## Métodos de Cálculo

### `calculate_from_string(equation: String) -> Variant`
**Propósito**: Evalúa una ecuación matemática usando la clase Expression de Godot

**Características**:
- Utiliza `Expression.new()` de Godot para parsing seguro
- Maneja errores de sintaxis y ejecución
- Retorna `null` en caso de error, valor numérico en caso de éxito

**Ejemplo de uso**:
```gdscript
var result = calculate_from_string("3 + 2 * 4")  # Retorna 11
```

---

# EquationBlock - Objetivos del Nivel

## Propósito
`EquationBlock` representa una ecuación que debe ser resuelta por el jugador. Contiene la lógica de validación, visualización y eventos asociados.

## Constantes

- `TILE_SIZE: Vector2(64, 64)` - Tamaño de tile para sistema de grid

## Variables Exportadas

### Configuración de ecuación:
- `equation: String` - Texto de la ecuación mostrada al jugador
- `color: String` - Color de visualización ("white", "green", etc.)
- `variableType: String` - Variable que debe resolverse (x, y, z)
- `solution: float` - Valor correcto de la variable

### Variables de estado:
- `solved: bool` - Estado actual de resolución
- `text: TextEquation` - Componente de visualización animada

## Métodos de Posicionamiento

### Sistema de Grid:
- `snap_to_grid()` - Ajusta posición al grid de 64x64
- `getSnappedPosition() -> Vector2` - Retorna posición en coordenadas de grid
- `_setup_position()` - Configura posición inicial

## Métodos de Gestión

### `get_solution() -> float`
Retorna el valor de solución esperado para que EquationManager pueda validar

### `triggerEvents(solved_value: bool) -> void`
**Propósito**: Notifica cambios de estado a todos los EventBlocks hijos

**Comportamiento**:
1. Evita notificaciones innecesarias (solo si cambia el estado)
2. Actualiza variable `solved`
3. Notifica a todos los EventBlocks hijos
4. Cambia color visual (verde=resuelto, blanco=no resuelto)

---

# EventBlock - Sistema de Eventos

## Propósito
`EventBlock` es la clase base para eventos que se activan cuando se resuelve una ecuación. Utiliza el patrón Template Method para permitir diferentes tipos de eventos.

## Variables

- `equation_correct: bool` - Estado de la ecuación asociada

## Métodos

### `trigger(solved_value: bool) -> void`
Método virtual que debe ser sobrescrito por clases hijas para implementar comportamientos específicos.

---

# GoalBlock - Meta del Nivel

## Propósito
`GoalBlock` extiende `EventBlock` para crear metas que se activan cuando se resuelve la ecuación correcta.

## Variables

- `body: GoalPostBody` - Referencia al cuerpo físico de la meta
- `activated: bool` - Estado de activación de la meta

## Métodos

### `trigger(solved_value: bool) -> void` (Override)
**Comportamiento**:
- Actualiza estado de activación
- Activa o desactiva el cuerpo físico según el estado
- Permite o bloquea el paso del jugador

### `_ready()`
- Obtiene referencia al GoalPostBody
- Inicializa en estado desactivado

---

# TextEquation - Visualización Animada

## Propósito
`TextEquation` maneja la visualización animada de las ecuaciones con efectos visuales dinámicos.

## Variables de Configuración

### Básicas:
- `equation: String` - Texto de la ecuación
- `color: String` - Color base del texto
- `label: Label` - Referencia al componente Label

### Animación de escala:
- `base_scale: Vector2` - Escala base del texto
- `max_scale: float = 0.2` - Amplitud máxima de escala
- `scale_speed: float = 5e-7` - Velocidad de animación de escala

### Animación de color:
- `primary_color: Color` - Color principal del texto
- `modulation_color: Color` - Color de modulación
- `modulation: float` - Intensidad de modulación actual
- `max_modulation: float = 0.2` - Modulación máxima

### Animación de posición:
- `base_position: Vector2` - Posición base
- `position_amplitude: Vector2(2, 1)` - Amplitud del movimiento
- `position_speed: float = 1.0` - Velocidad del movimiento

## Métodos de Animación

### `scaleAnimation()`
Crea efecto de pulsación usando función seno basada en tiempo del sistema

### `colorAnimation()`
Modula el color base con variaciones suaves para crear efecto de brillo

### `positionAnimation()`
Genera movimiento flotante sutil usando funciones seno y coseno

## Métodos Públicos

### `changeEquation(newEq: String)`
Actualiza el texto de la ecuación y lo refleja en el Label

### `changeColor(newColor: String)`
Cambia el color base del texto (soporta "white" y colores estándar)

### `getEquation() -> String`
Retorna la ecuación actual

---

# Flujo Completo del Sistema

## 1. Inicialización del Nivel
```
LevelManager._ready()
├── Obtiene referencias (Config, EquationManager)
├── Aplica configuración
└── EquationManager recolecta EquationBlocks
```

## 2. Movimiento y Validación
```
Player mueve GenericBlock
├── BlockManager.notify_block_moved()
├── LevelManager.reset_solutions()
├── BlockManager encuentra cadena válida
├── BlockManager.equation_found()
├── LevelManager.equation_found()
└── EquationManager.verify_equation()
```

## 3. Resolución de Ecuación
```
EquationManager encuentra coincidencia
├── EquationBlock.triggerEvents(true)
├── EventBlocks ejecutan acciones
├── GoalBlock activa meta
└── Player puede completar nivel
```

## Casos de Uso Típicos

### Ecuación Simple: `x = 5`
1. Player organiza bloques: [x][=][5]
2. BlockManager valida sintaxis
3. EquationManager compara con EquationBlock(x, 5.0)
4. GoalBlock se activa
5. Player puede alcanzar la meta

### Ecuación Compleja: `y = 3 + 2`
1. Player organiza: [y][=][3][+][2]
2. Sistema calcula: 3 + 2 = 5
3. Compara con EquationBlock(y, 5.0)
4. Activa eventos asociados

---

**Documentación generada - Septiembre 2025**  
*Sistema completo de ecuaciones para puzzle game en Godot*
