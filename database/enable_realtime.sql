-- Script para habilitar la replicación en tiempo real en las tablas del foro

-- Primero verificamos qué tablas tienen replicación habilitada
SELECT 
    schemaname,
    tablename,
    rowsecurity
FROM 
    pg_tables 
WHERE 
    schemaname = 'public' 
    AND tablename IN ('posts', 'comments', 'likes', 'categories', 'forum_user_stats');

-- Para habilitar la replicación, ve a tu dashboard de Supabase:
-- 1. Ve a Database > Replication
-- 2. Encuentra las siguientes tablas y habilita la replicación:
--    - posts
--    - comments
--    - likes (opcional)
-- 3. Guarda los cambios

-- Alternativamente, puedes usar estas sentencias SQL (requiere permisos de superusuario):
-- ALTER PUBLICATION supabase_realtime ADD TABLE posts;
-- ALTER PUBLICATION supabase_realtime ADD TABLE comments;
-- ALTER PUBLICATION supabase_realtime ADD TABLE likes;

-- Nota: En el dashboard de Supabase es más fácil hacer esto desde la interfaz gráfica
