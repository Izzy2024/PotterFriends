---
inclusion: always
priority: highest
---

# Memoria Completa de Estructura del Proyecto - Hogwarts Community Hub

Este documento sirve como memoria permanente y completa de la estructura, tecnologías, componentes y arquitectura del proyecto Hogwarts Community Hub. Debe consultarse siempre antes de realizar cualquier modificación al proyecto.

## Información General del Proyecto

### Nombre del Proyecto
**Hogwarts Community Hub** (también referenciado como "Potter Friends" en algunas páginas)

### Descripción
Una plataforma web inmersiva para fans de Harry Potter que permite:
- Descubrir su casa de Hogwarts a través de un quiz interactivo del Sombrero Seleccionador
- Participar en una comunidad temática con otros fans
- Ganar puntos y logros en un sistema gamificado
- Acceder a contenido personalizado según su casa asignada
- Participar en foros de discusión
- Unirse a eventos y desafíos comunitarios

### Versión Actual
1.0.0

## Estructura Completa del Proyecto

```
hogwarts-community-hub/
├── .gitignore                          # Archivos ignorados por Git
├── index.html                          # Página de entrada con animación de carga
├── package.json                        # Dependencias y scripts del proyecto
├── package-lock.json                   # Lockfile de dependencias
├── README.md                           # Documentación principal del proyecto
├── tailwind.config.js                  # Configuración personalizada de Tailwind CSS
├── test.html                           # Archivo de pruebas
│
├── css/                                # Archivos de estilos
│   ├── main.css                        # CSS compilado (generado automáticamente)
│   └── tailwind.css                    # Archivo fuente de Tailwind con utilidades personalizadas
│
├── docs/                               # Documentación del proyecto
│   ├── framework_analysis.md           # Análisis del framework y tecnologías
│   ├── future_improvements.md          # Mejoras futuras planificadas
│   ├── project_analysis.md             # Análisis completo del proyecto
│   ├── README.md                       # Índice de documentación
│   └── technical_documentation.md      # Documentación técnica detallada
│
├── .kiro/                              # Configuración y memoria para Kiro
│   ├── settings/
│   │   └── documentation_hooks.json    # Hooks para automatización de documentación
│   └── steering/
│       ├── documentation_checklist.md  # Checklist para actualización de documentación
│       ├── documentation_rules.md      # Reglas para mantener documentación
│       ├── project_memory.md           # Memoria del proyecto (original)
│       └── project_structure_memory.md # Este archivo - memoria completa de estructura
│
├── pages/                              # Páginas HTML de la aplicación
│   ├── community_events_challenges_center.html    # Centro de eventos y desafíos
│   ├── homepage_sorting_hat_experience.html       # Página principal con experiencia del sombrero
│   ├── house_common_rooms_personalized_dashboards.html # Salas comunes personalizadas
│   ├── house_selection_portal_sorting_hat_quiz.html    # Portal de selección con quiz
│   ├── interactive_forum_hub.html                      # Hub de foro interactivo
│   └── user_profile_achievement_system.html            # Sistema de perfil y logros
│
└── public/                             # Archivos públicos y recursos
    ├── dhws-data-injector.js           # Script de inyección de datos
    ├── favicon.ico                     # Icono del sitio
    └── manifest.json                   # Manifiesto para PWA
```

## Stack Tecnológico Completo

### Lenguajes y Frameworks Base
- **HTML5**: Estructura semántica moderna con atributos ARIA para accesibilidad
- **CSS3**: Implementado completamente a través de Tailwind CSS
- **JavaScript (ES6+)**: Funcionalidades interactivas, quiz del sombrero, animaciones
- **Tailwind CSS**: Framework CSS principal con configuración personalizada

### Dependencias de Producción
```json
{
  "@dhiwise/component-tagger": "^1.0.10",    // Etiquetado de componentes
  "@tailwindcss/forms": "^0.5.7",            // Estilos mejorados para formularios
  "tailwindcss-animate": "^1.0.7",           // Animaciones para elementos UI
  "tailwindcss-elevation": "^2.0.0",         // Efectos de elevación y sombras
  "tailwindcss-fluid-type": "^2.0.7"         // Tipografía responsiva
}
```

