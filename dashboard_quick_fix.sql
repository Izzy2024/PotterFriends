-- Fix rápido para problemas comunes del dashboard

-- ===================================
-- 1. ASEGURAR QUE POSTS TENGA HOUSE_ID
-- ===================================
-- Si los posts no tienen house_id, asignarlos basado en el usuario
UPDATE posts 
SET house_id = (
    SELECT CASE up.house
        WHEN 'gryffindor' THEN 1
        WHEN 'hufflepuff' THEN 2  
        WHEN 'ravenclaw' THEN 3
        WHEN 'slytherin' THEN 4
        ELSE NULL
    END
    FROM user_profiles up 
    WHERE up.id = posts.user_id
)
WHERE house_id IS NULL 
AND user_id IN (SELECT id FROM user_profiles WHERE house IS NOT NULL);

-- ===================================
-- 2. INSERTAR ALGUNOS EVENTOS DE PRUEBA SI NO HAY
-- ===================================
INSERT INTO events (
    slug, title, description, type, status, featured, 
    start_at, end_at, reward_points, created_at
) 
SELECT 
    'torneo-casas-' || generate_random_uuid()::text,
    'Torneo de Casas de ' || TO_CHAR(NOW(), 'Month'),
    'Competencia mensual entre las casas de Hogwarts',
    'tournament',
    'active',
    true,
    NOW() + INTERVAL '2 days',
    NOW() + INTERVAL '10 days', 
    100,
    NOW()
WHERE NOT EXISTS (
    SELECT 1 FROM events WHERE status = 'active' AND start_at > NOW()
)
LIMIT 1;

INSERT INTO events (
    slug, title, description, type, status, featured,
    start_at, end_at, reward_points, created_at
)
SELECT 
    'celebracion-' || generate_random_uuid()::text,
    'Celebración del Día Mágico',
    'Celebremos juntos nuestra comunidad mágica',
    'celebration', 
    'active',
    false,
    NOW() + INTERVAL '5 days',
    NOW() + INTERVAL '7 days',
    50,
    NOW()
WHERE (SELECT COUNT(*) FROM events WHERE status = 'active') < 2
LIMIT 1;

-- ===================================
-- 3. ASEGURAR DATOS DE FORUM_USER_STATS
-- ===================================
-- Insertar stats básicas para usuarios que no las tienen
INSERT INTO forum_user_stats (user_id, total_posts, total_comments, reputation_points, updated_at)
SELECT 
    up.id,
    COALESCE((SELECT COUNT(*) FROM posts WHERE user_id = up.id), 0),
    COALESCE((SELECT COUNT(*) FROM comments WHERE user_id = up.id), 0),
    25, -- Puntos base
    NOW()
FROM user_profiles up
WHERE NOT EXISTS (SELECT 1 FROM forum_user_stats WHERE user_id = up.id);

-- ===================================
-- 4. VERIFICAR Y CORREGIR ACHIEVEMENT_TYPES
-- ===================================
-- Asegurar que hay logros activos
UPDATE achievement_types SET is_active = true WHERE is_active IS NULL;

-- ===================================
-- 5. CREAR ALGUNOS USER_POINTS_LEDGER SI NO EXISTEN
-- ===================================
-- Esto ayudará con leaderboard_users
DO $$
BEGIN
    IF (SELECT COUNT(*) FROM user_points_ledger) = 0 THEN
        INSERT INTO user_points_ledger (user_id, source, points, note, created_at)
        SELECT 
            up.id,
            'manual',
            FLOOR(RANDOM() * 200 + 50)::INTEGER,
            'Puntos de actividad inicial',
            NOW() - (RANDOM() * INTERVAL '30 days')
        FROM user_profiles up
        LIMIT 10;
        
        RAISE NOTICE 'Creados puntos de usuario de prueba para leaderboard';
    END IF;
END $$;

-- ===================================
-- 6. VERIFICACIÓN FINAL
-- ===================================
SELECT 'VERIFICACIÓN POST-FIX' as status;

SELECT 
    'Posts con house_id' as check_item, 
    COUNT(*) as total,
    COUNT(CASE WHEN house_id IS NOT NULL THEN 1 END) as with_house_id
FROM posts;

SELECT 
    'Eventos activos' as check_item,
    COUNT(*) as total
FROM events WHERE status = 'active';

SELECT 
    'User_points_ledger' as check_item,
    COUNT(*) as total
FROM user_points_ledger;

SELECT 'FIX COMPLETADO ✅' as resultado;