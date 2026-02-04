-- ARREGLAR PROBLEMAS DE AUTENTICACIÓN EN SUPABASE
-- Ejecuta este código en el SQL Editor de Supabase para solucionar errores de login

-- 1. Verificar si la tabla user_profiles existe y tiene las políticas correctas
SELECT schemaname, tablename, rowsecurity, hasoids
FROM pg_tables 
WHERE tablename = 'user_profiles';

-- 2. Verificar políticas existentes en user_profiles
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies 
WHERE tablename = 'user_profiles';

-- 3. Crear o actualizar políticas para user_profiles
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
DROP POLICY IF EXISTS "Enable read access for all users" ON user_profiles;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON user_profiles;
DROP POLICY IF EXISTS "Enable update for users based on id" ON user_profiles;

-- Políticas básicas para user_profiles
CREATE POLICY "Users can view own profile" 
    ON user_profiles FOR SELECT 
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" 
    ON user_profiles FOR UPDATE 
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" 
    ON user_profiles FOR INSERT 
    WITH CHECK (auth.uid() = id);

-- Política adicional para que otros usuarios puedan ver perfiles básicos (para el foro)
CREATE POLICY "Users can view basic profile info" 
    ON user_profiles FOR SELECT 
    USING (true);

-- 4. Verificar que RLS esté habilitado
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- 5. Crear función para manejar nuevos usuarios automáticamente
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.user_profiles (id, email, created_at)
  VALUES (new.id, new.email, now());
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Crear trigger para nuevos usuarios (si no existe)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 7. Verificar permisos en auth.users (debe ser accesible)
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT SELECT ON auth.users TO authenticated;

-- 8. Asegurar que user_profiles tenga las columnas necesarias
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS email TEXT,
ADD COLUMN IF NOT EXISTS wizard_name TEXT,
ADD COLUMN IF NOT EXISTS first_name TEXT,
ADD COLUMN IF NOT EXISTS last_name TEXT,
ADD COLUMN IF NOT EXISTS house TEXT,
ADD COLUMN IF NOT EXISTS house_points INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'student',
ADD COLUMN IF NOT EXISTS is_house_head BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS avatar_url TEXT,
ADD COLUMN IF NOT EXISTS bio TEXT,
ADD COLUMN IF NOT EXISTS patronus TEXT,
ADD COLUMN IF NOT EXISTS wand_wood TEXT,
ADD COLUMN IF NOT EXISTS wand_core TEXT,
ADD COLUMN IF NOT EXISTS blood_status TEXT,
ADD COLUMN IF NOT EXISTS favorite_subject TEXT,
ADD COLUMN IF NOT EXISTS created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT now();

-- 9. Crear índices para mejorar performance
CREATE INDEX IF NOT EXISTS user_profiles_house_idx ON user_profiles(house);
CREATE INDEX IF NOT EXISTS user_profiles_role_idx ON user_profiles(role);
CREATE INDEX IF NOT EXISTS user_profiles_email_idx ON user_profiles(email);

-- 10. Función para obtener perfil de usuario actual
CREATE OR REPLACE FUNCTION get_current_user_profile()
RETURNS TABLE (
    id UUID,
    email TEXT,
    wizard_name TEXT,
    first_name TEXT,
    last_name TEXT,
    house TEXT,
    house_points INTEGER,
    role TEXT,
    is_house_head BOOLEAN,
    avatar_url TEXT,
    bio TEXT,
    patronus TEXT,
    wand_wood TEXT,
    wand_core TEXT,
    blood_status TEXT,
    favorite_subject TEXT,
    created_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        up.id,
        up.email,
        up.wizard_name,
        up.first_name,
        up.last_name,
        up.house,
        up.house_points,
        up.role,
        up.is_house_head,
        up.avatar_url,
        up.bio,
        up.patronus,
        up.wand_wood,
        up.wand_core,
        up.blood_status,
        up.favorite_subject,
        up.created_at,
        up.updated_at
    FROM user_profiles up
    WHERE up.id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Mensaje de confirmación
SELECT 'Configuración de autenticación corregida exitosamente!' as message;