# 🧠 MEMORIA DEL PROYECTO - Hogwarts PotterFriends

## 🎯 CONTEXTO RÁPIDO

**¿Qué es?** Una plataforma web inmersiva de Harry Potter donde usuarios se unen a casas de Hogwarts, ganan puntos, completan logros y participan en una comunidad mágica.

**Estado Actual:** Funcional con sistema de casas híbrido (Supabase + localStorage), autenticación completa, sistema de logros automático y panel de administración.

**Última Actualización:** Diciembre 2024 por Rovo Dev

---

## 🚀 COMANDOS ESENCIALES

### Desarrollo Local
```bash
# Iniciar servidor de desarrollo
./start-server.sh
# o alternativamente
npm run serve

# Compilar CSS
npm run build:css

# Modo desarrollo con watch
npm run dev
```

### URLs Importantes
- **Homepage:** `pages/homepage_sorting_hat_experience.html`
- **Login:** `pages/user_login.html`
- **Quiz:** `pages/house_selection_portal_sorting_hat_quiz.html`
- **Salas Comunes:** `pages/house_common_rooms_personalized_dashboards.html`
- **Admin Panel:** `pages/house_head_admin_panel.html`

---

## 🔑 CREDENCIALES Y CONFIGURACIÓN

### Supabase
```javascript
URL: 'https://vdcclritlgnwwdxloayt.supabase.co'
ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...' (en src/scripts/auth.js)
```

### Base de Datos Principal
- **Tablas Clave:** `user_profiles`, `profiles`, `achievement_types`, `user_achievements`, `user_statistics`
- **Setup SQL:** `setup_harry_potter_achievements.sql`
- **Fixes:** `fix_unique_constraint.sql`

---

## 🏠 SISTEMA DE CASAS - PUNTOS CLAVE

### Almacenamiento Híbrido
- **Primario:** Supabase (`user_profiles.house`)
- **Backup:** localStorage (`userHouse` o `selectedHouse`)
- **Sync:** Automático bidireccional

### Funciones Críticas
```javascript
// en auth.js
async function saveUserHouse(house)  // Guarda en ambos sistemas
async function getUserHouse()        // Obtiene con fallback
```

### Flujo Usuario Nuevo
1. Registro → Email verificación
2. Login → Redirección a quiz si no tiene casa
3. Quiz → Selección y guardado
4. Sala común → Acceso completo

### Flujo Usuario Existente con Casa
1. Login → Verificación de casa automática
2. Si accede al quiz → Mensaje elegante con opciones
3. Navegación → Muestra nombre de casa

---

## 🏆 SISTEMA DE LOGROS

### Categorías
- **primer_ano:** Nuevos usuarios (Carta Hogwarts, Sombrero, etc.)
- **vida_social_hogwarts:** Foro y comunidad
- **lealtad_casa:** Actividades de casa específicas
- **maestria_academica:** Conocimiento y tiempo
- **exploracion_magica:** Easter eggs y descubrimientos
- **eventos_especiales:** Temporales

### Tracking Automático
- **AchievementTracker:** Clase en `achievement-tracker.js`
- **Eventos:** Clics, navegación, tiempo, formularios
- **Easter Eggs:** Konami code, clics en logo
- **Stats:** Automáticas via `update_user_stat()`

### Asignación Manual
- **House Heads:** Panel admin `house_head_admin_panel.html`
- **Función SQL:** `assign_achievement_to_user()`
- **Permisos:** RLS valida house_head/admin

---

## 🔐 AUTENTICACIÓN - FLUJOS CLAVE

### Estados de Usuario
1. **No Autenticado:** Solo páginas públicas
2. **Autenticado Sin Casa:** Quiz obligatorio
3. **Autenticado Con Casa:** Acceso completo
4. **House Head/Admin:** Panel adicional

### Archivos Clave
- **`src/scripts/auth.js`:** Todo el sistema de autenticación
- **`universal-nav.js`:** Navegación dinámica
- **Páginas:** login, registration, verification, reset

### Verificaciones
```javascript
await isAuthenticated()     // Bool si está logueado
await getCurrentUser()      // Datos completos de usuario
```

---

## 🎨 DISEÑO Y UI

### Colores de Casa
```css
--gryffindor: #740001   /* Rojo valor */
--hufflepuff: #FFD800   /* Amarillo lealtad */
--ravenclaw: #0E1A40    /* Azul sabiduría */
--slytherin: #1A472A    /* Verde ambición */
```

### Tipografías
- **Headlines:** EB Garamond (elegancia académica)
- **Body:** Lato (lectura cómoda)
- **CTAs:** Open Sans (confianza)
- **Accent:** Cinzel (gravitas mágica)

