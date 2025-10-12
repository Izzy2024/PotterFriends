# PRD: Backend para pages/community_events_challenges_center.html

Autor: Equipo Hogwarts Community Hub
Fecha: 2025-08-11
Estado: Borrador listo para implementación

1. Resumen ejecutivo
- Objetivo: Habilitar un backend funcional (Supabase) para el Centro de Eventos y Desafíos que cubra: creación/gestión de eventos, participaciones, calendario, sistema de desafíos (individuales y por casas), archivo de eventos pasados, votaciones comunitarias y conteo de puntos por casa.
- Alcance: Definición de modelo de datos, políticas RLS, triggers, RPCs/Edge Functions, almacenamiento, integraciones Realtime, y endpoints de lectura/escritura consumibles desde el frontend existente.
- Exclusiones: Moderación automática de contenido con ML, pasarela de pagos, multitenencia.

2. Contexto del frontend (mapeo de componentes)
El archivo pages/community_events_challenges_center.html incluye:
- Hero + métricas rápidas: Eventos activos, participantes, puntos en juego, días restantes.
- Eventos destacados (3 tarjetas con imagen, estado “destacado”, días restantes, participantes, puntos, CTA Participar/Ver detalles).
- Calendario mágico: grilla mensual, interacción de selección de día, leyenda por tipo (Torneo/Concurso/Celebración).
- Sidebar de Próximos Eventos (lista compacta con fecha/hora y descripción breve) + Acciones Rápidas (Crear evento, Mis participaciones, Tabla de posiciones).
- Sistema de Desafíos: Individuales (3 tarjetas de retos) y por Casas (3 tarjetas con progreso por casa y puntos otorgables).
- Archivo de eventos pasados: tarjetas con estado Completado, participantes/obras/historias, ganador por casa, CTA Ver resultados/galería/historias.
- Votación de la comunidad: bloque con opciones activas (porcentaje y barra) y bloque de resultados recientes (1°, 2°, 3°); totales de votos y deadline.
- CTA móvil fijo: Participar en Evento.

3. Requisitos funcionales
3.1 Métricas rápidas (Hero)
- RF1: Obtener conteo de eventos activos (status = 'active' y fecha_actual entre start_at y end_at).
- RF2: Obtener total de participantes en eventos activos (distinct user_id en event_participants para events activos).
- RF3: Calcular “puntos en juego” (suma de reward_points de events activos + suma de rewards de challenges activos).
- RF4: “Días restantes”: mínimo(days_until(end_at)) entre eventos activos o del próximo cierre de votación/challenge.

3.2 Eventos
- RF5: Listar eventos destacados (featured=true) con imagen, etiquetas, countdown y stats.
- RF6: Participarse a un evento (“Participar Ahora”) crea/actualiza event_participants con status='joined'.
- RF7: Ver detalles (navegación futura) requiere slug único por evento.

3.3 Calendario
- RF8: Generar matriz para el mes actual con indicadores por tipo: 'tournament'|'contest'|'celebration'.
- RF9: Al seleccionar un día, listar eventos de ese día (UI futura). API lista ya disponible.

3.4 Próximos eventos
- RF10: Listar próximos eventos ordenados por start_at asc, límite configurable (p.ej. 5).

3.5 Acciones rápidas
- RF11: Crear evento: solo roles staff/admin. Abre formulario (pendiente) o ruta /admin. API lista.
- RF12: Mis participaciones: listar eventos donde user_id participó.
- RF13: Tabla de posiciones: ranking por casa y global de usuarios por puntos acumulados en periodo.

3.6 Sistema de desafíos
- RF14: Listar desafíos individuales activos con descripción, recompensa en puntos, número de completados y CTA “Intentar”.
- RF15: Intentar desafío registra attempt con status y puntaje si aplica.
- RF16: Desafíos por casas: mostrar objetivos agregados por casa con progreso, meta y recompensa colectiva.

3.7 Archivo de eventos pasados
- RF17: Listar eventos finalizados (status='completed') con métricas (participantes/obras/historias) y ganador (house o user según tipo).

3.8 Votación de la comunidad
- RF18: Listar votaciones activas con opciones, porcentaje y tiempo restante.
- RF19: Permitir votar 1 vez por usuario y por votación. Actualizar totales en tiempo real si es posible.
- RF20: Mostrar resultados recientes (ganadores y porcentajes) al finalizar una votación.

3.9 Puntos por casa
- RF21: Al completar desafíos o ganar eventos, asignar puntos a user y a su casa. Registrar en house_points_ledger. Recalcular ranking.

