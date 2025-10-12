-- ============================================================================
-- PASO 2: Sincronizar datos de usuarios existentes
-- ============================================================================
-- IMPORTANTE: Ejecuta este script DESPUÉS del PASO 1
-- ============================================================================

-- Actualizar perfiles existentes con datos de auth.users
UPDATE public.user_profiles up
SET 
    wizard_name = COALESCE(
        up.wizard_name,
        u.raw_user_meta_data->>'wizard_name',
        u.raw_user_meta_data->>'display_name',
        u.raw_user_meta_data->>'username',
        u.raw_user_meta_data->>'full_name',
        u.raw_user_meta_data->>'first_name',
        SPLIT_PART(u.email, '@', 1),
        'Usuario'
    ),
    display_name = COALESCE(
        up.display_name,
        u.raw_user_meta_data->>'display_name',
        u.raw_user_meta_data->>'wizard_name',
        u.raw_user_meta_data->>'username',
        SPLIT_PART(u.email, '@', 1),
        'Usuario'
    ),
    username = COALESCE(
        up.username,
        u.raw_user_meta_data->>'username',
        SPLIT_PART(u.email, '@', 1)
    ),
    avatar_url = COALESCE(up.avatar_url, u.raw_user_meta_data->>'avatar_url'),
    updated_at = NOW()
FROM auth.users u
WHERE up.id = u.id
AND (up.wizard_name IS NULL OR up.display_name IS NULL);

SELECT '✅ Perfiles existentes actualizados' as resultado;

-- Insertar perfiles para usuarios que no tienen perfil
INSERT INTO public.user_profiles (id, wizard_name, display_name, username, avatar_url, house_id)
SELECT 
    u.id,
    COALESCE(
        u.raw_user_meta_data->>'wizard_name',
        u.raw_user_meta_data->>'display_name',
        u.raw_user_meta_data->>'username',
        u.raw_user_meta_data->>'full_name',
        u.raw_user_meta_data->>'first_name',
        SPLIT_PART(u.email, '@', 1),
        'Usuario'
    ) as wizard_name,
    COALESCE(
        u.raw_user_meta_data->>'display_name',
        u.raw_user_meta_data->>'wizard_name',
        u.raw_user_meta_data->>'username',
        SPLIT_PART(u.email, '@', 1),
        'Usuario'
    ) as display_name,
    COALESCE(
        u.raw_user_meta_data->>'username',
        SPLIT_PART(u.email, '@', 1)
    ) as username,
    u.raw_user_meta_data->>'avatar_url' as avatar_url,
    CASE 
        WHEN u.raw_user_meta_data->>'house_id' IS NOT NULL 
        THEN (u.raw_user_meta_data->>'house_id')::INTEGER
        ELSE NULL
    END as house_id
FROM auth.users u
WHERE NOT EXISTS (
    SELECT 1 FROM public.user_profiles up WHERE up.id = u.id
)
ON CONFLICT (id) DO NOTHING;

SELECT '✅ Nuevos perfiles creados para usuarios existentes' as resultado;

-- Verificar resultados
SELECT 
    'Usuarios sin perfil' as estado, 
    COUNT(*) as cantidad
FROM auth.users u
WHERE NOT EXISTS (SELECT 1 FROM public.user_profiles up WHERE up.id = u.id);

SELECT 
    'Perfiles con wizard_name' as estado,
    COUNT(*) as cantidad
FROM public.user_profiles
WHERE wizard_name IS NOT NULL AND wizard_name != '';

SELECT 
    'Muestra de perfiles' as info,
    id,
    wizard_name,
    display_name,
    username
FROM public.user_profiles 
ORDER BY created_at DESC 
LIMIT 5;
