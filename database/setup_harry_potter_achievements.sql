-- SISTEMA COMPLETO DE LOGROS TEMÁTICO DE HARRY POTTER
-- Configuración completa para Supabase
-- Ejecuta este código completo en el SQL Editor de Supabase

-- Crear tablas para el sistema de logros
CREATE TABLE IF NOT EXISTS achievement_types (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    icon TEXT DEFAULT '🏆',
    points_reward INTEGER DEFAULT 0,
    category TEXT,
    trigger_condition TEXT,
    auto_award BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- user_achievements: logros obtenidos por usuarios
CREATE TABLE IF NOT EXISTS user_achievements (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    achievement_type_id INTEGER REFERENCES achievement_types(id) ON DELETE CASCADE,
    awarded_by UUID REFERENCES auth.users(id),
    reason TEXT,
    awarded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, achievement_type_id)
);

-- user_statistics: estadísticas para logros automáticos
CREATE TABLE IF NOT EXISTS user_statistics (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    stat_name TEXT NOT NULL,
    stat_value INTEGER DEFAULT 0,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, stat_name)
);

-- Habilitar RLS
ALTER TABLE achievement_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_statistics ENABLE ROW LEVEL SECURITY;

-- Políticas para achievement_types (todos pueden ver)
DROP POLICY IF EXISTS "Anyone can view achievement types" ON achievement_types;
CREATE POLICY "Anyone can view achievement types" 
    ON achievement_types FOR SELECT 
    USING (true);

-- Políticas para user_achievements
DROP POLICY IF EXISTS "Users can view their own achievements" ON user_achievements;
CREATE POLICY "Users can view their own achievements" 
    ON user_achievements FOR SELECT 
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "House heads can view achievements of their house members" ON user_achievements;
CREATE POLICY "House heads can view achievements of their house members" 
    ON user_achievements FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM user_profiles up1, user_profiles up2 
            WHERE up1.id = auth.uid() 
            AND up2.id = user_achievements.user_id
            AND up1.house = up2.house 
            AND (up1.role = 'house_head' OR up1.role = 'admin' OR up1.is_house_head = true)
        )
    );

DROP POLICY IF EXISTS "House heads can insert achievements for their house members" ON user_achievements;
CREATE POLICY "House heads can insert achievements for their house members" 
    ON user_achievements FOR INSERT 
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM user_profiles up1, user_profiles up2 
            WHERE up1.id = auth.uid() 
            AND up2.id = user_achievements.user_id
            AND up1.house = up2.house 
            AND (up1.role = 'house_head' OR up1.role = 'admin' OR up1.is_house_head = true)
        )
    );

-- Políticas para user_statistics
DROP POLICY IF EXISTS "Users can view their own statistics" ON user_statistics;
CREATE POLICY "Users can view their own statistics" 
    ON user_statistics FOR SELECT 
    USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "System can update user statistics" ON user_statistics;
CREATE POLICY "System can update user statistics" 
    ON user_statistics FOR ALL 
    USING (true);

