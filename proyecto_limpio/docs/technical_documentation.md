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
├── js/                # JavaScript modular
│   ├── community-events.js    # Sistema de eventos y desafíos
│   ├── auth.js                # Autenticación con Supabase
│   ├── supabase-client.js     # Cliente de base de datos
│   └── [otros módulos...]
├── docs/              # Documentación del proyecto
├── sql/               # Scripts SQL para base de datos
├── supabase/          # Migraciones y configuración de Supabase
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
8. **Administración**: `pages/event-admin.html` - Panel de administración de eventos

## Stack Tecnológico

### Frontend

- **HTML5**: Estructura semántica
- **CSS3/Tailwind CSS**: Estilos y diseño responsivo
- **JavaScript (ES6+)**: Interactividad y manipulación del DOM
- **Web Fonts**: Google Fonts (EB Garamond, Lato, Open Sans, Cinzel)

### Backend & Base de Datos

- **Supabase**: Plataforma backend-as-a-service
- **PostgreSQL**: Base de datos relacional
- **Row Level Security (RLS)**: Políticas de seguridad a nivel de fila
- **Real-time subscriptions**: Actualizaciones en tiempo real

### Herramientas de Desarrollo

- **Node.js**: Entorno de ejecución
- **npm**: Gestor de paquetes
- **PostCSS**: Procesamiento de CSS
- **Tailwind CLI**: Compilación de CSS
- **Supabase CLI**: Gestión de base de datos

## Sistema de Eventos y Desafíos

### Arquitectura del Sistema

El sistema de eventos es un componente complejo que incluye:

#### Componentes Principales

1. **Centro de Eventos** (`community_events_challenges_center.html`)
   - Página principal que muestra eventos destacados, próximos eventos y calendario
   - Secciones dinámicas que se cargan vía JavaScript
   - Sistema de votación comunitaria

2. **Panel de Administración** (`event-admin.html`)
   - Interfaz para crear y gestionar eventos
   - Formulario con validación para nuevos eventos
   - Gestión de estado (borrador/activo)

3. **Detalle de Eventos** (`event-detail.html`)
   - Página dinámica para ver detalles individuales de eventos
   - Sistema de participación y seguimiento
   - Compartir eventos en redes sociales

#### Funciones de Base de Datos

```sql
-- Funciones principales del sistema de eventos
CREATE OR REPLACE FUNCTION public.create_event(...) RETURNS uuid
CREATE OR REPLACE FUNCTION public.update_event(...) RETURNS void
CREATE OR REPLACE FUNCTION public.delete_event(...) RETURNS void
CREATE OR REPLACE FUNCTION public.activate_event(...) RETURNS void
CREATE OR REPLACE FUNCTION public.list_featured_events(...) RETURNS TABLE(...)
CREATE OR REPLACE FUNCTION public.list_upcoming_events(...) RETURNS TABLE(...)
CREATE OR REPLACE FUNCTION public.list_calendar_events_detailed(...) RETURNS TABLE(...)
```

#### Estructura de Datos

```sql
-- Tabla principal de eventos
CREATE TABLE public.events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  slug text UNIQUE NOT NULL,
  description text,
  type text CHECK (type IN ('tournament', 'contest', 'celebration')),
  status text DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'completed')),
  featured boolean DEFAULT false,
  start_at timestamptz NOT NULL,
  end_at timestamptz NOT NULL,
  reward_points int DEFAULT 0,
  cover_url text,
  created_by uuid REFERENCES auth.users(id),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Tabla de participantes
CREATE TABLE public.event_participants (
  event_id uuid REFERENCES public.events(id) ON DELETE CASCADE,
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  status text DEFAULT 'joined' CHECK (status IN ('joined', 'participating', 'completed')),
  joined_at timestamptz DEFAULT now(),
  PRIMARY KEY (event_id, user_id)
);
```

### Funcionalidades Implementadas

#### ✅ Sistema de Eventos Completamente Funcional

1. **Creación y Gestión de Eventos**
   - Formulario de creación con validación
   - Estados: borrador → activo → completado
   - Categorías: torneo, concurso, celebración
   - Sistema de puntos de recompensa

2. **Visualización Dinámica**
   - Eventos destacados en la página principal
   - Lista de próximos eventos
   - Calendario interactivo con marcadores visuales
   - Eventos pasados en archivo histórico

3. **Sistema de Participación**
   - Unirse a eventos con un clic
   - Seguimiento de participación
   - Sistema de logros y puntos
   - Tabla de posiciones por usuario y casa

4. **Desafíos Individuales y por Casa**
   - Desafíos individuales con progreso personal
   - Desafíos colectivos por casa
   - Sistema de recompensas
   - Estadísticas de completación

5. **Sistema de Votación**
   - Encuestas activas de la comunidad
   - Votación en tiempo real
   - Resultados históricos
   - Estadísticas de participación

6. **Funciones de Compartir**
   - Compartir eventos en redes sociales
   - Copiar enlace al portapapeles
   - Integración con APIs nativas de compartir

#### JavaScript Architecture

```javascript
// community-events.js - Módulo principal
async function fetchFeaturedEvents(limit = 6) {
  // Obtener eventos destacados de Supabase
}

async function fetchUpcoming(limit = 5) {
  // Obtener próximos eventos
}

async function fetchCalendar(month, year) {
  // Obtener eventos para calendario
}

function renderFeaturedEvents(items) {
  // Renderizar eventos destacados
}

function markCalendarDays(events) {
  // Marcar días en calendario
}
```

## Configuración del Entorno de Desarrollo

### Requisitos Previos

