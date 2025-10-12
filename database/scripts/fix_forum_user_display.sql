-- Script para solucionar el problema de usuarios anónimos en el foro
-- Este script crea un trigger para insertar automáticamente un perfil en user_profiles
-- cuando se crea un nuevo usuario en auth.users

-- 1. Primero, verificamos si la tabla user_profiles existe
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT FROM information_schema.tables 
        WHERE table_schema = 'public' 
        AND table_name = 'user_profiles'
    ) THEN
        -- Crear tabla user_profiles si no existe
        CREATE TABLE user_profiles (
            id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
            wizard_name TEXT,
            display_name TEXT,
            username TEXT,
            avatar_url TEXT,
            house_id INTEGER REFERENCES houses(id),
            created_at TIMESTAMPTZ DEFAULT NOW(),
            updated_at TIMESTAMPTZ DEFAULT NOW()
        );
        
        -- Crear índice para búsquedas rápidas
        CREATE INDEX IF NOT EXISTS idx_user_profiles_id ON user_profiles(id);
        
        RAISE NOTICE 'Tabla user_profiles creada exitosamente';
    ELSE
        RAISE NOTICE 'Tabla user_profiles ya existe';
    END IF;
END $$;

-- 2. Crear o reemplazar función para insertar perfil automáticamente
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
        SPLIT_PART(NEW.email, '@', 1)
    );
    
    -- Insertar perfil en user_profiles
    INSERT INTO public.user_profiles (
        id, 
        wizard_name, 
        display_name, 
        avatar_url,
        house_id,
        created_at,
        updated_at
    )
    VALUES (
        NEW.id,
        user_name,
        user_name,
        NEW.raw_user_meta_data->>'avatar_url',
        CASE 
            WHEN NEW.raw_user_meta_data->>'house_id' IS NOT NULL 
            THEN (NEW.raw_user_meta_data->>'house_id')::INTEGER
            ELSE NULL
        END,
        NOW(),
        NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
        wizard_name = COALESCE(EXCLUDED.wizard_name, user_profiles.wizard_name),
        display_name = COALESCE(EXCLUDED.display_name, user_profiles.display_name),
        avatar_url = COALESCE(EXCLUDED.avatar_url, user_profiles.avatar_url),
        house_id = COALESCE(EXCLUDED.house_id, user_profiles.house_id),
        updated_at = NOW();
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Crear trigger si no existe
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT OR UPDATE ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- 4. Insertar perfiles para usuarios existentes que no tienen perfil
INSERT INTO public.user_profiles (id, wizard_name, display_name, avatar_url, house_id)
SELECT 
    u.id,
    COALESCE(
        u.raw_user_meta_data->>'wizard_name',
        u.raw_user_meta_data->>'display_name',
        u.raw_user_meta_data->>'username',
        u.raw_user_meta_data->>'full_name',
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

-- 5. Configurar políticas RLS para user_profiles
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

-- Política para inserción (solo el sistema)
DROP POLICY IF EXISTS "Allow system to insert profiles" ON public.user_profiles;
CREATE POLICY "Allow system to insert profiles"
    ON public.user_profiles
    FOR INSERT
    WITH CHECK (true);

-- 6. Verificar resultados
SELECT 'Usuarios sin perfil:' as mensaje, COUNT(*) as cantidad
FROM auth.users u
WHERE NOT EXISTS (SELECT 1 FROM public.user_profiles up WHERE up.id = u.id);

SELECT 'Total de perfiles creados:' as mensaje, COUNT(*) as cantidad
FROM public.user_profiles;

SELECT 'Muestra de perfiles:' as mensaje;
SELECT id, wizard_name, display_name, house_id, created_at 
FROM public.user_profiles 
ORDER BY created_at DESC 
LIMIT 5;
