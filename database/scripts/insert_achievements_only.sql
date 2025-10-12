-- INSERTAR SOLO LOS LOGROS TEMÁTICOS
-- Ejecuta este código DESPUÉS de arreglar la tabla

-- Insertar los logros temáticos de Harry Potter
INSERT INTO achievement_types (name, description, icon, points_reward, category, trigger_condition) VALUES

-- ==========================================================
-- Categoría: PRIMER AÑO (Para nuevos miembros)
-- ==========================================================
('La Carta de Hogwarts', '¡Has sido aceptado! Creaste tu cuenta en nuestra comunidad mágica.', '✉️', 10, 'primer_ano', 'user_registration'),
('El Sombrero Seleccionador', 'Completaste el Test y fuiste seleccionado para tu noble Casa.', '🎓', 15, 'primer_ano', 'house_selection'),
('De Compras en el Callejón Diagon', 'Completaste tu perfil de usuario con toda la información mágica.', '🛍️', 20, 'primer_ano', 'profile_completion'),
('Primera Clase Asistida', 'Visitaste la sección de Guías o Roles por primera vez.', '📚', 10, 'primer_ano', 'first_guide_visit'),
('Plataforma 9¾', 'Te presentaste a la comunidad en el foro de bienvenida.', '🚂', 15, 'primer_ano', 'first_forum_post'),

-- ==========================================================
-- Categoría: VIDA SOCIAL EN HOGWARTS (Interacción y comunidad)
-- ==========================================================
('Primer Hechizo Verbal', 'Publicaste tu primer tema en el foro.', '💬', 15, 'vida_social_hogwarts', 'first_topic_created'),
('Eco en el Gran Comedor', 'Tu tema ha recibido más de 10 respuestas.', '🔊', 25, 'vida_social_hogwarts', 'topic_10_replies'),
('Conjurando Amistad', 'Interactuaste positivamente con otros miembros.', '🤝', 20, 'vida_social_hogwarts', 'first_interaction'),
('El Trío de Oro', 'Has participado en conversaciones con múltiples miembros.', '🧑‍🤝‍🧑', 35, 'vida_social_hogwarts', 'social_interaction_3'),
('Lumos Maxima', 'Tu contenido fue muy bien recibido por la comunidad.', '💡', 40, 'vida_social_hogwarts', 'popular_content'),
('Conversador del Caldero Chorreante', 'Has escrito 50 mensajes en los foros.', '🗣️', 50, 'vida_social_hogwarts', 'posts_count_50'),

-- ==========================================================
-- Categoría: LEALTAD DE CASA (Acciones relacionadas con la Casa)
-- ==========================================================
('Orgullo de Casa', 'Visitaste la sala común de tu Casa por primera vez.', '🏠', 25, 'lealtad_casa', 'house_room_visit'),
('Guardián de la Sala Común', 'Participaste activamente en actividades de tu Casa.', '🛡️', 40, 'lealtad_casa', 'house_activities_5'),
('Campeón de la Casa', 'Aportaste 100 puntos a tu Casa a través de tus logros.', '🏆', 60, 'lealtad_casa', 'house_points_100'),
('¡Diez puntos para tu Casa!', 'Tu participación destacó y fue reconocida.', '🔟', 50, 'lealtad_casa', 'recognized_contribution'),

-- ==========================================================
-- Categoría: MAESTRÍA ACADÉMICA (Conocimiento y creación)
-- ==========================================================
('Erudito de Biblioteca', 'Has explorado múltiples secciones de conocimiento.', '📖', 20, 'maestria_academica', 'sections_visited_10'),
('Supera los T.I.M.O.s', 'Completaste desafíos o quizzes con excelentes resultados.', '📝', 50, 'maestria_academica', 'quiz_completion'),
('Maestro de Pociones', 'Creaste contenido valioso para la comunidad.', '🧪', 75, 'maestria_academica', 'content_creation'),
('Historiador de la Magia', 'Has estado activo en la comunidad por más de 30 días.', '⏳', 100, 'maestria_academica', 'active_days_30'),
('Redactor de El Profeta', 'Has contribuido significativamente con contenido.', '📰', 80, 'maestria_academica', 'content_contributions_5'),

-- ==========================================================
-- Categoría: EXPLORACIÓN MÁGICA (Logros divertidos y de descubrimiento)
-- ==========================================================
('Cazador de la Snitch Dorada', 'Fuiste rápido en participar en eventos especiales.', '✨', 40, 'exploracion_magica', 'quick_participation'),
('Coleccionista de Cromos', 'Descubriste características ocultas de la página.', '🐸', 30, 'exploracion_magica', 'easter_egg_discovery'),
('¡Alohomora!', 'Accediste a secciones especiales por primera vez.', '🔓', 50, 'exploracion_magica', 'special_access'),
('Viajero del Giratiempo', 'Visitaste la página consistentemente durante una semana.', '⌛', 35, 'exploracion_magica', 'daily_visits_7'),
('Explorador de Hogwarts', 'Has visitado todas las secciones principales de la página.', '🗺️', 45, 'exploracion_magica', 'all_sections_visited'),

-- ==========================================================
-- Categoría: EVENTOS ESPECIALES (Logros de temporada)
-- ==========================================================
('Espíritu Navideño', 'Participaste en eventos especiales de temporada.', '🎄', 30, 'eventos_especiales', 'seasonal_participation'),
('Baile de Navidad', 'Participaste en eventos sociales especiales.', '💃', 40, 'eventos_especiales', 'special_event_participation'),
('Cazador de Huevos de Pascua', 'Encontraste sorpresas ocultas durante eventos.', '🥚', 35, 'eventos_especiales', 'event_easter_eggs')

ON CONFLICT DO NOTHING;

-- Verificar logros insertados
SELECT 'Logros temáticos de Harry Potter insertados exitosamente! 🎉' as message,
       COUNT(*) as total_logros,
       COUNT(DISTINCT category) as categorias
FROM achievement_types;