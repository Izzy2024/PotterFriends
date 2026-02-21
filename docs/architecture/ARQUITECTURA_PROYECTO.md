# 🏰 ARQUITECTURA DEL PROYECTO - Hogwarts PotterFriends

## ⚠️ Estado Actual (Actualizado: 19 de febrero de 2026)

Este documento nació con enfoque **Supabase BaaS**, pero hoy el proyecto opera con arquitectura híbrida local:

- Frontend en `pages/` + `js/`
- Backend local en `/Users/admin/Documents/Paginas web/hogwarts_PotterFriends/server/index.js` (Express)
- Base de datos PostgreSQL local
- Cliente unificado en `/Users/admin/Documents/Paginas web/hogwarts_PotterFriends/src/scripts/auth.js` que emula API estilo Supabase (`from`, `rpc`, etc.)

### Cambios clave respecto al documento original

- No se usa CDN de `supabase-client.js` en páginas funcionales.
- Las operaciones DB pasan por API local (`/api/db/select`, `/api/db/insert`, `/api/db/update`, `/api/db/delete`, `/api/db/rpc`).
- El sistema de logros automáticos se ejecuta por RPC local + fallback backend.
- Vistas de foro/perfil se adaptaron al esquema real de `user_profiles` (usar `display_name`).

### Estado del sistema de logros (real)

- Tablas base presentes: `achievement_types`, `user_achievements`, `user_statistics`, `user_profiles`.
- Flujo automático activo:
  - `update_user_stat`
  - `check_and_award_achievements`
- El perfil ahora fuerza chequeo de logros antes de renderizar, para mostrar logros nuevos inmediatamente.

---

## 📋 Resumen Ejecutivo

**Hogwarts PotterFriends** es una aplicación web interactiva que simula la experiencia de la comunidad mágica de Hogwarts. Los usuarios pueden unirse a casas, ganar puntos, participar en foros, completar logros y vivir una experiencia inmersiva del mundo mágico de Harry Potter.

### 🎯 Propósito del Proyecto
- **Comunidad Temática**: Crear un hub social para fanáticos de Harry Potter
- **Gamificación**: Sistema de puntos, logros y competencia entre casas
- **Experiencia Inmersiva**: UI/UX que recrea la atmósfera mágica de Hogwarts
- **Gestión de Usuario**: Sistema completo de perfiles, autenticación y administración

---

## 🛠️ Stack Tecnológico

### Frontend
- **HTML5** - Estructura semántica y accesibilidad
- **CSS3** + **Tailwind CSS 3.4.17** - Framework de diseño utility-first
- **JavaScript ES6+** - Lógica de cliente e interactividad
- **Fonts**: EB Garamond, Lato, Open Sans, Cinzel

### Backend & Base de Datos
- **Supabase** - BaaS (Backend as a Service)
  - PostgreSQL como base de datos principal
  - Autenticación integrada
  - Row Level Security (RLS)
  - Real-time subscriptions
  - API REST automática

### Build Tools & Development
- **NPM** - Gestión de paquetes
- **Tailwind CSS CLI** - Compilación de estilos
- **Live Server** - Servidor de desarrollo
- **Playwright** - Testing automatizado
- **@stagewise/toolbar** - Herramientas de desarrollo

### Servicios Externos
- **CDN de Supabase** - Cliente JavaScript
- **Google Fonts** - Tipografías personalizadas
- **Unsplash/Pexels** - Imágenes de alta calidad

---

## 🏗️ Arquitectura del Sistema

### Patrón Arquitectónico
```
CLIENTE (SPA) ←→ SUPABASE (BaaS) ←→ POSTGRESQL
```

### Flujo de Datos
```
Usuario → Frontend (JS) → Supabase Client → PostgreSQL → RLS Policies → Response
```

### Arquitectura de Componentes
```
├── Presentación (HTML/CSS/TailwindCSS)
├── Lógica de Negocio (JavaScript ES6+)
├── Gestión de Estado (LocalStorage + Supabase)
├── Autenticación (Supabase Auth)
├── Base de Datos (PostgreSQL + RLS)
└── APIs (Supabase REST + Real-time)
```

---

## 📁 Estructura del Proyecto