-- Función para actualizar estadísticas de usuario
CREATE OR REPLACE FUNCTION update_user_stat(
    p_user_id UUID,
    p_stat_name TEXT,
    p_increment INTEGER DEFAULT 1
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO user_statistics (user_id, stat_name, stat_value, last_updated)
    VALUES (p_user_id, p_stat_name, p_increment, CURRENT_TIMESTAMP)
    ON CONFLICT (user_id, stat_name) 
    DO UPDATE SET 
        stat_value = user_statistics.stat_value + p_increment,
        last_updated = CURRENT_TIMESTAMP;
END;
$$;

-- Función para verificar y otorgar logros automáticamente
CREATE OR REPLACE FUNCTION check_and_award_achievements(p_user_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    achievement RECORD;
    user_stat INTEGER;
    awarded_count INTEGER := 0;
    result JSON;
BEGIN
    -- Iterar sobre todos los logros automáticos
    FOR achievement IN 
        SELECT * FROM achievement_types 
        WHERE auto_award = true 
        AND id NOT IN (
            SELECT achievement_type_id 
            FROM user_achievements 
            WHERE user_id = p_user_id
        )
    LOOP
        -- Verificar condiciones específicas
        CASE achievement.trigger_condition
            WHEN 'user_registration' THEN
                -- Se otorga automáticamente al registrarse
                INSERT INTO user_achievements (user_id, achievement_type_id, awarded_by, reason)
                VALUES (p_user_id, achievement.id, p_user_id, 'Logro automático por registro');
                awarded_count := awarded_count + 1;
                
            WHEN 'posts_count_50' THEN
                SELECT COALESCE(stat_value, 0) INTO user_stat 
                FROM user_statistics 
                WHERE user_id = p_user_id AND stat_name = 'forum_posts';
                
                IF user_stat >= 50 THEN
                    INSERT INTO user_achievements (user_id, achievement_type_id, awarded_by, reason)
                    VALUES (p_user_id, achievement.id, p_user_id, 'Logro automático por 50 publicaciones');
                    awarded_count := awarded_count + 1;
                END IF;
                
            WHEN 'daily_visits_7' THEN
                SELECT COALESCE(stat_value, 0) INTO user_stat 
                FROM user_statistics 
                WHERE user_id = p_user_id AND stat_name = 'consecutive_days';
                
                IF user_stat >= 7 THEN
                    INSERT INTO user_achievements (user_id, achievement_type_id, awarded_by, reason)
                    VALUES (p_user_id, achievement.id, p_user_id, 'Logro automático por 7 días consecutivos');
                    awarded_count := awarded_count + 1;
                END IF;
                
            WHEN 'house_points_100' THEN
                SELECT COALESCE(house_points, 0) INTO user_stat 
                FROM user_profiles 
                WHERE id = p_user_id;
                
                IF user_stat >= 100 THEN
                    INSERT INTO user_achievements (user_id, achievement_type_id, awarded_by, reason)
                    VALUES (p_user_id, achievement.id, p_user_id, 'Logro automático por 100 puntos de casa');
                    awarded_count := awarded_count + 1;
                END IF;
        END CASE;
    END LOOP;
    
    -- Actualizar puntos del usuario por logros obtenidos
    IF awarded_count > 0 THEN
        UPDATE user_profiles 
        SET house_points = COALESCE(house_points, 0) + (
            SELECT COALESCE(SUM(at.points_reward), 0)
            FROM user_achievements ua
            JOIN achievement_types at ON ua.achievement_type_id = at.id
            WHERE ua.user_id = p_user_id 
            AND ua.awarded_at >= CURRENT_TIMESTAMP - INTERVAL '1 minute'
        )
        WHERE id = p_user_id;
    END IF;
    
    result := json_build_object(
        'achievements_awarded', awarded_count,
        'message', CASE 
            WHEN awarded_count > 0 THEN '¡Nuevos logros desbloqueados!'
            ELSE 'No hay nuevos logros disponibles'
        END
    );
    
    RETURN result;
END;
$$;

-- Función para asignar logros manualmente
CREATE OR REPLACE FUNCTION assign_achievement_to_user(
    p_user_id UUID,
    p_achievement_type_id INTEGER,
    p_reason TEXT DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_awarded_by UUID;
    v_points INTEGER;
    v_result JSON;
BEGIN
    -- Obtener el usuario que asigna el logro
    v_awarded_by := auth.uid();
    
    -- Verificar que el usuario que asigna tiene permisos
    IF NOT EXISTS (
        SELECT 1 FROM user_profiles up1, user_profiles up2 
        WHERE up1.id = v_awarded_by 
        AND up2.id = p_user_id
        AND up1.house = up2.house 
        AND (up1.role = 'house_head' OR up1.role = 'admin' OR up1.is_house_head = true)
    ) THEN
        RAISE EXCEPTION 'No tienes permisos para asignar logros';
    END IF;
    
    -- Obtener puntos del logro
    SELECT points_reward INTO v_points 
    FROM achievement_types 
    WHERE id = p_achievement_type_id;
    
    -- Insertar el logro
    INSERT INTO user_achievements (user_id, achievement_type_id, awarded_by, reason)
    VALUES (p_user_id, p_achievement_type_id, v_awarded_by, p_reason)
    ON CONFLICT (user_id, achievement_type_id) DO NOTHING;
    
    -- Actualizar puntos del usuario
    UPDATE user_profiles 
    SET house_points = COALESCE(house_points, 0) + v_points
    WHERE id = p_user_id;
    
    -- Retornar resultado
    v_result := json_build_object(
        'success', true,
        'points_added', v_points,
        'message', 'Logro asignado exitosamente'
    );
    
    RETURN v_result;
END;
$$;

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

ON CONFLICT (name) DO NOTHING;

-- Mensaje de confirmación
SELECT 'Sistema de logros de Harry Potter configurado exitosamente! 🎉' as message,
       COUNT(*) as logros_creados 
FROM achievement_types;