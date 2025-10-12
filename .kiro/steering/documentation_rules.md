---
inclusion: always
priority: high
---

# Reglas de Documentación - Hogwarts Community Hub

Este documento establece las reglas y directrices para mantener actualizada la documentación del proyecto Hogwarts Community Hub. Kiro debe seguir estas reglas al asistir con el desarrollo del proyecto.

## Documentos Principales

Los siguientes documentos deben mantenerse actualizados con cada cambio significativo:

1. **docs/project_analysis.md** - Análisis del proyecto y su estructura
2. **docs/framework_analysis.md** - Análisis del framework y tecnologías
3. **docs/technical_documentation.md** - Documentación técnica detallada
4. **docs/future_improvements.md** - Mejoras potenciales y roadmap
5. **docs/README.md** - Índice y visión general de la documentación

## Reglas para Actualización de Documentación

### Regla 1: Actualización Sincronizada

Cuando se realice un cambio significativo en el código, se debe actualizar la documentación correspondiente en el mismo commit o PR. Cambios significativos incluyen:

- Adición de nuevas características o componentes
- Cambios en la estructura del proyecto
- Actualizaciones de dependencias importantes
- Cambios en la API o interfaces públicas
- Modificaciones en el sistema de diseño

### Regla 2: Documentación de Componentes

Cada nuevo componente debe documentarse con:

- Propósito y funcionalidad
- Estructura HTML/CSS
- Comportamiento JavaScript (si aplica)
- Variantes y modificadores
- Ejemplos de uso

### Regla 3: Registro de Cambios

Mantener un registro de cambios en cada documento con:

- Fecha de la modificación
- Descripción breve del cambio
- Razón del cambio
- Autor o responsable

### Regla 4: Coherencia de Estilo

Toda la documentación debe seguir un estilo coherente:

- Usar Markdown para formateo
- Mantener una estructura jerárquica clara
- Incluir ejemplos de código cuando sea relevante
- Usar capturas de pantalla para cambios visuales importantes

### Regla 5: Revisión Periódica

La documentación debe revisarse completamente:

- Después de cada release importante
- Al menos una vez cada tres meses
- Cuando se introduzcan cambios arquitectónicos

## Proceso de Actualización

1. **Identificar Impacto**: Determinar qué documentos se ven afectados por el cambio
2. **Actualizar Contenido**: Modificar los documentos relevantes
3. **Verificar Referencias**: Asegurar que las referencias cruzadas siguen siendo válidas
4. **Actualizar Índice**: Si es necesario, actualizar el README.md con nuevas secciones

## Plantillas para Documentación

### Plantilla para Nuevo Componente

```markdown
## Componente: [Nombre]

### Propósito
[Descripción breve del propósito del componente]

### Estructura
```html
<!-- Ejemplo de estructura HTML -->
```

### Estilos
```css
/* Clases CSS relevantes */
```

### Comportamiento
```javascript
// Código JavaScript relevante
```

### Variantes
- Variante 1: [Descripción]
- Variante 2: [Descripción]

### Ejemplos de Uso
[Ejemplos de implementación]
```

### Plantilla para Registro de Cambios

```markdown
## Registro de Cambios

| Fecha | Cambio | Razón | Autor |
|-------|--------|-------|-------|
| YYYY-MM-DD | Descripción breve | Justificación | Nombre |
```

## Recordatorios para Kiro

- Siempre preguntar si la documentación debe actualizarse cuando se proponen cambios significativos
- Sugerir actualizaciones específicas a la documentación cuando se implementen nuevas características
- Mantener un enfoque en la claridad y accesibilidad de la documentación
- Asegurar que la documentación técnica y el código estén sincronizados
- Recordar al usuario la importancia de mantener la documentación actualizada

## Verificación de Documentación

Antes de considerar completa una tarea que involucre cambios significativos, verificar:

1. ¿Se han actualizado todos los documentos relevantes?
2. ¿La documentación refleja con precisión el estado actual del código?
3. ¿Se han documentado adecuadamente las decisiones de diseño y arquitectura?
4. ¿La documentación sigue siendo coherente y consistente?

---

**Nota**: Este documento debe revisarse y actualizarse periódicamente para reflejar las mejores prácticas actuales y las necesidades del proyecto.