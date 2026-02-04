-- ESTRATEGIA PARA MANEJAR DUAL TABLAS: profiles Y user_profiles
-- Solución al error 500 considerando la estructura real de la base de datos

-- 1. VERIFICAR ESTADO ACTUAL DE AMBAS TABLAS
SELECT 
    'profiles' as tabla,
    count(*) as registros
FROM profiles
UNION ALL
SELECT 
    'user_profiles' as tabla,
    count(*) as registros  
FROM user_profiles;

-- 2. SINCRONIZAR DATOS ENTRE AMBAS TABLAS
-- Copiar datos faltantes de profiles a user_profiles
INSERT INTO user_profiles (
    id, 
    wizard_name, 
    display_name,
    house,
    role,
    created_at,
    updated_at
)
SELECT 
    p.id,
    p.wizard_name,
    COALESCE(p.first_name || ' ' || p.last_name, p.wizard_name) as display_name,
    p.house,
    COALESCE(p.role, 'student') as role,
    p.created_at,
    p.updated_at
FROM profiles p
WHERE p.id NOT IN (SELECT id FROM user_profiles WHERE id IS NOT NULL)
ON CONFLICT (id) DO UPDATE SET
    wizard_name = EXCLUDED.wizard_name,
    house = EXCLUDED.house,
    updated_at = now();

-- 3. SINCRONIZAR EN DIRECCIÓN OPUESTA
-- Actualizar profiles con datos de user_profiles
UPDATE profiles SET
    wizard_name = up.wizard_name,
    house = up.house,
    updated_at = now()
FROM user_profiles up
WHERE profiles.id = up.id
    AND (profiles.wizard_name IS NULL OR profiles.house IS NULL);

-- 4. CREAR FUNCIÓN PARA MANTENER SINCRONIZACIÓN
CREATE OR REPLACE FUNCTION sync_profile_tables()
RETURNS TRIGGER AS $$
BEGIN
    -- Si se actualiza profiles, sincronizar a user_profiles
    IF TG_TABLE_NAME = 'profiles' THEN
        INSERT INTO user_profiles (
            id, wizard_name, display_name, house, role, updated_at
        ) VALUES (
            NEW.id,
            NEW.wizard_name,
            COALESCE(NEW.first_name || ' ' || NEW.last_name, NEW.wizard_name),
            NEW.house,
            COALESCE(NEW.role, 'student'),
            now()
        )
        ON CONFLICT (id) DO UPDATE SET
            wizard_name = EXCLUDED.wizard_name,
            house = EXCLUDED.house,
            updated_at = now();
    END IF;
    
    -- Si se actualiza user_profiles, sincronizar a profiles
    IF TG_TABLE_NAME = 'user_profiles' THEN
        UPDATE profiles SET
            wizard_name = NEW.wizard_name,
            house = NEW.house,
            updated_at = now()
        WHERE id = NEW.id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 5. CREAR TRIGGERS PARA SINCRONIZACIÓN AUTOMÁTICA
DROP TRIGGER IF EXISTS sync_to_user_profiles ON profiles;
CREATE TRIGGER sync_to_user_profiles
    AFTER INSERT OR UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION sync_profile_tables();

DROP TRIGGER IF EXISTS sync_to_profiles ON user_profiles;
CREATE TRIGGER sync_to_profiles
    AFTER INSERT OR UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION sync_profile_tables();

-- 6. MEJORAR POLÍTICAS RLS PARA user_profiles
DROP POLICY IF EXISTS "allow_select_user_profiles" ON user_profiles;
DROP POLICY IF EXISTS "allow_insert_user_profiles" ON user_profiles;
DROP POLICY IF EXISTS "allow_update_user_profiles" ON user_profiles;

CREATE POLICY "user_profiles_select_policy" 
    ON user_profiles FOR SELECT 
    USING (true);

CREATE POLICY "user_profiles_insert_policy" 
    ON user_profiles FOR INSERT 
    WITH CHECK (auth.uid() = id);

CREATE POLICY "user_profiles_update_policy" 
    ON user_profiles FOR UPDATE 
    USING (auth.uid() = id);

-- 7. MEJORAR POLÍTICAS RLS PARA profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "profiles_select_policy" ON profiles;
DROP POLICY IF EXISTS "profiles_insert_policy" ON profiles;
DROP POLICY IF EXISTS "profiles_update_policy" ON profiles;

CREATE POLICY "profiles_select_policy" 
    ON profiles FOR SELECT 
    USING (true);

CREATE POLICY "profiles_insert_policy" 
    ON profiles FOR INSERT 
    WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_update_policy" 
    ON profiles FOR UPDATE 
    USING (auth.uid() = id);

-- 8. CREAR FUNCIÓN PARA MANEJAR NUEVOS USUARIOS EN AMBAS TABLAS
CREATE OR REPLACE FUNCTION handle_new_user_dual_tables()
RETURNS TRIGGER AS $$
BEGIN
    -- Insertar en profiles (tabla básica)
    INSERT INTO public.profiles (
        id, 
        email, 
        wizard_name,
        first_name,
        last_name,
        house,
        role,
        created_at,
        updated_at
    ) VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'wizard_name', 'Mago'),
        NEW.raw_user_meta_data->>'first_name',
        NEW.raw_user_meta_data->>'last_name',
        NEW.raw_user_meta_data->>'house',
        'student',
        now(),
        now()
    ) ON CONFLICT (id) DO NOTHING;
    
    -- Insertar en user_profiles (tabla completa)
    INSERT INTO public.user_profiles (
        id,
        display_name,
        wizard_name,
        house,
        role,
        bio,
        reputation_level,
        house_points,
        contributions_count,
        is_house_head,
        is_prefect,
        privacy_public_profile,
        privacy_show_stats,
        privacy_allow_messages,
        created_at,
        updated_at
    ) VALUES (
        NEW.id,
        COALESCE(
            NEW.raw_user_meta_data->>'first_name' || ' ' || NEW.raw_user_meta_data->>'last_name',
            NEW.raw_user_meta_data->>'wizard_name',
            split_part(NEW.email, '@', 1)
        ),
        COALESCE(NEW.raw_user_meta_data->>'wizard_name', 'Mago'),
        NEW.raw_user_meta_data->>'house',
        'student',
        'Nuevo miembro de la comunidad mágica de Hogwarts.',
        1,
        0,
        0,
        false,
        false,
        true,
        true,
        true,
        now(),
        now()
    ) ON CONFLICT (id) DO NOTHING;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. ACTUALIZAR TRIGGER PARA NUEVOS USUARIOS
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user_dual_tables();

-- 10. VERIFICACIÓN FINAL
SELECT 
    'Verificación completada' as status,
    (SELECT count(*) FROM profiles) as profiles_count,
    (SELECT count(*) FROM user_profiles) as user_profiles_count;