### Dependencias de Desarrollo
```json
{
  "tailwindcss": "^3.4.17",                  // Framework CSS principal
  "@tailwindcss/aspect-ratio": "^0.4.2",     // Utilidades de aspect ratio
  "@tailwindcss/container-queries": "^0.1.1", // Consultas de contenedor
  "@tailwindcss/line-clamp": "^0.1.0",       // Truncado de texto
  "@tailwindcss/typography": "^0.5.16"       // Estilos tipográficos
}
```

### Fuentes Externas (Google Fonts)
- **EB Garamond**: Fuente principal para títulos y elementos elegantes
- **Lato**: Fuente para texto de lectura y contenido general
- **Open Sans**: Fuente para botones y llamadas a la acción
- **Cinzel**: Fuente de acento para elementos especiales y ceremoniales

## Sistema de Diseño y Configuración de Tailwind

### Paleta de Colores Temática

#### Colores Primarios (Gryffindor)
- `primary-50`: #FEF2F2 (red-50)
- `primary-100`: #FEE2E2 (red-100)
- `primary-500`: #EF4444 (red-500)
- `primary-600`: #DC2626 (red-600)
- `primary-700`: #B91C1C (red-700)
- `primary-800`: #991B1B (red-800)
- `primary-900`: #740001 (custom red-900)
- `primary-DEFAULT`: #740001

#### Colores Secundarios (Dorado Mágico)
- `secondary-50`: #FFFBEB (yellow-50)
- `secondary-100`: #FEF3C7 (yellow-100)
- `secondary-200`: #FDE68A (yellow-200)
- `secondary-300`: #FCD34D (yellow-300)
- `secondary-400`: #FBBF24 (yellow-400)
- `secondary-500`: #F59E0B (yellow-500)
- `secondary-600`: #C9A961 (custom yellow-600)
- `secondary-DEFAULT`: #C9A961

#### Colores de Acento (Ravenclaw)
- `accent-50`: #EFF6FF (blue-50)
- `accent-100`: #DBEAFE (blue-100)
- `accent-500`: #3B82F6 (blue-500)
- `accent-700`: #1D4ED8 (blue-700)
- `accent-800`: #1E40AF (blue-800)
- `accent-900`: #0E1A40 (custom blue-900)
- `accent-DEFAULT`: #0E1A40

#### Colores de Casa
- `gryffindor`: #740001 (red-900)
- `hufflepuff`: #FFD800 (yellow-400)
- `ravenclaw`: #0E1A40 (blue-900)
- `slytherin`: #1A472A (green-800)

#### Colores de Fondo y Superficie
- `background`: #F4F1E8 (stone-100) - Pergamino cálido
- `surface`: #FEFCF7 (stone-50) - Elevación sutil de contenido

#### Colores de Texto
- `text-primary`: #2C2C2C (gray-800) - Texto principal
- `text-secondary`: #5D5D5D (gray-600) - Texto secundario

#### Colores de Estado
- `success-DEFAULT`: #1A472A (green-800) - Slytherin achievement
- `warning-DEFAULT`: #FFD800 (yellow-400) - Hufflepuff attention
- `error-DEFAULT`: #8B0000 (custom red-800) - Corrección útil

### Tipografía Personalizada
```javascript
fontFamily: {
  headline: ['EB Garamond', 'serif'],    // Elegancia académica
  body: ['Lato', 'sans-serif'],          // Lectura cómoda
  cta: ['Open Sans', 'sans-serif'],      // Confianza moderna
  accent: ['Cinzel', 'serif'],           // Gravitas mágica
  sans: ['Lato', 'sans-serif'],
  serif: ['EB Garamond', 'serif'],
}
```

