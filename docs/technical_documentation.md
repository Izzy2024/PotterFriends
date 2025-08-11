# Documentación Técnica - Hogwarts Community Hub

## Introducción

Esta documentación técnica proporciona una visión detallada de la arquitectura, componentes y flujos de trabajo del proyecto "Hogwarts Community Hub". Está diseñada para desarrolladores que necesiten entender, mantener o extender la aplicación.

## Arquitectura General

### Estructura de Archivos

```
hogwarts_community_hub/
├── css/
│   ├── tailwind.css   # Archivo fuente de Tailwind con utilidades personalizadas
│   └── main.css       # CSS compilado (generado automáticamente)
├── pages/             # Páginas HTML de la aplicación
│   ├── community_events_challenges_center.html
│   ├── homepage_sorting_hat_experience.html
│   ├── house_common_rooms_personalized_dashboards.html
│   ├── house_selection_portal_sorting_hat_quiz.html
│   ├── interactive_forum_hub.html
│   └── user_profile_achievement_system.html
├── docs/              # Documentación del proyecto
├── index.html         # Página de entrada con animación de carga
├── package.json       # Dependencias y scripts del proyecto
└── tailwind.config.js # Configuración personalizada de Tailwind CSS
```

### Flujo de Navegación

1. **Entrada**: `index.html` - Pantalla de carga animada
2. **Página Principal**: `pages/homepage_sorting_hat_experience.html` - Hub central
3. **Selección de Casa**: `pages/house_selection_portal_sorting_hat_quiz.html` - Quiz interactivo
4. **Salas Comunes**: `pages/house_common_rooms_personalized_dashboards.html` - Áreas específicas por casa
5. **Perfil de Usuario**: `pages/user_profile_achievement_system.html` - Información y logros del usuario
6. **Foro**: `pages/interactive_forum_hub.html` - Discusiones de la comunidad
7. **Eventos**: `pages/community_events_challenges_center.html` - Actividades y desafíos

## Stack Tecnológico

### Frontend

- **HTML5**: Estructura semántica
- **CSS3/Tailwind CSS**: Estilos y diseño responsivo
- **JavaScript (ES6+)**: Interactividad y manipulación del DOM
- **Web Fonts**: Google Fonts (EB Garamond, Lato, Open Sans, Cinzel)

### Herramientas de Desarrollo

- **Node.js**: Entorno de ejecución
- **npm**: Gestor de paquetes
- **PostCSS**: Procesamiento de CSS
- **Tailwind CLI**: Compilación de CSS

## Configuración del Entorno de Desarrollo

### Requisitos Previos

- Node.js v12.x o superior
- npm o yarn

### Instalación

```bash
# Instalar dependencias
npm install

# Iniciar servidor de desarrollo con recarga automática de CSS
npm run dev

# Compilar CSS para producción
npm run build:css
```

### Scripts NPM

- `build:css`: Compila el CSS para producción
- `watch:css`: Compila el CSS y observa cambios
- `dev`: Alias para watch:css

## Componentes Principales

### Sistema de Navegación

La navegación principal se implementa como un componente responsivo que se adapta a diferentes tamaños de pantalla:

```html
<nav class="bg-surface/95 backdrop-blur-sm border-b border-primary/20 sticky top-0 z-50">
    <!-- Contenido de navegación -->
</nav>
```

**Características**:
- Barra fija en la parte superior (`sticky top-0`)
- Fondo semi-transparente con efecto de desenfoque (`bg-surface/95 backdrop-blur-sm`)
- Menú hamburguesa para dispositivos móviles
- Indicador visual para la página activa

### Tarjetas de Contenido

Las tarjetas son un componente fundamental para mostrar información:

```html
<div class="card p-6 hover-scale">
    <!-- Contenido de la tarjeta -->
</div>
```

