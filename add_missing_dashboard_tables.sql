-- Script para agregar SOLO las tablas faltantes para el dashboard
-- Basado en las migraciones existentes en el proyecto

-- ===================================
-- 1. TABLA DE TIPOS DE LOGROS
-- ===================================
CREATE TABLE IF NOT EXISTS public.achievement_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(10) DEFAULT '🏆',
    points_reward INTEGER DEFAULT 0,
    category VARCHAR(50), -- 'forum', 'house', 'event', 'social'
    requirements JSONB, -- Criterios para obtener el logro
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para mejor performance
CREATE INDEX IF NOT EXISTS idx_achievement_types_category ON achievement_types(category);
CREATE INDEX IF NOT EXISTS idx_achievement_types_active ON achievement_types(is_active);

-- ===================================
-- 2. TABLA DE LOGROS DE USUARIOS
-- ===================================
CREATE TABLE IF NOT EXISTS public.user_achievements (
    id SERIAL PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    achievement_type_id INTEGER REFERENCES achievement_types(id) ON DELETE CASCADE,
    awarded_at TIMESTAMPTZ DEFAULT NOW(),
    awarded_by UUID REFERENCES auth.users(id),
    notes TEXT,
    UNIQUE(user_id, achievement_type_id)
);

-- Índices
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_id ON user_achievements(user_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_awarded_at ON user_achievements(awarded_at);
CREATE INDEX IF NOT EXISTS idx_user_achievements_type ON user_achievements(achievement_type_id);

-- ===================================
-- 3. TABLA DE ESTADÍSTICAS DEL FORO
-- ===================================
CREATE TABLE IF NOT EXISTS public.forum_user_stats (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    total_posts INTEGER DEFAULT 0,
    total_comments INTEGER DEFAULT 0,
    reputation_points INTEGER DEFAULT 0,
    last_post_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===================================
-- 4. FUNCIÓN RPC PARA DESGLOSE DE PUNTOS
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
-- 5. POLÍTICAS DE SEGURIDAD (RLS)
-- ===================================

-- Habilitar RLS
ALTER TABLE achievement_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE forum_user_stats ENABLE ROW LEVEL SECURITY;

-- Políticas para achievement_types
CREATE POLICY IF NOT EXISTS "Anyone can view achievement types" 
ON achievement_types FOR SELECT 
USING (is_active = true);

-- Políticas para user_achievements
CREATE POLICY IF NOT EXISTS "Anyone can view achievements" 
ON user_achievements FOR SELECT 
USING (true);

CREATE POLICY IF NOT EXISTS "Only authenticated users can earn achievements" 
ON user_achievements FOR INSERT 
WITH CHECK (auth.role() = 'authenticated');

-- Políticas para forum_user_stats
CREATE POLICY IF NOT EXISTS "Anyone can view forum stats" 
ON forum_user_stats FOR SELECT 
USING (true);

-- ===================================
-- 6. DATOS DE EJEMPLO PARA TESTING
-- ===================================

-- Insertar algunos tipos de logros
INSERT INTO achievement_types (name, description, icon, points_reward, category) VALUES
('Primera Publicación', 'Realizó su primera publicación en el foro', '📝', 10, 'forum'),
('Conversador Activo', 'Ha realizado 10 publicaciones en el foro', '💬', 50, 'forum'),
('Veterano de la Casa', 'Lleva más de 30 días en su casa', '🏠', 100, 'house'),
('Comentarista Experto', 'Ha realizado 25 comentarios', '💭', 30, 'forum'),
('Organizador de Eventos', 'Ha organizado un evento comunitario', '🎉', 200, 'event'),
('Líder de Discusión', 'Su publicación recibió más de 10 respuestas', '👑', 75, 'forum'),
('Espíritu de Casa', 'Ha participado en 5 desafíos de casa', '⚡', 150, 'house'),
('Bienvenida Mágica', 'Se unió a la comunidad', '✨', 25, 'house')
ON CONFLICT (name) DO NOTHING;

-- ===================================
-- 7. TRIGGER PARA ACTUALIZAR ESTADÍSTICAS DEL FORO
-- ===================================

-- Función trigger para actualizar estadísticas
CREATE OR REPLACE FUNCTION update_forum_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- Actualizar estadísticas cuando se crea un post
    IF TG_OP = 'INSERT' AND TG_TABLE_NAME = 'posts' THEN
        INSERT INTO forum_user_stats (user_id, total_posts, updated_at)
        VALUES (NEW.user_id, 1, NOW())
        ON CONFLICT (user_id) 
        DO UPDATE SET 
            total_posts = forum_user_stats.total_posts + 1,
            last_post_at = NOW(),
            updated_at = NOW();
        RETURN NEW;
    END IF;
    
    -- Actualizar estadísticas cuando se crea un comentario
    IF TG_OP = 'INSERT' AND TG_TABLE_NAME = 'comments' THEN
        INSERT INTO forum_user_stats (user_id, total_comments, updated_at)
        VALUES (NEW.user_id, 1, NOW())
        ON CONFLICT (user_id) 
        DO UPDATE SET 
            total_comments = forum_user_stats.total_comments + 1,
            updated_at = NOW();
        RETURN NEW;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Aplicar triggers si las tablas existen
DO $$
BEGIN
    -- Trigger para posts
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'posts') THEN
        DROP TRIGGER IF EXISTS update_forum_stats_posts_trigger ON posts;
        CREATE TRIGGER update_forum_stats_posts_trigger
            AFTER INSERT ON posts
            FOR EACH ROW
            EXECUTE FUNCTION update_forum_stats();
    END IF;
    
    -- Trigger para comentarios
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'comments') THEN
        DROP TRIGGER IF EXISTS update_forum_stats_comments_trigger ON comments;
        CREATE TRIGGER update_forum_stats_comments_trigger
            AFTER INSERT ON comments
            FOR EACH ROW
            EXECUTE FUNCTION update_forum_stats();
    END IF;
END $$;

-- ===================================
-- 8. COMENTARIOS EXPLICATIVOS
-- ===================================

COMMENT ON TABLE achievement_types IS 'Tipos de logros disponibles en el sistema';
COMMENT ON TABLE user_achievements IS 'Logros obtenidos por los usuarios';
COMMENT ON TABLE forum_user_stats IS 'Estadísticas de participación en el foro por usuario';
COMMENT ON FUNCTION get_house_points_breakdown IS 'Obtiene el desglose de puntos por fuente para una casa específica';