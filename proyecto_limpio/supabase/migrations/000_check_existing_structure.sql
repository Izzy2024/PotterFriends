-- Script para verificar la estructura existente de tu base de datos
-- Ejecuta esto primero para ver qué tienes actualmente

-- 1. Verificar si la tabla houses existe y su estructura
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM 
    information_schema.columns
WHERE 
    table_name = 'houses'
ORDER BY 
    ordinal_position;

-- 2. Verificar si la tabla profiles existe y su estructura
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM 
    information_schema.columns
WHERE 
    table_name = 'profiles'
ORDER BY 
    ordinal_position;

-- 3. Ver las casas existentes (si las hay)
SELECT * FROM houses;

-- 4. Verificar si ya existen algunas de las tablas del foro
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('posts', 'comments', 'likes', 'categories', 'forum_user_stats');