**Implementación CSS**:
```css
.card {
  background-color: var(--color-surface);
  border-radius: 8px;
  box-shadow: var(--shadow-card);
  transition: var(--transition-gentle);
}

.card:hover {
  transform: scale(var(--scale-hover));
  box-shadow: var(--shadow-elevated);
}
```

### Botones

El sistema incluye varios estilos de botones:

```html
<button class="btn-primary px-6 py-3 rounded-lg hover-scale magical-transition">
    Texto del Botón
</button>
```

**Variantes**:
- `btn-primary`: Botón principal en color primario
- `btn-secondary`: Botón secundario en color dorado
- Modificadores: tamaños, bordes redondeados, iconos

### Quiz del Sombrero Seleccionador

El quiz es un componente interactivo complejo que:

1. Presenta preguntas secuencialmente
2. Registra respuestas del usuario
3. Calcula la casa más compatible
4. Muestra una animación de revelación
5. Proporciona detalles sobre la casa asignada

**Estructura de Datos**:
```javascript
const quizQuestions = [
    {
        question: "Pregunta...",
        answers: [
            { text: "Respuesta 1", house: "gryffindor", points: 3 },
            { text: "Respuesta 2", house: "hufflepuff", points: 3 },
            // Más respuestas...
        ]
    },
    // Más preguntas...
];
```

## Sistema de Diseño

### Variables CSS

El proyecto utiliza variables CSS para mantener la consistencia:

```css
:root {
  /* Colores primarios */
  --color-primary: #740001;
  --color-primary-50: #FEF2F2;
  /* Más variables... */
}
```

### Tokens de Diseño

#### Colores

- **Primarios**: Basados en Gryffindor (`#740001`)
- **Secundarios**: Dorado mágico (`#C9A961`)
- **Acento**: Azul Ravenclaw (`#0E1A40`)
- **Fondo**: Pergamino cálido (`#F4F1E8`)
- **Superficie**: Elevación sutil (`#FEFCF7`)
- **Texto**: Primario (`#2C2C2C`), Secundario (`#5D5D5D`)
- **Estado**: Éxito (`#1A472A`), Advertencia (`#FFD800`), Error (`#8B0000`)
- **Casas**: Gryffindor (`#740001`), Hufflepuff (`#FFD800`), Ravenclaw (`#0E1A40`), Slytherin (`#1A472A`)

#### Tipografía

- **Títulos**: 'EB Garamond', serif
- **Cuerpo**: 'Lato', sans-serif
- **CTA**: 'Open Sans', sans-serif
- **Acento**: 'Cinzel', serif

#### Espaciado

Sistema de espaciado basado en múltiplos de 0.25rem:
- 4px (0.25rem)
- 8px (0.5rem)
- 12px (0.75rem)
- 16px (1rem)
- 24px (1.5rem)
- 32px (2rem)
- 48px (3rem)
- 64px (4rem)
- 72px (4.5rem) - Personalizado como `18`
- 352px (22rem) - Personalizado como `88`

#### Sombras

- **Sutil**: `0 2px 8px rgba(44, 44, 44, 0.1)`
- **Tarjeta**: `0 4px 12px rgba(44, 44, 44, 0.08)`
- **Elevado**: `0 8px 24px rgba(44, 44, 44, 0.12)`

#### Transiciones

- **Duración**: 300ms
- **Timing**: ease-out
- **Escala Hover**: 1.02

## Patrones de Implementación

### Diseño Responsivo

El proyecto sigue un enfoque mobile-first con breakpoints de Tailwind:

- `sm`: 640px y superior
- `md`: 768px y superior
- `lg`: 1024px y superior
- `xl`: 1280px y superior
- `2xl`: 1536px y superior

**Ejemplo**:
```html
<div class="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
    <!-- Contenido que se adapta a diferentes tamaños -->
</div>
```

### Animaciones y Transiciones

Las animaciones se implementan mediante:

1. **Clases de Utilidad**:
   ```html
   <div class="hover-scale magical-transition">
       <!-- Contenido con animación -->
   </div>
   ```

