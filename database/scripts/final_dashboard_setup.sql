-- Script final mínimo para el Dashboard
-- Solo agrega lo que falta basado en tu base de datos actual

-- ===================================
-- 1. FUNCIÓN RPC PARA DESGLOSE DE PUNTOS (si no existe)
-- ===================================
CREATE OR REPLACE FUNCTION public.get_house_points_breakdown(target_house_id INTEGER)
RETURNS TABLE (
    source TEXT,
    points BIGINT
) 
LANGUAGE SQL
SECURITY DEFINER
AS $$
    SELECT 
        CASE 
            WHEN hpl.source = 'event' THEN 'Eventos Especiales'
            WHEN hpl.source = 'challenge' THEN 'Desafíos Completados'
            WHEN hpl.source = 'manual' THEN 'Contribuciones'
            WHEN hpl.source = 'vote' THEN 'Foro y Discusiones'
            ELSE 'Otros'
        END as source,
        COALESCE(SUM(hpl.points), 0)::BIGINT as points
    FROM house_points_ledger hpl
    WHERE hpl.house_id = target_house_id
    GROUP BY 
        CASE 
            WHEN hpl.source = 'event' THEN 'Eventos Especiales'
            WHEN hpl.source = 'challenge' THEN 'Desafíos Completados'
            WHEN hpl.source = 'manual' THEN 'Contribuciones'
            WHEN hpl.source = 'vote' THEN 'Foro y Discusiones'
            ELSE 'Otros'
        END
    ORDER BY points DESC;
$$;

-- ===================================
-- 2. VERIFICAR ESTRUCTURA DE USER_PROFILES
-- ===================================
-- Ver si user_profiles.house es texto o referencia a houses.id
SELECT 
    'user_profiles house field check' as info,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'user_profiles' 
AND column_name = 'house'
AND table_schema = 'public';

-- ===================================
-- 3. DATOS DE PRUEBA (solo si no existen)
-- ===================================

-- Insertar algunos puntos de ejemplo si no hay datos
DO $$
BEGIN
    -- Solo si no hay puntos en house_points_ledger
    IF (SELECT COUNT(*) FROM house_points_ledger) = 0 THEN
        -- Insertar puntos de ejemplo para cada casa
        INSERT INTO house_points_ledger (house_id, user_id, source, points, note, created_at)
        SELECT 
            h.id as house_id,
            (SELECT id FROM user_profiles WHERE house = h.name ORDER BY RANDOM() LIMIT 1) as user_id,
            'event' as source,
            (FLOOR(RANDOM() * 100) + 50)::INTEGER as points,
            'Evento de prueba' as note,
            NOW() - (RANDOM() * INTERVAL '30 days') as created_at
        FROM houses h
        CROSS JOIN generate_series(1, 5) -- 5 puntos por casa
        WHERE EXISTS (SELECT 1 FROM user_profiles WHERE house = h.name);
        
        -- Puntos de challenges
        INSERT INTO house_points_ledger (house_id, user_id, source, points, note, created_at)
        SELECT 
            h.id as house_id,
            (SELECT id FROM user_profiles WHERE house = h.name ORDER BY RANDOM() LIMIT 1) as user_id,
            'challenge' as source,
            (FLOOR(RANDOM() * 150) + 25)::INTEGER as points,
            'Desafío completado' as note,
            NOW() - (RANDOM() * INTERVAL '14 days') as created_at
        FROM houses h
        CROSS JOIN generate_series(1, 3) -- 3 puntos de challenge por casa
        WHERE EXISTS (SELECT 1 FROM user_profiles WHERE house = h.name);
        
        RAISE NOTICE 'Datos de ejemplo insertados en house_points_ledger';
    ELSE
        RAISE NOTICE 'Ya existen datos en house_points_ledger - no se insertan datos de ejemplo';
    END IF;
END $$;

-- ===================================
-- 4. VERIFICACIÓN FINAL
-- ===================================
SELECT 'Verificación final' as info;

-- Contar registros en tablas clave
SELECT 
    'houses' as tabla, COUNT(*) as registros FROM houses
UNION ALL
SELECT 
    'user_profiles', COUNT(*) FROM user_profiles
UNION ALL
SELECT 
    'achievement_types', COUNT(*) FROM achievement_types
UNION ALL
SELECT 
    'user_achievements', COUNT(*) FROM user_achievements
UNION ALL
SELECT 
    'house_points_ledger', COUNT(*) FROM house_points_ledger
UNION ALL
SELECT 
    'forum_user_stats', COUNT(*) FROM forum_user_stats;

-- Probar funciones RPC
SELECT 'Probando leaderboard_houses' as test;
SELECT * FROM leaderboard_houses('all') LIMIT 3;

SELECT 'Probando get_house_points_breakdown para casa 1' as test;
SELECT * FROM get_house_points_breakdown(1);

SELECT 'DASHBOARD LISTO! 🏰✨' as resultado;