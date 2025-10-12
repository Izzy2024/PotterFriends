---
inclusion: always
priority: highest
---

# Memoria del Proyecto - Hogwarts Community Hub

Este documento sirve como memoria persistente para Kiro sobre el proyecto Hogwarts Community Hub. Contiene información esencial, decisiones clave y contexto que debe recordarse al trabajar en el proyecto.

## Información Esencial del Proyecto

### Propósito y Visión

El Hogwarts Community Hub es una plataforma web inmersiva para fans de Harry Potter que permite:
- Descubrir su casa de Hogwarts a través de un quiz interactivo
- Participar en una comunidad temática con otros fans
- Ganar puntos y logros en un sistema gamificado
- Acceder a contenido personalizado según su casa asignada

### Estructura del Proyecto

```
hogwarts_community_hub/
├── css/
│   ├── tailwind.css   # Archivo fuente de Tailwind con utilidades personalizadas
│   └── main.css       # CSS compilado (generado automáticamente)
├── pages/             # Páginas HTML de la aplicación
├── docs/              # Documentación del proyecto
├── .kiro/             # Configuración y memoria para Kiro
├── index.html         # Página de entrada con animación de carga
├── package.json       # Dependencias y scripts del proyecto
└── tailwind.config.js # Configuración personalizada de Tailwind CSS
```

### Stack Tecnológico

- **Frontend**: HTML5, Tailwind CSS, JavaScript (ES6+)
- **Herramientas**: Node.js, npm, PostCSS
- **Fuentes**: Google Fonts (EB Garamond, Lato, Open Sans, Cinzel)
- **Despliegue**: Estático (sin backend actualmente)

## Decisiones Técnicas Importantes

### 1. Uso de Tailwind CSS

**Decisión**: Utilizar Tailwind CSS como framework principal de estilos.

**Razones**:
- Enfoque utility-first para desarrollo rápido
- Altamente personalizable para el tema de Harry Potter
- Excelente soporte para diseño responsivo
- Optimización de CSS en producción

**Implicaciones**:
- Todo el CSS debe seguir el paradigma de utilidades de Tailwind
- Minimizar CSS personalizado fuera del sistema de Tailwind
- Mantener la configuración en tailwind.config.js

### 2. Estructura de Páginas Independientes

**Decisión**: Utilizar páginas HTML independientes en lugar de una SPA.

**Razones**:
- Simplicidad de implementación sin framework JS
- Carga inicial más rápida
- Mejor SEO sin necesidad de SSR

**Implicaciones**:
- Mantener coherencia entre páginas
- Duplicación de elementos comunes (navegación, footer)
- Transiciones entre páginas son cargas completas

### 3. Sistema de Diseño Temático

**Decisión**: Implementar un sistema de diseño basado en las casas de Hogwarts.

**Razones**:
- Experiencia inmersiva para los usuarios
- Coherencia visual en toda la aplicación
- Personalización basada en la casa del usuario

**Implicaciones**:
- Mantener variables CSS para colores de casas
- Componentes con variantes por casa
- Sistema de tokens de diseño coherente

## Estado Actual y Próximos Pasos

### Componentes Implementados

- ✅ Navegación responsiva
- ✅ Pantalla de bienvenida animada
- ✅ Quiz del Sombrero Seleccionador
- ✅ Tarjetas de contenido
- ✅ Sistema de botones
- ✅ Footer

### Próximas Características (Prioridad)

1. Sistema de autenticación de usuarios
2. Persistencia de resultados del quiz
3. Foro interactivo funcional
4. Sistema de logros y puntos

## Convenciones y Estándares

### Convenciones de Nomenclatura

- **Clases CSS**: kebab-case (ej. `house-card`)
- **IDs HTML**: camelCase (ej. `quizContainer`)
- **Funciones JS**: camelCase (ej. `startQuiz()`)
- **Archivos**: snake_case (ej. `sorting_hat_quiz.html`)

### Estándares de Código

- Indentación: 2 espacios
- HTML semántico con atributos ARIA
- JavaScript modular y funcional
- Comentarios para código complejo

## Documentación

La documentación completa se encuentra en la carpeta `docs/` y debe mantenerse actualizada con cada cambio significativo:

1. **docs/project_analysis.md** - Análisis del proyecto
2. **docs/framework_analysis.md** - Análisis del framework
3. **docs/technical_documentation.md** - Documentación técnica
4. **docs/future_improvements.md** - Mejoras futuras
5. **docs/README.md** - Índice de documentación

## Problemas Conocidos y Limitaciones

1. **Sin Backend**: Actualmente no hay persistencia de datos entre sesiones
2. **Compatibilidad**: Optimizado para navegadores modernos, posibles problemas en IE11
3. **Rendimiento**: Las imágenes necesitan optimización adicional
4. **Accesibilidad**: Se necesitan mejoras en contraste de colores y navegación por teclado

## Recordatorios para Kiro

1. **Siempre consultar esta memoria** al trabajar en el proyecto
2. **Actualizar la documentación** con cada cambio significativo
3. **Mantener el sistema de diseño coherente** al añadir nuevos componentes
4. **Seguir las convenciones establecidas** para código y nomenclatura
5. **Considerar las mejoras futuras** documentadas al implementar nuevas características

---

## Registro de Actualizaciones de Memoria

| Fecha | Cambio | Autor |
|-------|--------|-------|
| 2025-07-18 | Creación inicial de la memoria del proyecto | Kiro |

---

**Nota**: Esta memoria debe actualizarse cuando ocurran cambios significativos en el proyecto, decisiones arquitectónicas importantes o cuando se establezcan nuevas convenciones.