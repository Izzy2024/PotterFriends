-- COMPLETAR SISTEMA DE LOGROS AUTOMÁTICO
-- Crear las tablas y funciones restantes

-- Crear tabla user_achievements si no existe
CREATE TABLE IF NOT EXISTS user_achievements (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    achievement_type_id INTEGER REFERENCES achievement_types(id) ON DELETE CASCADE,
    awarded_by UUID REFERENCES auth.users(id),
    reason TEXT,
    awarded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, achievement_type_id)
);

-- Crear tabla user_statistics si no existe
CREATE TABLE IF NOT EXISTS user_statistics (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    stat_name TEXT NOT NULL,
    stat_value INTEGER DEFAULT 0,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, stat_name)
);

-- Habilitar RLS
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_statistics ENABLE ROW LEVEL SECURITY;

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

-- Verificar que todo está configurado correctamente
SELECT 
    'Sistema de logros automático completado exitosamente! 🎉' as message,
    (SELECT COUNT(*) FROM achievement_types) as total_logros,
    (SELECT COUNT(DISTINCT category) FROM achievement_types) as categorias,
    'Tablas: achievement_types, user_achievements, user_statistics' as tablas_creadas,
    'Funciones: update_user_stat, check_and_award_achievements, assign_achievement_to_user' as funciones_creadas;