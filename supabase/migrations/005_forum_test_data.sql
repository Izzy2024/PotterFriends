-- Script para crear datos de prueba del foro
-- IMPORTANTE: Solo ejecutar si las tablas están vacías

-- Función para crear posts de prueba
CREATE OR REPLACE FUNCTION create_forum_test_data()
RETURNS VOID AS $$
DECLARE
    test_user_id UUID;
    cat_teorias UUID;
    cat_fanfiction UUID;
    cat_arte UUID;
    cat_debates UUID;
    cat_ayuda UUID;
    post_1 UUID;
    post_2 UUID;
    post_3 UUID;
BEGIN
    -- Verificar si ya hay posts
    IF EXISTS (SELECT 1 FROM posts LIMIT 1) THEN
        RAISE NOTICE 'Ya existen posts en la base de datos. No se crearán datos de prueba.';
        RETURN;
    END IF;

    -- Obtener IDs de categorías
    SELECT id INTO cat_teorias FROM categories WHERE name = 'Teorías y Análisis' LIMIT 1;
    SELECT id INTO cat_fanfiction FROM categories WHERE name = 'Fanfiction' LIMIT 1;
    SELECT id INTO cat_arte FROM categories WHERE name = 'Arte y Creatividad' LIMIT 1;
    SELECT id INTO cat_debates FROM categories WHERE name = 'Debates Mágicos' LIMIT 1;
    SELECT id INTO cat_ayuda FROM categories WHERE name = 'Ayuda y Preguntas' LIMIT 1;

    -- Intentar obtener un usuario real de la tabla auth.users
    SELECT id INTO test_user_id FROM auth.users LIMIT 1;
    
    -- Si no hay usuarios reales, crear posts sin user_id específico (se manejará en el frontend)
    IF test_user_id IS NULL THEN
        RAISE NOTICE 'No se encontraron usuarios reales. Creando posts de demostración...';
        
        -- Crear usuario ficticio temporal (solo para demostración)
        -- En producción, esto no debería hacerse
        INSERT INTO auth.users (id, email, created_at) 
        VALUES 
            ('00000000-0000-0000-0000-000000000001', 'demo@hogwarts.com', NOW()),
            ('00000000-0000-0000-0000-000000000002', 'student@hogwarts.com', NOW()),
            ('00000000-0000-0000-0000-000000000003', 'wizard@hogwarts.com', NOW())
        ON CONFLICT (id) DO NOTHING;
        
        SELECT '00000000-0000-0000-0000-000000000001'::UUID INTO test_user_id;
    END IF;

    RAISE NOTICE 'Creando posts de prueba...';

    -- Crear posts de prueba
    INSERT INTO posts (user_id, house_id, category_id, title, content, views, is_featured) VALUES
        (test_user_id, 1, cat_teorias, '¿Por qué Snape realmente protegió a Harry?', 
         'Una teoría profunda sobre las verdaderas motivaciones de Severus Snape más allá del amor por Lily. Analizando todas las pistas que dejó J.K. Rowling...', 
         847, true),
        ('00000000-0000-0000-0000-000000000002', 3, cat_teorias, 'Análisis: La Magia de los Horrocruxes', 
         'Un estudio detallado sobre la magia oscura detrás de los Horrocruxes y sus implicaciones en el mundo mágico...', 
         1250, true),
        (test_user_id, 2, cat_teorias, 'La verdadera naturaleza de los Dementores', 
         'Los Dementores representan algo más que simples criaturas mágicas. Su simbolismo y origen...', 
         456, false),
        ('00000000-0000-0000-0000-000000000002', 3, cat_teorias, '¿Podría existir magia sin varita?', 
         'Explorando las posibilidades de la magia wandless y sus implicaciones...', 
         289, false);

    -- Obtener IDs de los posts recién creados
    SELECT id INTO post_1 FROM posts WHERE title = '¿Por qué Snape realmente protegió a Harry?' LIMIT 1;
    SELECT id INTO post_2 FROM posts WHERE title = 'Análisis: La Magia de los Horrocruxes' LIMIT 1;
    SELECT id INTO post_3 FROM posts WHERE title = 'La verdadera naturaleza de los Dementores' LIMIT 1;

    -- Crear más posts para otras categorías
    INSERT INTO posts (user_id, house_id, category_id, title, content, views) VALUES
        (test_user_id, 1, cat_fanfiction, 'Los Merodeadores: Años Perdidos', 
         'Una historia original sobre los años perdidos de James, Sirius, Remus y Peter...', 
         234),
        ('00000000-0000-0000-0000-000000000003', 4, cat_fanfiction, 'Hogwarts: Una Nueva Era', 
         'Historia completa sobre una nueva generación de estudiantes en Hogwarts...', 
         189),
        ('00000000-0000-0000-0000-000000000002', 3, cat_arte, 'Retrato de Hermione', 
         'Mi interpretación artística del personaje de Hermione Granger...', 
         127),
        ('00000000-0000-0000-0000-000000000003', 4, cat_arte, 'Hogwarts al Atardecer', 
         'Ilustración digital del castillo de Hogwarts durante el atardecer...', 
         203),
        (test_user_id, 1, cat_debates, '¿Snape era realmente un héroe?', 
         'Debate abierto sobre la verdadera naturaleza moral de Severus Snape...', 
         678),
        ('00000000-0000-0000-0000-000000000002', 3, cat_debates, '¿Cuál es la casa más poderosa?', 
         'Análisis comparativo del poder mágico de cada casa de Hogwarts...', 
         892),
        ('00000000-0000-0000-0000-000000000003', 4, cat_ayuda, '¿Cómo cambio mi casa asignada?', 
         'Soy nuevo en el foro y me asignaron una casa que no me gusta...', 
         45),
        ('00000000-0000-0000-0000-000000000002', 3, cat_ayuda, 'Guía para nuevos miembros', 
         'Todo lo que necesitas saber para empezar en nuestra comunidad mágica...', 
         567);

    -- Crear comentarios de prueba
    IF post_1 IS NOT NULL THEN
        INSERT INTO comments (post_id, user_id, content) VALUES
            (post_1, '00000000-0000-0000-0000-000000000002', 'Excelente análisis! Nunca había pensado en esa perspectiva.'),
            (post_1, '00000000-0000-0000-0000-000000000003', 'Totalmente de acuerdo. Snape es un personaje mucho más complejo.'),
            (post_1, test_user_id, 'Gracias por los comentarios! Estoy preparando una segunda parte.');
    END IF;

    IF post_2 IS NOT NULL THEN
        INSERT INTO comments (post_id, user_id, content) VALUES
            (post_2, test_user_id, 'Increíble investigación sobre los Horrocruxes.'),
            (post_2, '00000000-0000-0000-0000-000000000003', 'Me ha ayudado mucho a entender mejor la historia.');
    END IF;

    -- Crear algunos likes de prueba
    IF post_1 IS NOT NULL THEN
        INSERT INTO likes (user_id, post_id) VALUES
            ('00000000-0000-0000-0000-000000000002', post_1),
            ('00000000-0000-0000-0000-000000000003', post_1);
    END IF;

    IF post_2 IS NOT NULL THEN
        INSERT INTO likes (user_id, post_id) VALUES
            (test_user_id, post_2),
            ('00000000-0000-0000-0000-000000000003', post_2);
    END IF;

    -- Actualizar estadísticas de usuarios
    INSERT INTO forum_user_stats (user_id, total_posts, total_comments)
    SELECT 
        user_id,
        COUNT(*) as post_count,
        0
    FROM posts 
    GROUP BY user_id
    ON CONFLICT (user_id) DO UPDATE SET 
        total_posts = EXCLUDED.total_posts;

    -- Actualizar conteos de comentarios
    INSERT INTO forum_user_stats (user_id, total_comments)
    SELECT 
        user_id,
        COUNT(*) as comment_count
    FROM comments 
    GROUP BY user_id
    ON CONFLICT (user_id) DO UPDATE SET 
        total_comments = EXCLUDED.total_comments;

    RAISE NOTICE 'Datos de prueba del foro creados exitosamente!';
    RAISE NOTICE 'Posts creados: %', (SELECT COUNT(*) FROM posts);
    RAISE NOTICE 'Comentarios creados: %', (SELECT COUNT(*) FROM comments);
    RAISE NOTICE 'Likes creados: %', (SELECT COUNT(*) FROM likes);

