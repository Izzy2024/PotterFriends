-- Script de verificación para el Dashboard de Salas Comunes
-- Ejecutar estas consultas para verificar que todo funciona correctamente

-- 1. Verificar que las tablas base existan
SELECT 'houses' as table_name, count(*) as record_count FROM houses
UNION ALL
SELECT 'house_points_ledger', count(*) FROM house_points_ledger
UNION ALL
SELECT 'achievement_types', count(*) FROM achievement_types
UNION ALL
SELECT 'user_achievements', count(*) FROM user_achievements
UNION ALL
SELECT 'forum_user_stats', count(*) FROM forum_user_stats;

-- 2. Probar función de ranking de casas
SELECT 'leaderboard_houses - all time' as test;
SELECT * FROM leaderboard_houses('all');

SELECT 'leaderboard_houses - this week' as test;
SELECT * FROM leaderboard_houses('week');

-- 3. Probar función de ranking de usuarios
SELECT 'leaderboard_users - all time' as test;
SELECT * FROM leaderboard_users('all') LIMIT 10;

-- 4. Probar breakdown de puntos (usar ID de casa real)
SELECT 'house_points_breakdown - Gryffindor' as test;
SELECT * FROM get_house_points_breakdown(1);

-- 5. Verificar relaciones entre tablas
SELECT 'profiles with house_id' as test;
SELECT count(*) as profiles_with_house FROM profiles WHERE house_id IS NOT NULL;

SELECT 'achievement_types active' as test;
SELECT count(*) as active_achievements FROM achievement_types WHERE is_active = true;

-- 6. Verificar datos de ejemplo
SELECT 'sample house points' as test;
SELECT h.name as house, sum(hpl.points) as total_points
FROM houses h
LEFT JOIN house_points_ledger hpl ON h.id = hpl.house_id
GROUP BY h.id, h.name
ORDER BY total_points DESC;

-- 7. Verificar logros de usuarios
SELECT 'user achievements' as test;
SELECT at.name as achievement, count(*) as users_earned
FROM user_achievements ua
JOIN achievement_types at ON ua.achievement_type_id = at.id
GROUP BY at.id, at.name
ORDER BY users_earned DESC;

-- 8. Verificar posts por casa (si existe la tabla)
DO $$
BEGIN
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'posts') THEN
        RAISE NOTICE 'Posts table exists - checking distribution by house';
        -- Esta consulta solo se ejecutará si la tabla posts existe
    ELSE
        RAISE NOTICE 'Posts table does not exist - create it if needed for forum functionality';
    END IF;
END $$;