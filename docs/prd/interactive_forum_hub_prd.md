# PRD – Conversión de "Interactive Forum Hub" de estático a funcional

## 1. Contexto
La página `pages/interactive_forum_hub.html` ya cuenta con una rica maqueta visual (TailwindCSS) y algo de JS de demostración. Falta persistencia, seguridad y lógica de negocio. El proyecto utiliza Supabase para autenticación (`../js/auth.js`) y se supone una estructura de páginas HTML estáticas.

## 2. Objetivo del producto
Convertir el hub de foro en una experiencia interactiva completa donde los usuarios autenticados puedan:
1. Crear, leer, actualizar y eliminar (CRUD) discusiones y respuestas.
2. Filtrar, buscar y ordenar contenidos en tiempo real.
3. Interactuar mediante “likes”, puntos y estados (abierto / resuelto / en vivo).
4. Recibir actualizaciones en vivo (realtime) sobre nuevas publicaciones y miembros en línea.

## 3. Alcance (MVP)
• Alta/baja/modificación de discusiones, comentarios y likes.
• Filtros por Casa, categoría y ordenamiento.
• Buscador (full-text) en título y contenido.
• Panel de miembros en línea en tiempo real.
• Autenticación vía Supabase existente.
• Políticas RLS para que los usuarios sólo editen su propio contenido.

## 4. Usuarios clave
• Miembro registrado (estudiante) – Publica y comenta.
• Moderador – Puede fijar debates, cerrar temas, borrar contenido.
• Invitado – Sólo lectura (opcional según políticas).

## 5. Requerimientos funcionales
F1. El usuario autenticado puede crear una nueva discusión con título, descripción, categoría y casa.
F2. El usuario puede responder a una discusión existente.
F3. El sistema muestra contadores de vistas, respuestas y likes.
F4. Filtros (checkbox) y selector de orden envían consultas sin recarga.
F5. El buscador devuelve resultados en <300 ms con sugerencias.
F6. El panel “Miembros online” se actualiza vía canales realtime.
F7. Moderador puede cambiar `status` (abierto, cerrado, resuelto, en vivo).
F8. Botón “Cargar más” realiza paginación incremental.

## 6. Requerimientos no funcionales
NF1. Tiempo de respuesta API ≤ 500 ms.
NF2. 99 % de disponibilidad mensual.
NF3. Accesibilidad WCAG AA.
NF4. Cumplir política de privacidad interna.
NF5. Compatible con móviles ≥ iPhone 8 / Android 9.

## 7. Arquitectura propuesta
```
Front-End (HTML + Alpine/Vanilla) ──┐
                                   │ REST/Realtime (supabase-js)
Supabase Postgres  ←─ Edge Functions ─┘
```
• Se mantiene la página HTML; la lógica se traslada a un módulo JS `forum.js` con llamadas a Supabase.
• Edge Functions (TypeScript) encapsulan lógica compleja (p.ej. puntos, notificaciones).
• Política RLS en tablas para la seguridad.

## 8. Modelo de datos (Postgres)
Tabla `users` (ya existe en Supabase)
Tabla `houses` (`id`, `name`, `color`)
Tabla `categories` (`id`, `name`, `icon`)
Tabla `posts`
• id (uuid PK)
• user_id → users.id
• house_id → houses.id
• category_id → categories.id
• title text, content text
• status enum('open','closed','resolved','live')
• views int default 0
• created_at timestamptz
Tabla `comments`
• id, post_id, user_id, content, created_at
Tabla `likes`
• id, user_id, post_id, created_at
Tabla `online_users` (realtime presences, opcional)

## 9. Endpoints / Edge Functions
| Método | Ruta | Descripción |
|--------|------|-------------|
| POST   | /posts            | Crear discusión |
| GET    | /posts?filters…   | Listar con filtros + paginación |
| GET    | /posts/{id}       | Detalle + comentarios |
| POST   | /posts/{id}/comments | Comentar |
| POST   | /posts/{id}/like  | Toggle like |
| PATCH  | /posts/{id}       | Editar (propio/moderador) |
| PATCH  | /posts/{id}/status| Cambiar estado (moderador) |

*Nota:* En Supabase JS estas rutas se convierten en llamadas `supabase.from('posts')...`, pero se exponen Edge Functions si se requiere lógica adicional.

## 10. Flujo de implementación
1. **Preparar Base de datos**
   • Crear tablas y enums en Supabase SQL editor.
   • Configurar RLS (+ policies).
2. **SDK y variables**
   • Añadir `SUPABASE_URL` y `SUPABASE_ANON_KEY` en `.env` y referenciar en `forum.js`.
3. **Servicios de datos** (`/js/services/forumApi.js`)
   • Implementar funciones `listPosts`, `createPost`, `addComment`, `toggleLike`.
4. **Integrar UI existente**
   • Reemplazar datos estáticos por renders dinámicos (template literals / htmx / Alpine).
   • Conectar filtros y buscador a `listPosts` con query params.
5. **Realtime**
   • Suscribirse a canal `supabase.channel('public:posts')` para insert/update.
6. **Estado y paginación**
   • Mantener cursor y concatenar resultados en “Cargar Más”.
7. **Moderación** (edge function `updateStatus` + botones visibles a moderadores).
8. **Testing**
   • Unit tests de servicios (Vitest).
   • Test de integración (Playwright) para flujos CRUD básicos.
9. **Deploy**
   • Desplegar página en Vercel/Netlify; variables env.
   • Supabase ya es serverless.

## 11. KPIs de éxito
• >70 % de usuarios activos diarios usan el foro.
• Tasa de retención de discusión (>2 respuestas) ≥ 60 %.
• Tiempo medio de carga inicial <2 s en 4G.

## 12. Riesgos y mitigación
| Riesgo | Impacto | Mitigación |
|--------|---------|------------|
| Spam / abuso | Alto | Captcha Invisible + reputación + moderadores |
| Costos Supabase por realtime | Medio | Limitar presencia y throttling |
| Complejidad UI sin framework | Bajo | Usar Alpine.js pequeño y declarativo |

## 13. Próximos pasos
1. Validar PRD con stakeholders.
2. Crear issues en proyecto Kanban.
3. Iniciar sprint 0 (setup DB y políticas).