4. Modelo de datos (Supabase Postgres)
Tablas (prefijo público):
- profiles
  - id uuid PK (igual a auth.users.id)
  - username text UNIQUE
  - house text CHECK IN ('gryffindor','hufflepuff','ravenclaw','slytherin')
  - avatar_url text
  - created_at timestamptz default now()

- houses
  - key text PK ('gryffindor','hufflepuff','ravenclaw','slytherin')
  - name text
  - emblem_url text

- events
  - id uuid PK default gen_random_uuid()
  - slug text UNIQUE NOT NULL
  - title text NOT NULL
  - description text
  - type text CHECK IN ('tournament','contest','celebration') NOT NULL
  - featured boolean default false
  - cover_url text
  - reward_points int default 0 -- puntos por participar/ganar (ver reglas)
  - start_at timestamptz NOT NULL
  - end_at timestamptz NOT NULL
  - status text CHECK IN ('draft','active','completed','cancelled') default 'draft'
  - created_by uuid REFERENCES profiles(id)
  - created_at timestamptz default now()
  - metadata jsonb -- campos flexibles
  Indices: (status), (featured), (start_at), (end_at)

- event_participants
  - event_id uuid REFERENCES events(id) ON DELETE CASCADE
  - user_id uuid REFERENCES profiles(id) ON DELETE CASCADE
  - status text CHECK IN ('joined','submitted','disqualified','winner') default 'joined'
  - submission_url text -- link a obra/archivo si aplica
  - points_awarded int default 0
  - joined_at timestamptz default now()
  PK (event_id, user_id)
  Índices: (user_id), (status)

- challenges
  - id uuid PK default gen_random_uuid()
  - slug text UNIQUE NOT NULL
  - title text NOT NULL
  - description text
  - scope text CHECK IN ('individual','house') NOT NULL
  - reward_points int NOT NULL
  - target_count int -- para retos de casa (meta total)
  - start_at timestamptz NOT NULL
  - end_at timestamptz NOT NULL
  - status text CHECK IN ('draft','active','completed','cancelled') default 'draft'
  - created_by uuid REFERENCES profiles(id)
  - metadata jsonb
  Índices: (scope), (status), (start_at), (end_at)

- challenge_attempts
  - id uuid PK default gen_random_uuid()
  - challenge_id uuid REFERENCES challenges(id) ON DELETE CASCADE
  - user_id uuid REFERENCES profiles(id) ON DELETE CASCADE
  - house_key text REFERENCES houses(key)
  - status text CHECK IN ('in_progress','completed','rejected') default 'in_progress'
  - score int -- opcional
  - evidence_url text -- link a evidencia
  - created_at timestamptz default now()
  - completed_at timestamptz
  Índices: (challenge_id), (user_id), (house_key), (status)

- house_challenge_progress
  - challenge_id uuid REFERENCES challenges(id) ON DELETE CASCADE
  - house_key text REFERENCES houses(key)
  - progress_count int default 0
  - updated_at timestamptz default now()
  PK (challenge_id, house_key)

- votes
  - id uuid PK default gen_random_uuid()
  - poll_id uuid REFERENCES polls(id) ON DELETE CASCADE
  - user_id uuid REFERENCES profiles(id) ON DELETE CASCADE
  - option_id uuid REFERENCES poll_options(id) ON DELETE CASCADE
  - created_at timestamptz default now()
  UNIQUE (poll_id, user_id)

- polls
  - id uuid PK default gen_random_uuid()
  - slug text UNIQUE NOT NULL
  - title text NOT NULL
  - description text
  - context jsonb -- p.ej. { event_id: ..., category: 'art' }
  - start_at timestamptz NOT NULL
  - end_at timestamptz NOT NULL
  - status text CHECK IN ('draft','active','completed','cancelled') default 'draft'

- poll_options
  - id uuid PK default gen_random_uuid()
  - poll_id uuid REFERENCES polls(id) ON DELETE CASCADE
  - label text NOT NULL
  - author text -- nombre del autor mostrado
  - media_url text -- link a obra (si aplica)
  - sort_order int default 0

- house_points_ledger
  - id uuid PK default gen_random_uuid()
  - house_key text REFERENCES houses(key)
  - user_id uuid REFERENCES profiles(id) -- opcional si acción individual
  - source text CHECK IN ('event','challenge','vote','manual')
  - source_id uuid -- id de evento/retos etc.
  - points int NOT NULL -- positivos o negativos
  - note text
  - created_at timestamptz default now()
  Índices: (house_key), (created_at), (source, source_id)

