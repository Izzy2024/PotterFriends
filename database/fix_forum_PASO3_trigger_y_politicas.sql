-- ============================================================================
-- PASO 3: Crear trigger para usuarios nuevos y configurar políticas
-- ============================================================================
-- IMPORTANTE: Ejecuta este script DESPUÉS del PASO 2
-- ============================================================================

-- Crear función para manejar nuevos usuarios
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
DECLARE
    user_name TEXT;
BEGIN
    -- Intentar obtener el nombre del usuario de user_metadata
    user_name := COALESCE(
        NEW.raw_user_meta_data->>'wizard_name',
        NEW.raw_user_meta_data->>'display_name',
        NEW.raw_user_meta_data->>'username',
        NEW.raw_user_meta_data->>'full_name',
        NEW.raw_user_meta_data->>'first_name',
        SPLIT_PART(NEW.email, '@', 1),
        'Usuario'
    );
    
    -- Insertar o actualizar perfil
    INSERT INTO public.user_profiles (
        id, 
        wizard_name, 
        display_name,
        username,
        avatar_url,
        house_id,
        updated_at
    )
    VALUES (
        NEW.id,
        user_name,
        user_name,
        COALESCE(NEW.raw_user_meta_data->>'username', SPLIT_PART(NEW.email, '@', 1)),
        NEW.raw_user_meta_data->>'avatar_url',
        CASE 
            WHEN NEW.raw_user_meta_data->>'house_id' IS NOT NULL 
            THEN (NEW.raw_user_meta_data->>'house_id')::INTEGER
            ELSE NULL
        END,
        NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
        wizard_name = COALESCE(EXCLUDED.wizard_name, user_profiles.wizard_name),
        display_name = COALESCE(EXCLUDED.display_name, user_profiles.display_name),
        username = COALESCE(EXCLUDED.username, user_profiles.username),
        avatar_url = COALESCE(EXCLUDED.avatar_url, user_profiles.avatar_url),
        house_id = COALESCE(EXCLUDED.house_id, user_profiles.house_id),
        updated_at = NOW();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

SELECT '✅ Función handle_new_user() creada' as resultado;

-- Crear trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT OR UPDATE ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

SELECT '✅ Trigger on_auth_user_created creado' as resultado;

-- Configurar Row Level Security (RLS)
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Política para lectura pública
DROP POLICY IF EXISTS "Allow public read access to user_profiles" ON public.user_profiles;
CREATE POLICY "Allow public read access to user_profiles"
    ON public.user_profiles
    FOR SELECT
    USING (true);

-- Política para actualizar propio perfil
DROP POLICY IF EXISTS "Users can update own profile" ON public.user_profiles;
CREATE POLICY "Users can update own profile"
    ON public.user_profiles
    FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Política para inserción
DROP POLICY IF EXISTS "Allow system to insert profiles" ON public.user_profiles;
CREATE POLICY "Allow system to insert profiles"
    ON public.user_profiles
    FOR INSERT
    WITH CHECK (true);

SELECT '✅ Políticas RLS configuradas' as resultado;

-- Verificación final
SELECT '=== VERIFICACIÓN FINAL ===' as info;

SELECT 
    'Total de usuarios' as metrica,
    COUNT(*) as valor
FROM auth.users;

SELECT 
    'Total de perfiles' as metrica,
    COUNT(*) as valor
FROM public.user_profiles;

SELECT 
    'Perfiles con nombre' as metrica,
    COUNT(*) as valor
FROM public.user_profiles
WHERE wizard_name IS NOT NULL AND wizard_name != '';

SELECT 
    'Usuarios sin perfil' as metrica,
    COUNT(*) as valor
FROM auth.users u
WHERE NOT EXISTS (SELECT 1 FROM public.user_profiles up WHERE up.id = u.id);

SELECT '✅ CONFIGURACIÓN COMPLETADA' as resultado;