### Efectos y Animaciones Personalizadas
- `shadow-subtle`: Sombras suaves como luz de velas
- `shadow-card`: Tarjetas de contenido elevadas
- `shadow-elevated`: Elementos interactivos
- `transition-gentle`: Transiciones mágicas de 300ms
- `scale-hover`: Escala sutil de 1.02 para hover
- `border-house`: Bordes de 2px para acentos de casa

## Arquitectura de Páginas

### Flujo de Navegación Principal
1. **index.html** → Pantalla de carga animada (3 segundos)
2. **homepage_sorting_hat_experience.html** → Hub central de la experiencia
3. **house_selection_portal_sorting_hat_quiz.html** → Quiz interactivo del sombrero
4. **house_common_rooms_personalized_dashboards.html** → Salas comunes por casa
5. **user_profile_achievement_system.html** → Perfil y sistema de logros
6. **interactive_forum_hub.html** → Foro de discusión comunitaria
7. **community_events_challenges_center.html** → Eventos y desafíos

### Características de Cada Página

#### index.html (Página de Entrada)
- **Propósito**: Pantalla de bienvenida con animación de carga
- **Características**:
  - Gradiente de fondo mágico
  - Logo animado de Hogwarts con efecto pulse
  - Partículas flotantes animadas
  - Barra de progreso de carga
  - Redirección automática después de 3 segundos
  - Efectos interactivos con el mouse

#### homepage_sorting_hat_experience.html (Página Principal)
- **Propósito**: Hub central de la experiencia del usuario
- **Características**:
  - Navegación principal responsiva
  - Sección hero con imagen del Sombrero Seleccionador
  - Tarjetas de las cuatro casas con información
  - Testimonios de usuarios
  - Sección de llamada a la acción
  - Footer completo con enlaces
  - Animaciones de scroll y hover

#### house_selection_portal_sorting_hat_quiz.html (Quiz del Sombrero)
- **Propósito**: Quiz interactivo para selección de casa
- **Características**:
  - Sistema de quiz con múltiples preguntas
  - Lógica de puntuación por casa
  - Pantalla de resultados personalizada
  - Animaciones de transición entre preguntas
  - Persistencia de resultados (localStorage)
  - Navegación móvil funcional

### Componentes Comunes

#### Navegación
- Logo SVG personalizado
- Menú desktop horizontal
- Menú móvil colapsable
- Enlaces activos con indicadores visuales
- Botón CTA destacado para "Mi Casa"

#### Footer
- Información de copyright
- Enlaces de navegación organizados
- Iconos de redes sociales
- Diseño responsivo en columnas

#### Tarjetas (Cards)
- Efecto hover con escala sutil
- Sombras de elevación
- Bordes redondeados mágicos
- Contenido estructurado semánticamente

#### Botones
- `btn-primary`: Botón principal con colores de Gryffindor
- `btn-secondary`: Botón secundario con colores dorados
- Estados hover con transiciones suaves
- Variantes de tamaño (sm, md, lg)

## Scripts y Funcionalidades JavaScript

### Scripts Principales
1. **Quiz del Sombrero Seleccionador**:
   - Array de preguntas con opciones múltiples
   - Sistema de puntuación por casa
   - Lógica de determinación de casa ganadora
   - Animaciones de transición
   - Persistencia en localStorage

2. **Animaciones de Interfaz**:
   - Intersection Observer para animaciones de scroll
   - Efectos de hover en tarjetas
   - Partículas flotantes interactivas
   - Transiciones suaves entre estados

3. **Navegación Móvil**:
   - Toggle de menú móvil
   - Gestión de estados activos
   - Responsive behavior

### Scripts Externos
- **dhws-data-injector.js**: Script de inyección de datos de DhiWise

## Configuración de Compilación

### Scripts NPM
```json
{
  "build:css": "npx @dhiwise/component-tagger && npx tailwindcss -i ./css/tailwind.css -o ./css/main.css",
  "watch:css": "npx @dhiwise/component-tagger && npx tailwindcss -i ./css/tailwind.css -o ./css/main.css --watch",
  "dev": "npm run watch:css"
}
```

