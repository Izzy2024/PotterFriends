-- Script corregido para solucionar el problema de usuarios anónimos en el foro
-- Versión 2: Adaptado a la estructura existente de user_profiles

-- PASO 1: Verificar estructura actual de user_profiles
DO $$ 
BEGIN
    RAISE NOTICE '=== VERIFICANDO ESTRUCTURA DE user_profiles ===';
END $$;

-- Mostrar columnas actuales
SELECT 
    column_name, 
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name = 'user_profiles'
ORDER BY ordinal_position;

-- PASO 2: Agregar columnas faltantes si no existen
DO $$ 
BEGIN
    -- Agregar wizard_name si no existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'user_profiles' 
        AND column_name = 'wizard_name'
    ) THEN
        ALTER TABLE public.user_profiles ADD COLUMN wizard_name TEXT;
        RAISE NOTICE 'Columna wizard_name agregada';
    ELSE
        RAISE NOTICE 'Columna wizard_name ya existe';
    END IF;

    -- Agregar display_name si no existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'user_profiles' 
        AND column_name = 'display_name'
    ) THEN
        ALTER TABLE public.user_profiles ADD COLUMN display_name TEXT;
        RAISE NOTICE 'Columna display_name agregada';
    ELSE
        RAISE NOTICE 'Columna display_name ya existe';
    END IF;

    -- Agregar avatar_url si no existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'user_profiles' 
        AND column_name = 'avatar_url'
    ) THEN
        ALTER TABLE public.user_profiles ADD COLUMN avatar_url TEXT;
        RAISE NOTICE 'Columna avatar_url agregada';
    ELSE
        RAISE NOTICE 'Columna avatar_url ya existe';
    END IF;

    -- Agregar username si no existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'user_profiles' 
        AND column_name = 'username'
    ) THEN
        ALTER TABLE public.user_profiles ADD COLUMN username TEXT;
        RAISE NOTICE 'Columna username agregada';
    ELSE
        RAISE NOTICE 'Columna username ya existe';
    END IF;

    -- Agregar house_id si no existe (como INTEGER)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'user_profiles' 
        AND column_name = 'house_id'
    ) THEN
        ALTER TABLE public.user_profiles ADD COLUMN house_id INTEGER REFERENCES houses(id);
        RAISE NOTICE 'Columna house_id agregada';
    ELSE
        RAISE NOTICE 'Columna house_id ya existe';
    END IF;

    -- Agregar updated_at si no existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'user_profiles' 
        AND column_name = 'updated_at'
    ) THEN
        ALTER TABLE public.user_profiles ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
        RAISE NOTICE 'Columna updated_at agregada';
    ELSE
        RAISE NOTICE 'Columna updated_at ya existe';
    END IF;
END $$;

-- PASO 3: Crear o reemplazar función para insertar perfil automáticamente
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
        SPLIT_PART(NEW.email, '@', 1)
    );
    
    -- Insertar o actualizar perfil en user_profiles
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

RAISE NOTICE 'Función handle_new_user() creada/actualizada';

-- PASO 4: Crear trigger si no existe
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT OR UPDATE ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

RAISE NOTICE 'Trigger on_auth_user_created creado';

-- PASO 5: Actualizar perfiles existentes con datos de auth.users
DO $$
DECLARE
    updated_count INTEGER := 0;
BEGIN
    -- Actualizar usuarios existentes que tienen datos en user_profiles pero les falta wizard_name
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
            u.raw_user_meta_data->>'full_name',
            SPLIT_PART(u.email, '@', 1),
            'Usuario'
        ),
        avatar_url = COALESCE(up.avatar_url, u.raw_user_meta_data->>'avatar_url'),
        updated_at = NOW()
    FROM auth.users u
    WHERE up.id = u.id
    AND (up.wizard_name IS NULL OR up.display_name IS NULL);
    
    GET DIAGNOSTICS updated_count = ROW_COUNT;
    RAISE NOTICE 'Perfiles actualizados: %', updated_count;
END $$;

-- PASO 6: Insertar perfiles para usuarios que no tienen perfil
DO $$
DECLARE
    inserted_count INTEGER := 0;
BEGIN
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
            u.raw_user_meta_data->>'full_name',
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
    
    GET DIAGNOSTICS inserted_count = ROW_COUNT;
    RAISE NOTICE 'Nuevos perfiles creados: %', inserted_count;
END $$;

-- PASO 7: Configurar políticas RLS para user_profiles
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

-- Política para lectura pública
DROP POLICY IF EXISTS "Allow public read access to user_profiles" ON public.user_profiles;
CREATE POLICY "Allow public read access to user_profiles"
    ON public.user_profiles
    FOR SELECT
    USING (true);

-- Política para que los usuarios puedan actualizar su propio perfil
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

RAISE NOTICE '=== Políticas RLS configuradas ===';

-- PASO 8: Verificar resultados
DO $$ 
BEGIN
    RAISE NOTICE '=== VERIFICACIÓN FINAL ===';
END $$;

-- Contar usuarios sin perfil
SELECT 
    'Usuarios sin perfil' as estado, 
    COUNT(*) as cantidad
FROM auth.users u
WHERE NOT EXISTS (SELECT 1 FROM public.user_profiles up WHERE up.id = u.id);

-- Contar perfiles con datos
SELECT 
    'Perfiles con wizard_name' as estado,
    COUNT(*) as cantidad
FROM public.user_profiles
WHERE wizard_name IS NOT NULL;

-- Mostrar muestra de perfiles
SELECT 
    'Muestra de perfiles creados' as info,
    id,
    wizard_name,
    display_name,
    username,
    house_id
FROM public.user_profiles 
ORDER BY created_at DESC 
LIMIT 5;