- user_points_ledger
  - id uuid PK default gen_random_uuid()
  - user_id uuid REFERENCES profiles(id) ON DELETE CASCADE
  - source text CHECK IN ('event','challenge','vote','manual')
  - source_id uuid
  - points int NOT NULL
  - note text
  - created_at timestamptz default now()
  Índices: (user_id), (created_at)

- media_assets (opcional si no se usa storage directo)
  - id uuid PK default gen_random_uuid()
  - owner_id uuid REFERENCES profiles(id)
  - url text NOT NULL
  - type text CHECK IN ('image','video','file')
  - created_at timestamptz default now()

5. Storage (Supabase Storage)
Buckets sugeridos:
- event-covers: imágenes de portada de eventos.
- submissions: evidencias y obras (arte, historias, etc.).
- poll-media: imágenes asociadas a opciones de votación.
Políticas: lectura pública de assets aprobados, escritura autenticada por dueño; objetos nombrados por UUIDs. Usar RLS-like mediante políticas de storage con allow insert por auth.uid().

6. Políticas de seguridad (RLS)
Habilitar RLS en todas las tablas. Políticas base:
- profiles: select por usuario autenticado; update solo self; insert mediante trigger/función al registrarse.
- events:
  - select: pública (o autenticada si se requiere), status!='draft' OR created_by = auth.uid().
  - insert/update/delete: solo role 'staff' o 'admin'. Usar claim custom role en JWT o tabla de roles.
- event_participants:
  - select: user puede ver sus filas; público puede ver conteos agregados vía RPC.
  - insert: user autenticado puede insert si evento activo y no existe ya registro.
  - update: user puede actualizar su submission_url; staff puede cambiar status/points_awarded.
- challenges/challenge_attempts:
  - select: pública para listados activos; attempts visibles por dueño y staff.
  - insert attempts: user autenticado;
  - update attempts: dueño (evidence_url) o staff (status/score).
- house_challenge_progress: solo lectura pública; update solo trigger (no directo por cliente).
- polls/poll_options: lectura pública si status='active' o 'completed'; edición staff.
- votes: insert una vez por poll_id y user_id; select por usuario para su propio voto; agregados vía RPC.
- ledgers: select por staff; agregados/leaderboards vía RPC para no exponer filas crudas.

7. Triggers y lógica derivada
- TR1: En challenge_attempts, al update status -> 'completed':
  - Insert en user_points_ledger con points = challenges.reward_points.
  - Si profiles.house no es null y challenge.scope='individual': también insertar en house_points_ledger con points = challenges.reward_points.
  - Si scope='house': incrementar house_challenge_progress.progress_count para profiles.house y challenge_id. Al alcanzar target_count, opcionalmente insertar bonificación extra en house_points_ledger.

- TR2: En events, al cambiar status -> 'completed':
  - Si metadata.winner_house existe, insertar en house_points_ledger con points = events.reward_points (o metadata.winner_house_points si set).
  - Si hay ganadores individuales en event_participants (status='winner'), crear entradas en user_points_ledger.

- TR3: En votes, al insert si polls.status='active':
  - Opcional: emitir NOTIFY para canal realtime 'polls:{poll_id}' para re-render de porcentajes.

- TR4: profiles on insert: crear fila en houses? (no) Solo asegurar constraints. O inicializar house si viene de onboarding.

8. RPCs (Postgres functions) y vistas
Para optimizar y asegurar agregados sin exponer datos sensibles:
- get_quick_stats(): retorna { active_events_count, active_participants_count, points_in_play, min_days_remaining }
- list_featured_events(limit int default 6)
- list_upcoming_events(limit int default 5)
- list_calendar_events(month int, year int): retorna por día [{ date, types: [..], events: [...] }]
- join_event(event_slug text): inserta event_participants (idempotente)
- my_participations(): lista eventos del usuario
- list_individual_challenges(): activos scope='individual' + completados_count
- list_house_challenges(): activos scope='house' + progreso por casa
- submit_challenge_attempt(challenge_slug text, evidence_url text)
- leaderboard_houses(period text default 'month'): retorna ranking por casa y puntos
- leaderboard_users(period text default 'month')
- get_polls_active(): lista polls activos con opciones y porcentajes calculados
- vote_poll(poll_slug text, option_id uuid): inserta vote (enforce unique)
- get_recent_poll_results(limit int default 1)

Vistas/materializadas (opcional):
- v_event_participants_counts(event_id, participants_count)
- v_challenge_completed_counts(challenge_id, completed_count)
- v_poll_option_vote_counts(poll_id, option_id, votes_count)

