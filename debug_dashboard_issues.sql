-- Script de debug para identificar problemas específicos del dashboard

-- ===================================
-- 1. VERIFICAR MAPEO DE CASAS
-- ===================================
SELECT 'MAPEO DE CASAS' as section;
SELECT id, name as house_name FROM houses ORDER BY id;

-- ===================================
-- 2. VERIFICAR USER_PROFILES Y HOUSE
-- ===================================
SELECT 'USER_PROFILES con HOUSE' as section;
SELECT id, wizard_name, house, created_at FROM user_profiles ORDER BY created_at DESC LIMIT 5;

-- ===================================
-- 3. PROBAR get_house_points_breakdown PARA CADA CASA
-- ===================================
SELECT 'BREAKDOWN SLYTHERIN (ID=4)' as section;
SELECT * FROM get_house_points_breakdown(4);

SELECT 'BREAKDOWN GRYFFINDOR (ID=1)' as section;
SELECT * FROM get_house_points_breakdown(1);

-- ===================================
-- 4. VERIFICAR POSTS CON HOUSE_ID
-- ===================================
SELECT 'POSTS con HOUSE_ID' as section;
SELECT 
    p.id, 
    p.title, 
    p.house_id,
    h.name as house_name,
    p.user_id,
    up.wizard_name,
    p.created_at
FROM posts p
LEFT JOIN houses h ON p.house_id = h.id  
LEFT JOIN user_profiles up ON p.user_id = up.id
ORDER BY p.created_at DESC 
LIMIT 5;

-- ===================================
-- 5. VERIFICAR USER_ACHIEVEMENTS CON JOINS
-- ===================================
SELECT 'USER_ACHIEVEMENTS con JOINS' as section;
SELECT 
    ua.id,
    ua.user_id,
    up.wizard_name,
    up.house,
    at.name as achievement_name,
    at.icon,
    ua.awarded_at
FROM user_achievements ua
JOIN achievement_types at ON ua.achievement_type_id = at.id
JOIN user_profiles up ON ua.user_id = up.id
ORDER BY ua.awarded_at DESC
LIMIT 5;

-- ===================================
-- 6. VERIFICAR EVENTOS ACTIVOS
-- ===================================
SELECT 'EVENTOS ACTIVOS' as section;
SELECT 
    id, 
    title, 
    status, 
    start_at, 
    end_at,
    CASE 
        WHEN start_at > NOW() THEN 'futuro'
        WHEN end_at < NOW() THEN 'pasado'
        ELSE 'activo'
    END as estado_real
FROM events 
WHERE status = 'active'
ORDER BY start_at ASC
LIMIT 5;

-- ===================================
-- 7. VERIFICAR FORUM_USER_STATS
-- ===================================
SELECT 'FORUM_USER_STATS' as section;
SELECT 
    fs.user_id,
    up.wizard_name,
    up.house,
    fs.total_posts,
    fs.total_comments,
    fs.reputation_points
FROM forum_user_stats fs
JOIN user_profiles up ON fs.user_id = up.id
LIMIT 5;

-- ===================================
-- 8. SIMULAR CONSULTA ESPECÍFICA PARA SLYTHERIN
-- ===================================
SELECT 'SIMULANDO CONSULTAS PARA SLYTHERIN' as section;

-- Miembros de Slytherin
SELECT 'Miembros de Slytherin:' as info;
SELECT id, wizard_name, avatar_url, created_at 
FROM user_profiles 
WHERE house = 'slytherin' 
ORDER BY created_at DESC;

-- Logros de Slytherin
SELECT 'Logros de Slytherin:' as info;
SELECT 
    ua.id,
    ua.awarded_at,
    at.name,
    at.icon,
    at.points_reward,
    up.wizard_name
FROM user_achievements ua
JOIN achievement_types at ON ua.achievement_type_id = at.id
JOIN user_profiles up ON ua.user_id = up.id
WHERE up.house = 'slytherin'
ORDER BY ua.awarded_at DESC;

-- Posts de Slytherin (si house_id = 4)
SELECT 'Posts de Slytherin:' as info;
SELECT id, title, user_id, created_at 
FROM posts 
WHERE house_id = 4
ORDER BY created_at DESC 
LIMIT 3;

-- ===================================
-- 9. DIAGNÓSTICO FINAL
-- ===================================
SELECT 'DIAGNÓSTICO' as section;
SELECT 
    'Total casas' as metric, COUNT(*) as value FROM houses
UNION ALL
SELECT 
    'Total user_profiles', COUNT(*) FROM user_profiles
UNION ALL  
SELECT 
    'User_profiles con casa', COUNT(*) FROM user_profiles WHERE house IS NOT NULL
UNION ALL
SELECT 
    'Posts con house_id', COUNT(*) FROM posts WHERE house_id IS NOT NULL
UNION ALL
SELECT 
    'User_achievements', COUNT(*) FROM user_achievements
UNION ALL
SELECT 
    'Achievement_types activos', COUNT(*) FROM achievement_types WHERE is_active = true
UNION ALL
SELECT 
    'Forum_user_stats', COUNT(*) FROM forum_user_stats
UNION ALL
SELECT 
    'Eventos activos', COUNT(*) FROM events WHERE status = 'active';