```
hogwarts_PotterFriends/
├── 📄 index.html                          # Página de bienvenida con splash screen
├── 📄 package.json                        # Dependencias y scripts del proyecto
├── 📄 tailwind.config.js                  # Configuración de Tailwind con tema personalizado
├── 📄 start-server.sh                     # Script para iniciar servidor de desarrollo
│
├── 📁 pages/                              # Páginas principales de la aplicación
│   ├── 📄 homepage_sorting_hat_experience.html     # Página principal con hero section
│   ├── 📄 user_login.html                          # Sistema de login
│   ├── 📄 user_registration.html                   # Registro de nuevos usuarios
│   ├── 📄 email_verification_pending.html          # Verificación de email
│   ├── 📄 forgot_password.html                     # Recuperación de contraseña
│   ├── 📄 reset_password.html                      # Reset de contraseña
│   ├── 📄 house_selection_portal_sorting_hat_quiz.html  # Quiz del sombrero seleccionador
│   ├── 📄 house_common_rooms_personalized_dashboards.html  # Salas comunes por casa
│   ├── 📄 user_profile_achievement_system.html     # Perfil de usuario y logros
│   ├── 📄 interactive_forum_hub.html               # Sistema de foros
│   ├── 📄 community_events_challenges_center.html  # Centro de eventos
│   └── 📄 house_head_admin_panel.html              # Panel de administración
│
├── 📁 js/                                 # Módulos JavaScript
│   ├── 📄 auth.js                         # Sistema de autenticación y gestión de usuarios
│   ├── 📄 universal-nav.js               # Navegación dinámica universal
│   ├── 📄 profile-system.js              # Sistema de perfiles de usuario
│   ├── 📄 achievement-tracker.js         # Seguimiento automático de logros
│   ├── 📄 house-head-admin.js            # Panel de administración de jefes de casa
│   └── 📄 stagewise-init.js              # Inicialización de herramientas de desarrollo
│
├── 📁 css/                               # Estilos y temas
│   ├── 📄 main.css                       # Estilos compilados de Tailwind
│   ├── 📄 tailwind.css                   # Archivo fuente de Tailwind
│   └── 📄 admin-panel.css               # Estilos específicos para panel admin
│
├── 📁 tests/                            # Archivos de testing
│   ├── 📄 test.html                     # Tests básicos
│   ├── 📄 test-navigation.html          # Tests de navegación
│   └── 📄 test-page.html               # Tests de páginas
│
├── 📁 node_modules/                     # Dependencias (auto-generado)
│
├── 📄 DOCUMENTACION_MEJORAS_SISTEMA_CASAS.md  # Documentación de mejoras implementadas
├── 📄 setup_harry_potter_achievements.sql     # Script SQL para sistema de logros
├── 📄 fix_unique_constraint.sql              # Fixes de base de datos
└── 📄 tmp_*.* / debug_*.*                    # Archivos temporales y de debug
```

---

## 🎨 Sistema de Diseño

### Paleta de Colores Temática

#### Colores de Casa
```css
--gryffindor: #740001    /* Rojo profundo - Valor y coraje */
--hufflepuff: #FFD800    /* Amarillo dorado - Lealtad y trabajo */
--ravenclaw: #0E1A40     /* Azul profundo - Sabiduría e inteligencia */
--slytherin: #1A472A     /* Verde esmeralda - Ambición y astucia */
```

#### Colores Funcionales
```css
--primary: #740001       /* Acciones principales (Gryffindor) */
--secondary: #C9A961     /* Elementos dorados mágicos */
--accent: #0E1A40        /* Estados reflexivos (Ravenclaw) */
--success: #1A472A       /* Confirmaciones (Slytherin green) */
--warning: #FFD800       /* Atención (Hufflepuff) */
--error: #8B0000         /* Errores y alertas */
--background: #F4F1E8    /* Pergamino cálido */
--surface: #FEFCF7       /* Elevación sutil */
```

### Tipografía Temática
```css
font-headline: 'EB Garamond'    /* Elegancia académica antigua */
font-body: 'Lato'              /* Lectura cómoda moderna */
font-cta: 'Open Sans'          /* Confianza en acciones */
font-accent: 'Cinzel'          /* Gravitas mágica ceremonial */
```

### Componentes UI Reutilizables
- **Cards mágicas** con sombras sutiles y bordes dorados
- **Botones temáticos** con efectos hover y escalado
- **Navegación adaptiva** con estados dinámicos
- **Formularios elegantes** con validación en tiempo real
- **Modales inmersivos** con blur backdrop

---

## 🗄️ Arquitectura de Base de Datos

### Esquema Principal

#### Tabla: `auth.users` (Supabase Auth)
```sql
id: UUID PRIMARY KEY
email: TEXT UNIQUE
created_at: TIMESTAMP
email_confirmed_at: TIMESTAMP
user_metadata: JSONB
```

