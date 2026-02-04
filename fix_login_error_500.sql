-- SOLUCION PARA ERROR 500 EN LOGIN
-- Este script corrige el error "Database error granting user"

-- 1. Verificar si existe la tabla user_profiles
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'user_profiles') THEN
        -- Crear tabla user_profiles si no existe
        CREATE TABLE user_profiles (
            id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
            email TEXT,
            wizard_name TEXT,
            first_name TEXT,
            last_name TEXT,
            username TEXT,
            display_name TEXT,
            house TEXT,
            house_points INTEGER DEFAULT 0,
            role TEXT DEFAULT 'student',
            is_house_head BOOLEAN DEFAULT false,
            is_prefect BOOLEAN DEFAULT false,
            bio TEXT,
            avatar_url TEXT,
            patronus TEXT,
            wand_wood TEXT,
            wand_core TEXT,
            blood_status TEXT,
            favorite_subject TEXT,
            reputation_level INTEGER DEFAULT 1,
            contributions_count INTEGER DEFAULT 0,
            privacy_public_profile BOOLEAN DEFAULT true,
            privacy_show_stats BOOLEAN DEFAULT true,
            privacy_allow_messages BOOLEAN DEFAULT true,
            house_selected_at TIMESTAMP WITH TIME ZONE,
            join_date TIMESTAMP WITH TIME ZONE DEFAULT now(),
            created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
        );
    END IF;
END
$$;

-- 2. Eliminar todas las políticas existentes
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can view basic profile info" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
DROP POLICY IF EXISTS "Enable all for authenticated users" ON user_profiles;
DROP POLICY IF EXISTS "Enable read access for all users" ON user_profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON user_profiles;
DROP POLICY IF EXISTS "Enable update for users based on id" ON user_profiles;

-- 3. Deshabilitar temporalmente RLS para evitar conflictos
ALTER TABLE user_profiles DISABLE ROW LEVEL SECURITY;

-- 4. Crear políticas simples y funcionales
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Política para SELECT (lectura)
CREATE POLICY "allow_select_user_profiles" 
    ON user_profiles 
    FOR SELECT 
    USING (true);

-- Política para INSERT (creación)
CREATE POLICY "allow_insert_user_profiles" 
    ON user_profiles 
    FOR INSERT 
    WITH CHECK (auth.uid() = id);

-- Política para UPDATE (actualización)
CREATE POLICY "allow_update_user_profiles" 
    ON user_profiles 
    FOR UPDATE 
    USING (auth.uid() = id);

-- 5. Eliminar trigger existente
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- 6. Crear función mejorada para manejar nuevos usuarios
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger 
LANGUAGE plpgsql 
SECURITY DEFINER
AS $$
BEGIN
  -- Insertar perfil básico para el nuevo usuario
  INSERT INTO public.user_profiles (
    id, 
    email, 
    username, 
    display_name,
    wizard_name,
    created_at,
    updated_at
  )
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    COALESCE(
      NEW.raw_user_meta_data->>'first_name' || ' ' || NEW.raw_user_meta_data->>'last_name',
      NEW.raw_user_meta_data->>'wizard_name',
      split_part(NEW.email, '@', 1)
    ),
    COALESCE(NEW.raw_user_meta_data->>'wizard_name', 'Mago'),
    now(),
    now()
  )
  ON CONFLICT (id) DO UPDATE SET
    email = EXCLUDED.email,
    updated_at = now();
  
  RETURN NEW;
END;
$$;

-- 7. Crear trigger para nuevos usuarios
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW 
  EXECUTE FUNCTION public.handle_new_user();

-- 8. Asegurar permisos correctos
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.user_profiles TO authenticated;
GRANT SELECT ON public.user_profiles TO anon;

-- 9. Crear índices para mejorar rendimiento
CREATE INDEX IF NOT EXISTS user_profiles_email_idx ON user_profiles(email);
CREATE INDEX IF NOT EXISTS user_profiles_house_idx ON user_profiles(house);

-- 10. Verificar que todo esté funcionando
DO $$
BEGIN
    RAISE NOTICE 'Verificando configuración...';
    
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'user_profiles') THEN
        RAISE NOTICE '✓ Tabla user_profiles existe';
    ELSE
        RAISE NOTICE '✗ Tabla user_profiles NO existe';
    END IF;
    
    IF EXISTS (SELECT FROM pg_policies WHERE tablename = 'user_profiles') THEN
        RAISE NOTICE '✓ Políticas RLS configuradas';
    ELSE
        RAISE NOTICE '✗ No hay políticas RLS';
    END IF;
    
    RAISE NOTICE 'Configuración completada exitosamente!';
END
$$;