9. Realtime
- Canal 'polls:{poll_id}': broadcast de nuevos votos para actualizar porcentajes en vivo.
- Canal 'events': cambios de status para actualizar listados en tiempo real (opcional).
- Canal 'house-points': cuando hay nuevas entradas en house_points_ledger, actualizar tabla de posiciones por casa.

10. Integración con el frontend
10.1 Librerías ya incluidas en la página
- Se carga @supabase/supabase-js v2 y scripts globales auth.js y universal-nav.js. Asumimos window.supabaseClient global (creado en auth.js ó previamente). Si no, inicializar con URL y ANON_KEY mediante variables de entorno inyectadas en build. No hardcodear secretos (usar {{SUPABASE_URL}}/{{SUPABASE_ANON_KEY}}).

10.2 Mapeo de acciones UI -> llamadas
- Hero (métricas): on load -> get_quick_stats().
- Eventos destacados: on load -> list_featured_events(6).
- CTA Participar: on click -> join_event(slug).
- Calendario: on month change -> list_calendar_events(month,year). on day click -> opcionalmente filtrar lista.
- Próximos eventos: on load -> list_upcoming_events(5).
- Acciones rápidas:
  - Crear Evento: si user.role in ['staff','admin'] -> redirigir /admin/events/new. Backend: insert en events.
  - Mis Participaciones: on click -> my_participations().
  - Tabla de posiciones: on click -> leaderboard_houses('month') y/o leaderboard_users('month').
- Desafíos individuales: on load -> list_individual_challenges(); on Intentar -> submit_challenge_attempt(slug, evidence_url?).
- Desafíos por casas: on load -> list_house_challenges(). Progreso por casa via house_challenge_progress o RPC agregada.
- Archivo de eventos pasados: on load -> events where status='completed' limit 9 ordenado por end_at desc.
- Votación activa: on load -> get_polls_active(); on seleccionar opción -> vote_poll(slug, option_id). Suscribirse a realtime 'polls:{poll_id}'.
- Resultados recientes: on load -> get_recent_poll_results(1).

10.3 Estructura de datos esperada en el frontend
Ejemplos de respuestas (JSON):
- list_featured_events -> [{ slug, title, description, cover_url, type, featured, reward_points, participants_count, ends_in_days }]
- get_quick_stats -> { active_events_count: number, active_participants_count: number, points_in_play: number, min_days_remaining: number }
- list_individual_challenges -> [{ slug, title, description, reward_points, completed_count }]
- list_house_challenges -> [{ slug, title, reward_points, target_count, progress: { gryffindor: n, ravenclaw: n, hufflepuff: n, slytherin: n } }]
- get_polls_active -> [{ slug, title, ends_in_days, options: [{ id, label, author, percent }], total_votes }]

11. Reglas de negocio y validaciones
- Un usuario solo puede unirse una vez a un evento dado.
- Un usuario solo puede votar una vez por poll activo. Cambiar el voto no permitido salvo diseño futuro.
- Attempt de desafío individual: máximo 1 attempt completado por usuario y desafío (o permitir múltiples y tomar el mejor score – decidir en metadata).
- Fechas: start_at < end_at; status transiciona: draft -> active -> completed/cancelled.
- Recompensas: los puntos otorgados deben ser no negativos salvo ajustes manuales.

12. Roles y permisos
- User: leer listados, unirse a eventos, crear attempts, votar, subir evidencias propias.
- Staff: crear/editar eventos, retos, polls; marcar ganadores; validar attempts; asignar puntos manuales.
- Admin: todo lo anterior + gestión de políticas y catálogos.
Implementación de roles: tabla user_roles(user_id, role text) + RLS en combinación con auth.jwt().

13. Migraciones (orden sugerido)
1) houses
2) profiles
3) events
4) event_participants
5) challenges
6) challenge_attempts
7) house_challenge_progress
8) polls, poll_options
9) votes
10) ledgers (house_points_ledger, user_points_ledger)
11) índices adicionales
12) políticas RLS
13) funciones (RPCs)
14) triggers
15) storage buckets y políticas

14. Ejemplos de SQL (extractos)
-- Nota: usar esquemas y seguridad según entorno. Placeholders: {{schema}}

-- v_event_participants_counts
CREATE MATERIALIZED VIEW IF NOT EXISTS v_event_participants_counts AS
SELECT event_id, count(DISTINCT user_id) AS participants_count
FROM event_participants
GROUP BY event_id;