#### Tabla: `user_profiles`
```sql
id: UUID PRIMARY KEY REFERENCES auth.users(id)
display_name: TEXT
bio: TEXT
house: TEXT (gryffindor|hufflepuff|ravenclaw|slytherin)
house_points: INTEGER DEFAULT 0
avatar_url: TEXT
privacy_public_profile: BOOLEAN DEFAULT true
privacy_show_stats: BOOLEAN DEFAULT true
privacy_allow_messages: BOOLEAN DEFAULT true
role: text DEFAULT 'student'::text
is_house_head: BOOLEAN DEFAULT false
created_at: TIMESTAMP DEFAULT NOW()
updated_at: TIMESTAMP DEFAULT NOW()
```

#### Tabla: `profiles` (Alternativa/Legacy)
```sql
id: UUID PRIMARY KEY REFERENCES auth.users(id)
wizard_name: TEXT
first_name: TEXT
last_name: TEXT
email: TEXT
house: TEXT
house_selected_at: TIMESTAMPTZ
role: TEXT DEFAULT 'student'
is_house_head: BOOLEAN DEFAULT false
```

#### Tabla: `achievement_types`
```sql
id: SERIAL PRIMARY KEY
name: TEXT UNIQUE NOT NULL
description: TEXT
icon: TEXT DEFAULT '🏆'
points_reward: INTEGER DEFAULT 0
category: TEXT
trigger_condition: TEXT
auto_award: BOOLEAN DEFAULT true
is_active: BOOLEAN DEFAULT true
created_at: TIMESTAMPTZ DEFAULT NOW()
```

#### Tabla: `user_achievements`
```sql
id: SERIAL PRIMARY KEY
user_id: UUID REFERENCES auth.users(id) ON DELETE CASCADE
achievement_type_id: INTEGER REFERENCES achievement_types(id)
awarded_by: UUID REFERENCES auth.users(id)
reason: TEXT
awarded_at: TIMESTAMPTZ DEFAULT NOW()
UNIQUE(user_id, achievement_type_id)
```

#### Tabla: `user_statistics`
```sql
id: SERIAL PRIMARY KEY
user_id: UUID REFERENCES auth.users(id) ON DELETE CASCADE
stat_name: TEXT NOT NULL
stat_value: INTEGER DEFAULT 0
last_updated: TIMESTAMPTZ DEFAULT NOW()
UNIQUE(user_id, stat_name)
```

### Funciones de Base de Datos

#### `update_user_stat(user_id, stat_name, increment)`
- Actualiza estadísticas de usuario de forma atómica
- Usado para tracking automático de logros
- Seguridad: SECURITY DEFINER

#### `check_and_award_achievements(user_id)`
- Verifica y otorga logros automáticamente
- Retorna JSON con resultados
- Triggers basados en condiciones específicas

#### `assign_achievement_to_user(user_id, achievement_type_id, reason)`
- Asignación manual de logros por house heads
- Validación de permisos integrada
- Actualización automática de puntos de casa

### Row Level Security (RLS)

#### Políticas de Seguridad
```sql
-- Users can view their own profiles
user_profiles: auth.uid() = id

-- House heads can view their house members
user_profiles: house_head_access_policy

-- Achievement types are public
achievement_types: true (SELECT)

-- Users can view their own achievements
user_achievements: auth.uid() = user_id

-- House heads can manage their house achievements
user_achievements: house_head_management_policy
```

---

## 🔐 Sistema de Autenticación

### Flujo de Autenticación

#### Registro de Usuario
```javascript
1. user_registration.html → Formulario de registro
2. auth.js::register() → Supabase Auth
3. Email de verificación automático
4. Creación de perfil en user_profiles
5. Redirección a verificación pendiente
```

#### Inicio de Sesión
```javascript
1. user_login.html → Formulario de login
2. auth.js::login() → Supabase Auth
3. Carga de perfil desde user_profiles
4. Actualización de UI dinámica
5. Redirección basada en estado de casa
```

#### Gestión de Sesión
- **Persistencia**: Supabase maneja tokens automáticamente
- **Verificación**: getCurrentUser() en cada página crítica
- **Logout**: Limpieza de estado local y Supabase
- **Recuperación**: Sistema completo de reset de contraseña

### Estados de Usuario

#### Usuario No Autenticado
- Acceso a páginas públicas (homepage, login, register)
- Navegación muestra "Iniciar Sesión"
- Sin acceso a funcionalidades del usuario

