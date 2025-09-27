# GitHub Copilot Instructions

## Idioma y Comunicación
- Responde siempre en **español**
- Mantén un tono técnico, claro y respetuoso
- Documenta el código en español

## Proyecto Godot - Estructura y Buenas Prácticas

### Scripts GDScript (.gd)
- Sigue las convenciones de nomenclatura de GDScript (snake_case para variables y funciones, PascalCase para clases)
- Utiliza type hints siempre que sea posible
- Mantén coherencia con el estilo de código existente
- Documenta funciones públicas con comentarios descriptivos

### Escenas y Nodos (.tscn)
- Verifica que los cambios no rompan referencias entre escenas
- Asegúrate de que los paths de nodos sean correctos
- Mantén la jerarquía de nodos organizada y con propósito claro
- Reutiliza nodos y componentes cuando sea apropiado

### Señales y Comunicación
- Verifica que las conexiones de señales sean correctas
- Usa nombres descriptivos para señales personalizadas
- Evita dependencias circulares entre nodos
- Documenta el flujo de señales en sistemas complejos

### Arquitectura del Proyecto
- Mantén la organización de carpetas existente
- No rompas la arquitectura general del juego
- Reutiliza scripts y recursos cuando sea posible
- Separa lógica de presentación apropiadamente

### Revisión de Código
Cuando revises código, verifica que:
- Sea coherente con la estructura del proyecto Godot
- Siga buenas prácticas de GDScript
- No rompa escenas ni referencias en archivos `.tscn`
- Esté correctamente documentado
- Mantenga la organización del proyecto
- Aproveche la reutilización de nodos, señales y scripts

### Archivos a Considerar
- Prioriza archivos `.gd` (scripts)
- Revisa archivos `.tscn` (escenas) para verificar integridad
- Considera archivos `.tres` (recursos) si son relevantes
- Ten en cuenta `project.godot` para configuraciones
- Actualiza documentación en `README.md` y `docs/` si es necesario

### Exclusiones
- Ignora cambios en `addons/` a menos que sean modificaciones intencionales
- No consideres archivos en `.import/` (generados automáticamente)
- Evita modificar configuraciones de plugins externos sin contexto

## Nuevas Implementaciones
- Si agregas nuevas escenas, asegúrate de que tengan propósito claro
- Verifica que no generen errores en tiempo de ejecución
- Mantén consistencia con patrones existentes en el proyecto
- Actualiza documentación relevante cuando sea necesario