-- get_quick_stats
CREATE OR REPLACE FUNCTION get_quick_stats()
RETURNS jsonb LANGUAGE sql SECURITY DEFINER AS $$
WITH active_events AS (
  SELECT id, reward_points, end_at
  FROM events
  WHERE status='active' AND now() BETWEEN start_at AND end_at
), participants AS (
  SELECT count(DISTINCT ep.user_id) AS c
  FROM event_participants ep
  JOIN active_events e ON e.id = ep.event_id
)
SELECT jsonb_build_object(
  'active_events_count', (SELECT count(*) FROM active_events),
  'active_participants_count', (SELECT c FROM participants),
  'points_in_play', COALESCE((SELECT sum(reward_points) FROM active_events),0),
  'min_days_remaining', COALESCE((SELECT CEIL(EXTRACT(EPOCH FROM MIN(end_at - now()))/86400.0)::int FROM active_events), 0)
);
$$;

-- join_event (idempotente)
CREATE OR REPLACE FUNCTION join_event(in_slug text)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE v_event_id uuid; v_user uuid := auth.uid();
BEGIN
  SELECT id INTO v_event_id FROM events WHERE slug=in_slug AND status='active' AND now() BETWEEN start_at AND end_at;
  IF v_event_id IS NULL THEN RAISE EXCEPTION 'Evento no disponible'; END IF;
  INSERT INTO event_participants(event_id, user_id, status)
  VALUES (v_event_id, v_user, 'joined')
  ON CONFLICT (event_id, user_id) DO NOTHING;
END;$$;

-- vote_poll
CREATE OR REPLACE FUNCTION vote_poll(in_slug text, in_option uuid)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE v_poll_id uuid; v_user uuid := auth.uid();
BEGIN
  SELECT id INTO v_poll_id FROM polls WHERE slug=in_slug AND status='active' AND now() BETWEEN start_at AND end_at;
  IF v_poll_id IS NULL THEN RAISE EXCEPTION 'Votación no disponible'; END IF;
  INSERT INTO votes(poll_id, user_id, option_id) VALUES (v_poll_id, v_user, in_option);
END;$$;

15. Indicadores y analítica
- Número de eventos activos, participantes, tasa de conversión Participar/Ver.
- Número de attempts por desafío, tasa de completion.
- Votos por poll y participación por casa.
- Puntos por casa y evolución temporal.
Registrar en tablas existentes y exponer dashboards via consultas agregadas.

16. Errores y estados vacíos
- Sin eventos activos: mostrar mensaje y botón “Crear evento” para staff.
- Usuario no autenticado al participar/votar: abrir modal de login.
- Attempt duplicado: mostrar confirmación de ya inscrito/completado.
- Votación cerrada: desactivar opciones y mostrar próximos polls.

17. Rendimiento y caché
- Usar vistas/materialized para conteos pesados (participantes, votos) con refresh programado.
- Limitar payloads (paginación en listados y archivo pasado).
- Índices en columnas de filtro (status, dates, slug).

18. Seguridad
- RLS estricto en tablas de escritura por usuario.
- Validar inputs en RPCs. Prevenir enumeración de usuarios.
- Almacenamiento: antivirus/validación mimetype para uploads (si aplica).

19. Plan de entrega
- Semana 1: Migraciones base + RLS + buckets storage.
- Semana 2: RPCs + triggers + vistas; wire-up en frontend (fetch y render básico).
- Semana 3: Realtime y leaderboards; QA y pruebas de carga.

20. QA y pruebas
- Casos: unirse evento, intentar desafío, completar desafío, votar, chequear RLS, staff crea/edita evento, ganador asignado, progresos por casa.
- Tests de RPC con usuarios de distintos roles y casas.

21. Dependencias
- Supabase: Auth, Postgres, Storage, Realtime.
- Scripts existentes: auth.js, universal-nav.js. Reutilizar window.supabaseClient.

22. Notas de implementación frontend (rápidas)
- Añadir módulo pages/js/community-events.js que encapsule llamadas:
  - fetchQuickStats, fetchFeaturedEvents, joinEvent, fetchCalendar, fetchUpcoming, fetchMyParticipations, fetchIndividualChallenges, submitAttempt, fetchHouseChallenges, fetchPastEvents, fetchActivePoll, castVote, fetchRecentPollResults, fetchLeaderboards.
- Manejar estados de carga y errores; actualizar barras/progresos con datos reales.
- Suscripción realtime para votación activa cuando exista una poll activa.

23. Consideraciones futuras
- Moderación de submissions.
- Soporte a brackets para torneos.
- Internacionalización de fechas y textos dinámicos.
- Backoffice admin UI.