2. **CSS Personalizado**:
   ```css
   .magical-transition {
     transition: var(--transition-gentle);
   }

   .hover-scale:hover {
     transform: scale(var(--scale-hover));
   }
   ```

3. **Animaciones Keyframe**:
   ```css
   @keyframes pulse {
       0%, 100% { transform: scale(1); }
       50% { transform: scale(1.05); }
   }
   ```

### Tematización por Casa

El sistema permite aplicar estilos específicos por casa:

```html
<div class="border-l-4 border-gryffindor">
    <!-- Contenido con tema de Gryffindor -->
</div>
```

**Clases de Utilidad**:
- `.text-gryffindor`, `.bg-gryffindor`, `.border-gryffindor`
- `.text-hufflepuff`, `.bg-hufflepuff`, `.border-hufflepuff`
- `.text-ravenclaw`, `.bg-ravenclaw`, `.border-ravenclaw`
- `.text-slytherin`, `.bg-slytherin`, `.border-slytherin`

## JavaScript

### Funciones Principales

#### Navegación Móvil

```javascript
function toggleMobileMenu() {
    const mobileMenu = document.getElementById('mobileMenu');
    mobileMenu.classList.toggle('hidden');
}
```

#### Quiz del Sombrero Seleccionador

```javascript
// Iniciar el quiz
function startQuiz() {
    document.getElementById('welcomeScreen').classList.add('hidden');
    document.getElementById('quizScreen').classList.remove('hidden');
    loadQuestion(currentQuestionIndex);
}

// Cargar pregunta
function loadQuestion(index) {
    const question = quizQuestions[index];
    document.getElementById('questionText').textContent = question.question;
    document.getElementById('currentQuestion').textContent = index + 1;
    document.getElementById('progressPercent').textContent = Math.round(((index + 1) / quizQuestions.length) * 100);
    document.getElementById('progressBar').style.width = `${((index + 1) / quizQuestions.length) * 100}%`;
    
    // Cargar opciones de respuesta
    const answerContainer = document.getElementById('answerOptions');
    answerContainer.innerHTML = '';
    
    question.answers.forEach((answer, i) => {
        const option = document.createElement('div');
        option.className = 'answer-option bg-surface/30 backdrop-blur-sm rounded-lg p-4 border border-white/10 cursor-pointer hover:bg-surface/50 magical-transition';
        option.dataset.index = i;
        option.innerHTML = answer.text;
        option.addEventListener('click', () => selectAnswer(index, i));
        answerContainer.appendChild(option);
    });
}

// Más funciones del quiz...
```

## Compilación y Despliegue

### Proceso de Desarrollo

1. Editar archivos fuente (HTML, CSS en `tailwind.css`)
2. Los cambios en CSS se compilan automáticamente con `npm run dev`
3. Refrescar el navegador para ver los cambios

### Compilación para Producción

1. Ejecutar `npm run build:css` para generar CSS optimizado
2. Los archivos listos para producción son:
   - Todos los archivos HTML
   - `css/main.css` (compilado)
   - Cualquier recurso estático referenciado

### Consideraciones de Despliegue

- El proyecto es estático y puede desplegarse en cualquier servidor web
- No requiere backend para la funcionalidad básica
- Para características avanzadas (autenticación, persistencia) se necesitaría implementar un backend

## Guías de Estilo y Convenciones

### HTML

- Usar elementos semánticos (`nav`, `section`, `article`, etc.)
- Mantener la indentación consistente (2 espacios)
- Incluir atributos ARIA para accesibilidad
- Usar clases de Tailwind para estilos

### CSS

- Seguir la estructura de capas de Tailwind (base, components, utilities)
- Usar variables CSS para valores reutilizables
- Minimizar CSS personalizado, favoreciendo clases de utilidad

### JavaScript

- Usar funciones nombradas para mejor legibilidad
- Seguir principios de programación funcional cuando sea posible
- Evitar variables globales innecesarias
- Comentar código complejo o no obvio