### Componentes Mágicos
- Cards con sombras sutiles
- Hover effects con escalado
- Gradientes temáticos
- Partículas animadas

---

## 🗄️ BASE DE DATOS - ESQUEMA RÁPIDO

### user_profiles (Principal)
```sql
id, display_name, bio, house, house_points, 
avatar_url, privacy_*, role, is_house_head
```

### profiles (Legacy/Alternativa)
```sql
id, wizard_name, first_name, last_name, 
email, house, house_selected_at, role, is_house_head
```

### achievement_types
```sql
id, name, description, icon, points_reward, 
category, trigger_condition, auto_award
```

### user_achievements
```sql
id, user_id, achievement_type_id, awarded_by, 
reason, awarded_at
UNIQUE(user_id, achievement_type_id)
```

---

## 🔧 SOLUCIÓN DE PROBLEMAS COMUNES

### Usuario No Encuentra Su Casa
1. Verificar `getUserHouse()` en consola
2. Revisar tanto user_profiles como profiles
3. Comprobar localStorage: `userHouse` y `selectedHouse`
4. Forzar sync con `saveUserHouse()`

### Quiz No Guarda Resultado
1. Verificar conexión Supabase
2. Comprobar `calculateResults()` function
3. Revisar RLS policies en user_profiles
4. Fallback a localStorage manual

### Panel Admin No Carga
1. Verificar role en base de datos (user_profiles.role o profiles.role)
2. Comprobar is_house_head = true
3. Verificar house match entre admin y miembros
4. Revisar console logs para permisos RLS

### Navegación No Actualiza
1. Verificar `updateUniversalNavigation()` se ejecuta
2. Comprobar window.HogwartsAuth disponible
3. Revisar estado de autenticación
4. Forzar update manual

---

## 📁 ARCHIVOS CRÍTICOS - UBICACIONES

### JavaScript Core
- **`src/scripts/auth.js`** - Autenticación completa + house functions
- **`js/universal-nav.js`** - Navegación dinámica
- **`js/profile-system.js`** - Sistema perfiles + achievements
- **`js/achievement-tracker.js`** - Tracking automático
- **`js/house-head-admin.js`** - Panel administración

### HTML Principal
- **`index.html`** - Splash screen inicial
- **`pages/homepage_sorting_hat_experience.html`** - Landing principal
- **`pages/user_login.html`** - Sistema login
- **`pages/house_selection_portal_sorting_hat_quiz.html`** - Quiz sombrero
- **`pages/house_common_rooms_personalized_dashboards.html`** - Salas comunes
- **`pages/house_head_admin_panel.html`** - Admin panel

### Configuración
- **`package.json`** - Dependencias y scripts
- **`tailwind.config.js`** - Tema y colores
- **`start-server.sh`** - Script servidor desarrollo

### SQL
- **`setup_harry_potter_achievements.sql`** - Setup completo logros
- **`fix_unique_constraint.sql`** - Fixes constraints

---

## 🐛 DEBUGGING TIPS

### 2025-09-01 - Mejora Sala Común (dashboard) y Supabase client
- Corregido mapeo de IDs de casas (1=gryffindor, 2=hufflepuff, 3=ravenclaw, 4=slytherin).
- Se evitó el error 400 al leer `user_profiles`:
  - Se dejó de ordenar por `created_at` (no existe en algunos esquemas).
  - Lecturas tolerantes: `profiles` → `public_profiles` → `user_profiles`.
- “Compañeros de Casa Destacados” ahora usa fuente tolerante y no falla sin `created_at`.
- “Logros Recientes” ahora se pinta y evita joins que causaban 400:
  - Primero obtiene IDs de miembros de la casa.
  - Luego consulta `user_achievements` por esos IDs (con `achievement_types`).
  - Finalmente resuelve nombres/avatares.
- Se añadió fallback de fecha para nuevos miembros en el feed para evitar “Invalid Date”.
- Se unificó el cliente de Supabase:
  - `js/supabase-client.js` ahora reutiliza `window.supabaseClient` (creado en `auth.js`) y no crea nuevos clientes.
  - Esto elimina el warning: “Multiple GoTrueClient instances detected …”.

Archivos modificados:
- `pages/house_common_rooms_personalized_dashboards.html` (previo)
- `js/services/dashboardApi.js` (actividad, logros recientes, miembros; fallbacks y tolerancia)
- `js/supabase-client.js` (unificación de cliente)

Impacto:
- Secciones que se quedaban en “Cargando…” ahora muestran datos o mensajes vacíos claros.
- Menos ruido en consola y comportamiento estable con RLS/variaciones de esquema.