#### Usuario Autenticado Sin Casa
- Redirigido automáticamente al quiz del sombrero
- Acceso limitado hasta completar selección
- Estado transitorio obligatorio

#### Usuario Autenticado Con Casa
- Acceso completo a la aplicación
- Navegación muestra nombre de casa
- Funcionalidades de perfil, logros, foro activas

#### House Head / Admin
- Acceso a panel de administración
- Gestión de miembros de casa
- Asignación manual de logros
- Estadísticas avanzadas

---

## 🏠 Sistema de Casas

### Arquitectura del Sistema de Casas

#### Almacenamiento Híbrido
```javascript
Primary: Supabase (user_profiles.house)
Fallback: localStorage (userHouse/selectedHouse)
Sync: Bidireccional automático
```

#### Flujo de Selección de Casa
```javascript
1. Quiz del Sombrero Seleccionador
2. Algoritmo de puntuación por respuestas
3. Guardado en Supabase + localStorage
4. Actualización de navegación universal
5. Acceso a sala común personalizada
```

#### Funciones de Casa

##### `saveUserHouse(house)`
```javascript
// Guarda casa en ambos sistemas
async function saveUserHouse(house) {
    // 1. Intenta Supabase primero
    // 2. Fallback a localStorage
    // 3. Sincronización bidireccional
}
```

##### `getUserHouse()`
```javascript
// Obtiene casa con prioridad Supabase
async function getUserHouse() {
    // 1. Intenta Supabase primero
    // 2. Fallback a localStorage
    // 3. Actualiza caché local
}
```

### Características de Casa

#### Gryffindor - Valor y Coraje
```css
Color: #740001 (Rojo profundo)
Valores: Valor, coraje, determinación
Elementos UI: Bordes rojos, gradientes cálidos
```

#### Hufflepuff - Lealtad y Trabajo Duro
```css
Color: #FFD800 (Amarillo dorado)
Valores: Lealtad, paciencia, trabajo justo
Elementos UI: Acentos dorados, fondos cálidos
```

#### Ravenclaw - Sabiduría e Inteligencia
```css
Color: #0E1A40 (Azul profundo)
Valores: Inteligencia, sabiduría, creatividad
Elementos UI: Tonos azules, elementos contemplativos
```

#### Slytherin - Ambición y Astucia
```css
Color: #1A472A (Verde esmeralda)
Valores: Ambición, astucia, determinación
Elementos UI: Verdes profundos, elementos elegantes
```

---

## 🏆 Sistema de Logros

### Arquitectura de Logros

#### Categorías Temáticas
```sql
- primer_ano: Logros para nuevos usuarios
- vida_social_hogwarts: Interacción y comunidad
- lealtad_casa: Actividades de casa
- maestria_academica: Conocimiento y aprendizaje
- exploracion_magica: Descubrimientos y easter eggs
- eventos_especiales: Logros de temporada
```

#### Tracking Automático
```javascript
class AchievementTracker {
    // Seguimiento de páginas visitadas
    // Tiempo en plataforma
    // Interacciones de usuario
    // Eventos específicos
    // Easter eggs y secuencias especiales
}
```

#### Logros Destacados

##### Primer Año (Nuevos Usuarios)
- **La Carta de Hogwarts** (✉️): Registro completado
- **El Sombrero Seleccionador** (🎓): Casa seleccionada
- **De Compras en el Callejón Diagon** (🛍️): Perfil completado
- **Plataforma 9¾** (🚂): Primera participación en foro

##### Vida Social
- **Primer Hechizo Verbal** (💬): Primer post
- **Eco en el Gran Comedor** (🔊): Tema con 10+ respuestas
- **El Trío de Oro** (🧑‍🤝‍🧑): Interacciones múltiples
- **Conversador del Caldero Chorreante** (🗣️): 50+ mensajes

##### Lealtad de Casa
- **Orgullo de Casa** (🏠): Primera visita a sala común
- **Guardián de la Sala Común** (🛡️): Actividades de casa activas
- **Campeón de la Casa** (🏆): 100+ puntos contribuidos

##### Exploración Mágica
- **Cazador de la Snitch Dorada** (✨): Participación rápida en eventos
- **Coleccionista de Cromos** (🐸): Easter eggs descubiertos
- **¡Alohomora!** (🔓): Acceso a secciones especiales
- **Viajero del Giratiempo** (⌛): 7 días consecutivos