### Proceso de Compilación
1. Ejecuta component-tagger de DhiWise
2. Compila Tailwind CSS desde `css/tailwind.css` a `css/main.css`
3. Incluye todas las configuraciones personalizadas
4. Optimiza para producción (cuando se usa build)

## Convenciones y Estándares del Proyecto

### Nomenclatura
- **Clases CSS**: kebab-case (ej. `house-card`, `magical-transition`)
- **IDs HTML**: camelCase (ej. `quizContainer`, `welcomeScreen`)
- **Funciones JS**: camelCase (ej. `startQuiz()`, `calculateHouse()`)
- **Archivos**: snake_case (ej. `sorting_hat_quiz.html`)

### Estructura HTML
- HTML5 semántico con elementos apropiados
- Atributos ARIA para accesibilidad
- Meta tags completos para SEO
- Estructura de encabezados jerárquica

### Estándares CSS
- Uso exclusivo de clases de utilidad de Tailwind
- Minimización de CSS personalizado
- Variables CSS para valores reutilizables
- Enfoque mobile-first

### JavaScript
- ES6+ moderno
- Funciones puras cuando sea posible
- Comentarios para lógica compleja
- Manejo de errores apropiado

## Características Implementadas

### ✅ Completadas
- [x] Navegación responsiva con menú móvil
- [x] Pantalla de bienvenida animada
- [x] Quiz completo del Sombrero Seleccionador
- [x] Sistema de tarjetas para contenido
- [x] Botones con estados hover y focus
- [x] Footer informativo
- [x] Animaciones CSS y JavaScript
- [x] Diseño responsivo completo
- [x] Sistema de colores temático
- [x] Tipografía personalizada

### 🔄 En Desarrollo
- [ ] Sistema de autenticación de usuarios
- [ ] Persistencia de datos en backend
- [ ] Foro interactivo funcional
- [ ] Sistema de logros y puntos
- [ ] Eventos y desafíos dinámicos

## Limitaciones y Problemas Conocidos

### Limitaciones Técnicas
1. **Sin Backend**: No hay persistencia de datos entre sesiones
2. **Compatibilidad**: Optimizado para navegadores modernos
3. **Rendimiento**: Las imágenes necesitan optimización adicional
4. **PWA**: Manifest.json básico, falta service worker

### Problemas de Accesibilidad
1. Contraste de colores en algunos elementos
2. Navegación por teclado mejorable
3. Lectores de pantalla necesitan más atributos ARIA

## Mejoras Futuras Planificadas

### Prioridad Alta
1. Implementar backend para persistencia de datos
2. Sistema de autenticación de usuarios
3. Mejorar accesibilidad general
4. Optimización de imágenes y rendimiento

### Prioridad Media
1. Convertir a Progressive Web App completa
2. Implementar sistema de notificaciones
3. Añadir más animaciones y efectos
4. Sistema de temas por casa más avanzado

### Prioridad Baja
1. Integración con APIs externas de Harry Potter
2. Sistema de chat en tiempo real
3. Gamificación avanzada
4. Modo oscuro/claro

## Reglas de Mantenimiento

### Actualización de Documentación
- Actualizar este archivo con cada cambio significativo
- Mantener sincronizada la documentación técnica
- Seguir las reglas en `documentation_rules.md`
- Usar la checklist en `documentation_checklist.md`

### Desarrollo
- Seguir las convenciones establecidas
- Mantener el sistema de diseño coherente
- Probar en múltiples dispositivos y navegadores
- Documentar nuevos componentes

### Despliegue
- Compilar CSS antes del despliegue
- Verificar que todas las imágenes cargan correctamente
- Probar la navegación completa
- Validar HTML y accesibilidad

---

## Registro de Actualizaciones

| Fecha | Cambio | Autor |
|-------|--------|-------|
| 2025-01-20 | Creación inicial de la memoria completa de estructura | Rovo Dev |

---

**Nota Importante**: Este documento debe consultarse SIEMPRE antes de realizar modificaciones al proyecto. Mantenerlo actualizado es crucial para la coherencia y calidad del desarrollo.