- Node.js v12.x o superior
- npm o yarn
- Cuenta de Supabase (para funcionalidades completas)

### Instalación

```bash
# Instalar dependencias
npm install

# Iniciar servidor de desarrollo con recarga automática de CSS
npm run dev

# Compilar CSS para producción
npm run build:css
```

### Configuración de Supabase

1. Crear proyecto en Supabase
2. Ejecutar migraciones de base de datos:
   ```bash
   supabase db push --file supabase/migrations/20250811_community_events_backend.sql
   supabase db push --file supabase/migrations/20250925_event_crud_rpcs.sql
   ```
3. Aplicar datos de ejemplo:
   ```bash
   supabase db push --file supabase/migrations/20250811_seed_community_events.sql
   ```

## Componentes Principales

### Sistema de Navegación

La navegación principal se implementa como un componente responsivo:

```html
<nav class="bg-surface/95 backdrop-blur-sm border-b border-primary/20 sticky top-0 z-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
            <!-- Logo y navegación -->
        </div>
    </div>
</nav>
```

### Tarjetas de Contenido

```html
<div class="card overflow-hidden hover-scale group">
    <div class="p-6">
        <!-- Contenido -->
    </div>
</div>
```

### Sistema de Autenticación

Integración completa con Supabase Auth:

```javascript
// auth.js
const supabase = createClient(supabaseUrl, supabaseKey);

async function signIn(email, password) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password
  });
  return { data, error };
}
```

## Sistema de Diseño

### Variables CSS

```css
:root {
  /* Colores primarios */
  --color-primary: #740001;
  --color-secondary: #C9A961;
  --color-accent: #0E1A40;

  /* Espaciado */
  --space-xs: 0.25rem;
  --space-sm: 0.5rem;
  --space-md: 1rem;

  /* Sombras */
  --shadow-card: 0 4px 12px rgba(44, 44, 44, 0.08);
  --shadow-elevated: 0 8px 24px rgba(44, 44, 44, 0.12);
}
```

### Tema por Casa

Clases específicas para cada casa de Hogwarts:

```css
.text-gryffindor { color: #740001; }
.text-hufflepuff { color: #FFD800; }
.text-ravenclaw { color: #0E1A40; }
.text-slytherin { color: #1A472A; }
```

## JavaScript Modular

### Estructura de Módulos

- `auth.js` - Autenticación y gestión de usuarios
- `community-events.js` - Sistema de eventos y desafíos
- `supabase-client.js` - Cliente de base de datos
- `universal-nav.js` - Navegación universal

### Patrones de Programación

```javascript
// Patrón de módulo con async/await
async function fetchData() {
  try {
    const client = await ensureClient();
    const { data, error } = await client.rpc('function_name', params);
    if (error) throw error;
    return data;
  } catch (e) {
    console.error('Error:', e);
    return null;
  }
}
```

## Compilación y Despliegue

### Proceso de Desarrollo

1. Editar archivos fuente
2. `npm run dev` para desarrollo con hot reload
3. `npm run build:css` para producción

### Despliegue

```bash
# Construir para producción
npm run build:css

# Desplegar archivos estáticos en cualquier servidor web
# Los archivos incluyen: HTML, CSS compilado, JS, y recursos
```

## Solución de Problemas

### Problemas Comunes del Sistema de Eventos

#### Eventos no aparecen en la página principal

**Síntomas**: Se muestra "Cargando eventos..." pero nunca se cargan.

**Soluciones**:
1. Verificar que las funciones RPC existen en Supabase
2. Comprobar que hay eventos con `status = 'active'` y `featured = true`
3. Revisar la consola del navegador para errores de JavaScript

#### Calendario no marca los días correctamente

**Síntomas**: El calendario se muestra pero los días con eventos no están marcados.

**Soluciones**:
1. Verificar que `list_calendar_events_detailed` existe
2. Comprobar que los eventos tienen fechas válidas
3. Revisar que el mes/año del calendario es correcto

#### Error al crear eventos

**Síntomas**: El formulario de creación falla al enviar.

**Soluciones**:
1. Verificar autenticación del usuario
2. Comprobar permisos de la función `create_event`
3. Validar que todos los campos requeridos están presentes

### Scripts de Diagnóstico

- `diagnose_events.html` - Verificar estado de eventos y funciones
- `check_event_rpcs.html` - Probar funciones RPC manualmente
- `test_event_rpcs.html` - Ejecutar pruebas automatizadas

## Actualizaciones Recientes

### ✅ Sistema de Eventos Completamente Implementado

**Fecha**: Septiembre 2025

**Cambios principales**:
- ✅ Implementación completa del sistema de eventos
- ✅ Funciones CRUD para gestión de eventos
- ✅ Sistema de participación y seguimiento
- ✅ Calendario interactivo con marcadores visuales
- ✅ Desafíos individuales y por casa
- ✅ Sistema de votación comunitaria
- ✅ Funcionalidades de compartir en redes sociales
- ✅ Panel de administración de eventos
- ✅ Páginas de detalle dinámicas
- ✅ Integración completa con Supabase

**Archivos modificados**:
- `pages/community_events_challenges_center.html`
- `pages/event-admin.html`
- `pages/event-detail.html`
- `js/community-events.js`
- `supabase/migrations/20250925_event_crud_rpcs.sql`
- `supabase/migrations/20250811_seed_community_events.sql`

## Conclusión

Esta documentación técnica proporciona una visión completa de la arquitectura, componentes y patrones utilizados en el proyecto "Hogwarts Community Hub". El sistema de eventos representa una implementación avanzada de funcionalidades interactivas con integración completa de base de datos y UI/UX moderna.