END;
$$ LANGUAGE plpgsql;

-- Ejecutar la función
SELECT create_forum_test_data();

-- Crear algunos perfiles de usuario para demostración
INSERT INTO user_profiles (id, wizard_name, house_id, level, experience_points, avatar_url) VALUES
    ('00000000-0000-0000-0000-000000000001', 'María González', 1, 15, 1250, 'https://images.unsplash.com/photo-1494790108755-2616b612b786?q=80&w=400&auto=format&fit=crop'),
    ('00000000-0000-0000-0000-000000000002', 'Ana Rodríguez', 3, 22, 2100, 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=400&auto=format&fit=crop'),
    ('00000000-0000-0000-0000-000000000003', 'Carlos Mendoza', 4, 18, 1680, 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=400&auto=format&fit=crop')
ON CONFLICT (id) DO UPDATE SET
    wizard_name = EXCLUDED.wizard_name,
    house_id = EXCLUDED.house_id,
    level = EXCLUDED.level,
    experience_points = EXCLUDED.experience_points,
    avatar_url = EXCLUDED.avatar_url;

-- Limpiar función temporal
DROP FUNCTION IF EXISTS create_forum_test_data();

-- Mensaje final
DO $$
BEGIN
    RAISE NOTICE '✅ Setup del foro completado. El foro ahora debería mostrar contenido dinámico.';
END $$;