## Solución de Problemas Comunes

### Estilos No Aplicados

**Problema**: Los estilos de Tailwind no se aplican correctamente.

**Solución**:
1. Verificar que `main.css` se ha generado correctamente
2. Comprobar que la ruta al CSS es correcta en el HTML
3. Ejecutar `npm run build:css` para regenerar el CSS
4. Verificar que las clases están escritas correctamente

### Problemas de Responsividad

**Problema**: El diseño no se adapta correctamente a diferentes tamaños de pantalla.

**Solución**:
1. Verificar el uso de clases responsivas (`sm:`, `md:`, `lg:`, etc.)
2. Comprobar la estructura de contenedores y grid
3. Usar herramientas de desarrollo del navegador para inspeccionar en diferentes tamaños

### JavaScript No Funciona

**Problema**: Las funcionalidades interactivas no responden.

**Solución**:
1. Verificar la consola del navegador para errores
2. Comprobar que los IDs de los elementos coinciden con los referenciados en JS
3. Verificar que el script se carga después de los elementos del DOM
4. Añadir `console.log()` para depurar el flujo de ejecución

## Recursos Adicionales

### Referencias de Tailwind CSS

- [Documentación oficial de Tailwind CSS](https://tailwindcss.com/docs)
- [Tailwind UI Components](https://tailwindui.com/components)
- [Tailwind Cheat Sheet](https://nerdcave.com/tailwind-cheat-sheet)

### Herramientas Útiles

- [Tailwind Play](https://play.tailwindcss.com/) - Entorno de pruebas en línea
- [Heroicons](https://heroicons.com/) - Iconos SVG compatibles con Tailwind
- [Tailwind CSS IntelliSense](https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss) - Extensión para VS Code

### Inspiración de Diseño

- [Dribbble - Harry Potter UI](https://dribbble.com/search/harry-potter)
- [Behance - Wizarding World Designs](https://www.behance.net/search/projects?search=wizarding%20world)

## Conclusión

Esta documentación técnica proporciona una visión completa de la arquitectura, componentes y patrones utilizados en el proyecto "Hogwarts Community Hub". Siguiendo estas guías y convenciones, los desarrolladores pueden mantener y extender el proyecto de manera consistente y eficiente.
## 🐛 
Solución de Problemas de Navegación

### Errores 404 (Not Found)

**Problema**: Las páginas muestran error 404 o no se cargan.

**Solución**:
1. Asegúrate de iniciar el servidor HTTP correctamente:
   ```bash
   ./start-server.sh
   ```
2. Verifica que estés accediendo a la URL correcta: `http://127.0.0.1:8080/index.html`
3. Si hay problemas con enlaces, ejecuta el script de corrección:
   ```bash
   node fix-login-links.js
   ```

### Redirecciones Incorrectas

**Problema**: Los enlaces redirigen a páginas que no existen (ej: auth_login.html).

**Solución**:
1. Ejecuta el script de corrección de enlaces:
   ```bash
   node fix-login-links.js
   ```
2. Usa la página de debug para identificar problemas: `http://127.0.0.1:8080/debug-login.html`

### Problemas de Autenticación

**Problema**: El sistema de login no funciona o redirige incorrectamente.

**Solución**:
1. Verifica que Supabase esté configurado correctamente:
   ```bash
   node test-auth-simple.js
   ```
2. Revisa la consola del navegador (F12) para ver errores de JavaScript
3. Asegúrate de que las tablas estén creadas en Supabase
4. Verifica que el servidor HTTP esté corriendo desde el directorio correcto

## 📋 Scripts de Diagnóstico

- `debug-login.html` - Página para diagnosticar problemas de navegación
- `fix-login-links.js` - Script para corregir enlaces incorrectos
- `test-auth-simple.js` - Prueba básica de autenticación
- `hello.html` - Página de prueba del servidor HTTP