### Console Commands Útiles
```javascript
// Verificar usuario actual
window.HogwartsAuth.getCurrentUser()

// Verificar casa
window.HogwartsAuth.getUserHouse()

// Verificar autenticación
window.HogwartsAuth.isAuthenticated()

// Ver localStorage
localStorage.getItem('userHouse')
localStorage.getItem('selectedHouse')
localStorage.getItem('hogwarts_user')
```

### SQL Queries Útiles
```sql
-- Ver usuarios con casas
SELECT id, display_name, house, role, is_house_head 
FROM user_profiles;

-- Ver logros de usuario
SELECT ua.*, at.name, at.points_reward 
FROM user_achievements ua 
JOIN achievement_types at ON ua.achievement_type_id = at.id 
WHERE ua.user_id = 'USER_ID';

-- Stats de usuario
SELECT * FROM user_statistics WHERE user_id = 'USER_ID';
```

---

## 🔄 FLUJOS DE TRABAJO

### Añadir Nuevo Logro
1. INSERT en `achievement_types` table
2. Definir `trigger_condition` 
3. Actualizar `check_and_award_achievements()` si es auto
4. Testear con `triggerAchievement()` en tracker

### Modificar Casa de Usuario
1. Actualizar en user_profiles.house
2. Sync con localStorage via `saveUserHouse()`
3. Actualizar navegación con `updateUniversalNavigation()`
4. Verificar acceso a sala común

### Agregar House Head
1. Actualizar `role = 'house_head'` o `is_house_head = true`
2. Asignar `house` correcta
3. Verificar acceso a admin panel
4. Comprobar permisos RLS para su casa

---

## 🎯 MEJORAS FUTURAS IDENTIFICADAS

### Inmediatas
- [ ] PWA capabilities (offline mode)
- [ ] Push notifications para logros
- [ ] Sistema mensajería entre usuarios
- [ ] Modo dark/light toggle

### Mediano Plazo
- [ ] Quizzes más complejos con múltiples resultados
- [ ] Calendario de eventos mágicos
- [ ] Sistema de badges visuales
- [ ] Leaderboards por casa y global

### Largo Plazo
- [ ] API pública para developers
- [ ] Mobile app nativa
- [ ] Integración redes sociales
- [ ] Sistema de mentorship entre usuarios

---

## 📊 MÉTRICAS IMPORTANTES

### KPIs a Monitorear
- **Retención:** % usuarios que regresan después de selección
- **Engagement:** Tiempo promedio en salas comunes
- **Balance:** Distribución equitativa entre casas
- **Logros:** Tasa de completación de achievements

### Analytics Setup
- Google Analytics configurado
- Supabase dashboard para DB metrics
- Console logging para debugging
- User feedback via forms

---

## 🆘 CONTACTOS Y RECURSOS

### Documentación Técnica
- `ARQUITECTURA_PROYECTO.md` - Documentación completa
- `DOCUMENTACION_MEJORAS_SISTEMA_CASAS.md` - Mejoras específicas
- Supabase Docs: https://supabase.com/docs
- Tailwind Docs: https://tailwindcss.com/docs

### Recursos de Desarrollo
- Harry Potter Wiki para referencias
- Color palettes y tipografías ya definidas
- Component library en proceso
- Testing framework con Playwright

---

## 🎪 EASTER EGGS Y FEATURES ESPECIALES

### Easter Eggs Implementados
- **Konami Code:** Secuencia de flechas para logro especial
- **Logo Clicking:** 10+ clics para achievement
- **Particle Effects:** Animaciones mágicas en homepage
- **House Colors:** Dinámicos según selección usuario

### Features Ocultas
- Debug pages en `/tmp_*.html`
- Admin access via URL directa (si permisos)
- Testing utilities en `/tests/`
- Development toolbar integration

---

## 🔮 NOTAS PARA EL FUTURO

### Decisiones de Arquitectura
- **Hybrid Storage:** localStorage como backup fue clave para UX
- **RLS Policies:** Críticas para seguridad multi-tenant
- **Supabase Choice:** Perfecto para rapidez desarrollo
- **Tailwind:** Excelente para theming consistente

### Lecciones Aprendidas
- Siempre tener fallbacks (localStorage backup)
- RLS policies deben ser granulares pero no complejas
- User state management es crítico en SPAs
- Testing debe incluir flujos completos, no solo units

### Warnings
- **No eliminar** archivos `tmp_*` sin verificar dependencias
- **Cuidado** con cambios en auth.js - afecta todo el flujo
- **Siempre** probar changes en ambas tablas (user_profiles + profiles)
- **RLS policies** pueden fallar silenciosamente

---

*🧙‍♂️ "Un mago siempre llega precisamente cuando se lo propone, y con documentación completa." - Gandalf del Código*

**Última actualización:** Enero 2025  
**Versión de memoria:** 1.0  
**Próxima revisión:** Cada nueva feature major
