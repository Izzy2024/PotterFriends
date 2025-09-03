-- Script para verificar tablas existentes en Supabase
-- Ejecutar en la consola SQL de Supabase para ver el estado actual

-- 1. LISTAR TODAS LAS TABLAS EXISTENTES
SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

-- 2. VERIFICAR ESTRUCTURA DE TABLA PROFILES
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- 3. VERIFICAR SI EXISTE USER_PROFILES
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'user_profiles'
) as user_profiles_exists;

-- 4. VERIFICAR TABLAS RELACIONADAS CON CASAS
SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'houses'
) as houses_exists;

-- 5. VERIFICAR TABLAS DE PUNTOS Y LOGROS
SELECT 
    'house_points_ledger' as table_name,
    EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'house_points_ledger'
    ) as exists
UNION ALL
SELECT 
    'achievement_types',
    EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'achievement_types'
    )
UNION ALL
SELECT 
    'user_achievements',
    EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'user_achievements'
    )
UNION ALL
SELECT 
    'forum_user_stats',
    EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'forum_user_stats'
    )
UNION ALL
SELECT 
    'posts',
    EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'posts'
    )
UNION ALL
SELECT 
    'events',
    EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'events'
    );

-- 6. VERIFICAR FUNCIONES RPC EXISTENTES
SELECT 
    routinename as function_name,
    routinetype as type
FROM information_schema.routines 
WHERE routineschema = 'public' 
AND routinename IN ('leaderboard_houses', 'leaderboard_users', 'get_house_points_breakdown')
ORDER BY routinename;

-- 7. MOSTRAR MUESTRA DE DATOS DE TABLAS CLAVE (si existen)
DO $$
BEGIN
    -- Verificar datos en profiles
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'profiles') THEN
        RAISE NOTICE 'PROFILES TABLE - Sample data:';
        PERFORM pg_sleep(0.1); -- Pequeña pausa para logging
    END IF;
    
    -- Verificar datos en houses
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'houses') THEN
        RAISE NOTICE 'HOUSES TABLE - Sample data:';
        PERFORM pg_sleep(0.1);
    END IF;
END $$;

-- Si la tabla profiles existe, mostrar muestra
SELECT 'PROFILES - Sample (first 3 records)' as info;
SELECT id, username, created_at, house_id
FROM profiles 
LIMIT 3;

-- Si la tabla houses existe, mostrar todas las casas
SELECT 'HOUSES - All records' as info;
SELECT * FROM houses ORDER BY id;