### Sistema de Puntos
- **Puntos por Logro**: 10-100 puntos según dificultad
- **Contribución a Casa**: Puntos individuales suman al total de casa
- **Ranking**: Comparación entre casas y usuarios individuales
- **Rewards**: Acceso a contenido exclusivo por puntos

---

## 🌐 Navegación Universal

### Sistema de Navegación Dinámica

#### `universal-nav.js`
```javascript
// Actualización automática basada en estado de autenticación
function updateUniversalNavigation() {
    // Detecta estado de usuario
    // Actualiza enlaces dinámicamente
    // Muestra casa o "Iniciar Sesión"
    // Responsive y accesible
}
```

#### Estados de Navegación

##### Usuario No Logueado
```html
- Inicio
- Selección → "Iniciar Sesión"
- Foro → "Iniciar Sesión"
- Perfil → "Iniciar Sesión"
- Eventos → "Iniciar Sesión"
- [Iniciar Sesión]
```

##### Usuario Logueado Sin Casa
```html
- Inicio
- Selección → house_selection_portal_sorting_hat_quiz.html
- Foro → Acceso limitado
- Perfil → user_profile_achievement_system.html
- Eventos → community_events_challenges_center.html
- [Seleccionar Casa]
```

##### Usuario Logueado Con Casa
```html
- Inicio
- [GRYFFINDOR] → house_common_rooms_personalized_dashboards.html
- Foro → interactive_forum_hub.html
- Perfil → user_profile_achievement_system.html
- Eventos → community_events_challenges_center.html
- [Logout]
```

---

## 📱 Responsive Design

### Breakpoints
```css
sm: 640px   /* Teléfonos grandes */
md: 768px   /* Tablets */
lg: 1024px  /* Laptops */
xl: 1280px  /* Desktops */
2xl: 1536px /* Pantallas grandes */
```

### Estrategia Mobile-First
- Diseño base para móviles
- Progressive enhancement para pantallas más grandes
- Touch-friendly interactions
- Menús colapsables
- Imágenes optimizadas

### Componentes Responsive
- **Navigation**: Hamburger menu en móvil
- **Cards**: Stack vertical en móvil, grid en desktop
- **Forms**: Full-width en móvil, centrado en desktop
- **Modals**: Full-screen en móvil, floating en desktop

---

## ⚡ Rendimiento

### Estrategias de Optimización

#### Carga de Recursos
- **CDN**: Supabase client y Google Fonts
- **Preload**: Fonts críticas
- **Lazy Loading**: Imágenes no críticas
- **Minification**: CSS/JS en producción

#### Gestión de Estado
- **Local Storage**: Caché de datos de usuario
- **Session Management**: Tokens de Supabase
- **State Sync**: Automático entre tabs
- **Offline Fallback**: Funcionalidad básica sin conexión

#### Base de Datos
- **RLS**: Filtrado en base de datos
- **Indexes**: Optimización de queries
- **Connection Pooling**: Manejo eficiente de conexiones
- **Caching**: Datos estáticos cacheados

---

## 🔒 Seguridad

### Frontend Security
- **Input Validation**: Sanitización de formularios
- **XSS Prevention**: Escape de contenido dinámico
- **CSRF Protection**: Tokens en formularios críticos
- **Content Security Policy**: Headers de seguridad

### Backend Security (Supabase)
- **Row Level Security**: Acceso granular a datos
- **JWT Tokens**: Autenticación segura
- **HTTPS Only**: Comunicación encriptada
- **SQL Injection**: Prevención automática via ORM

### Privacy & GDPR
- **Privacy Settings**: Control de usuario sobre datos
- **Data Portability**: Exportación de datos de usuario
- **Right to Deletion**: Eliminación completa de datos
- **Consent Management**: Opt-in para features opcionales

---

## 🧪 Testing

### Estrategias de Testing

#### Unit Testing
```javascript
// Tests de funciones críticas
- auth.js functions
- achievement-tracker.js logic
- Data validation helpers
```

#### Integration Testing
```javascript
// Tests de flujos completos
- User registration → House selection → Profile setup
- Achievement earning → Points calculation
- Admin panel → User management
```

#### E2E Testing (Playwright)
```javascript
// Tests de experiencia de usuario
- Complete user journey
- Cross-browser compatibility
- Mobile responsiveness
```

#### Manual Testing
- **UX Testing**: Experiencia de usuario real
- **Accessibility**: Screen readers, keyboard navigation
- **Performance**: Load times, responsiveness
- **Security**: Penetration testing básico

---

## 🚀 Deployment

### Estrategia de Despliegue

#### Desarrollo Local
```bash
npm run dev          # Watch mode con live reload
npm run build:css    # Build CSS para producción
npm run serve        # Servidor de desarrollo
```

#### Staging Environment
- **Supabase Project**: Staging database
- **Environment Variables**: Staging keys
- **Testing Data**: Datos de prueba poblados
- **Feature Flags**: Features experimentales

#### Production Deployment
- **Static Hosting**: Netlify, Vercel, o similar
- **CDN**: Distribución global de assets
- **Custom Domain**: DNS y SSL certificates
- **Monitoring**: Error tracking y analytics

### CI/CD Pipeline
```yaml
1. Git Push → Main Branch
2. Automated Tests → Playwright + Unit
3. Build Process → CSS compilation
4. Deploy to Staging → Testing environment
5. Manual QA → User acceptance testing
6. Deploy to Production → Live environment
7. Post-deployment Tests → Smoke tests
```

---

## 📊 Analytics & Monitoring

### Métricas Clave

#### User Engagement
- **Daily Active Users**: Usuarios únicos diarios
- **Session Duration**: Tiempo promedio en sitio
- **Page Views**: Páginas más visitadas
- **House Distribution**: Balance entre casas

#### Achievement Metrics
- **Achievement Completion Rate**: % de logros completados
- **Most Popular Achievements**: Rankings de logros
- **Time to First Achievement**: Onboarding effectiveness
- **House Points Distribution**: Balance competitivo

#### Technical Metrics
- **Page Load Times**: Rendimiento de carga
- **Error Rates**: Errores de JavaScript
- **API Response Times**: Latencia de Supabase
- **Mobile vs Desktop Usage**: Device preferences

### Monitoring Tools
- **Google Analytics**: User behavior tracking
- **Supabase Dashboard**: Database performance
- **Console Logging**: Development debugging
- **User Feedback**: In-app feedback system

---

## 🔄 Versionado y Mantenimiento

### Semantic Versioning
```
MAJOR.MINOR.PATCH
1.0.0 → Initial release
1.1.0 → New features
1.1.1 → Bug fixes
2.0.0 → Breaking changes
```

### Release Process
1. **Feature Development** → Feature branches
2. **Code Review** → Pull requests
3. **Testing** → Automated + manual
4. **Documentation** → Update README y docs
5. **Release Notes** → Changelog generation
6. **Deployment** → Staged rollout

### Maintenance Tasks
- **Database Maintenance**: Cleanup de datos obsoletos
- **Security Updates**: Dependencias y Supabase
- **Performance Optimization**: Query optimization
- **Content Updates**: Nuevos logros y eventos

---

## 🎯 Roadmap Futuro

### Fase 1 - Mejoras Inmediatas
- [ ] Sistema de mensajería privada
- [ ] Notificaciones push
- [ ] Mobile app (PWA)
- [ ] Modo offline básico

### Fase 2 - Funcionalidades Avanzadas
- [ ] Sistema de quizzes más complejos
- [ ] Torneos entre casas
- [ ] Biblioteca digital con contenido
- [ ] Sistema de mentorship

### Fase 3 - Expansión
- [ ] API pública para developers
- [ ] Integración con redes sociales
- [ ] Marketplace de contenido
- [ ] Eventos en tiempo real

---

## 📚 Documentación Adicional

### Archivos de Referencia
- `DOCUMENTACION_MEJORAS_SISTEMA_CASAS.md` - Mejoras del sistema de casas
- `setup_harry_potter_achievements.sql` - Setup de logros
- `README.md` - Guía de instalación y uso
- `CONTRIBUTING.md` - Guía para contribuidores

### Links Útiles
- [Supabase Documentation](https://supabase.com/docs)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [Harry Potter Wiki](https://harrypotter.fandom.com) - Referencia temática

---

## 🤝 Créditos y Licencia

### Desarrollo
**Desarrollado por**: Rovo Dev  
**Período**: Diciembre 2024  
**Versión**: 1.0.0  

### Tecnologías Utilizadas
- **Supabase** - Backend as a Service
- **Tailwind CSS** - Framework de CSS
- **Font Sources** - Google Fonts
- **Image Sources** - Unsplash, Pexels

### Licencia
MIT License - Ver archivo LICENSE para detalles completos

---

*✨ "La magia reside en los detalles de la implementación, pero la verdadera magia está en la experiencia que creamos para nuestra comunidad." - Arquitectura Hogwarts PotterFriends*
